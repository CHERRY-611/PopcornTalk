from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from typing import List
import os
import uuid
import shutil

from server.models.party import Party as PartyModel
from server.models.party_member import PartyMember
from server.models.user import User
from server.schemas.party import Party as PartySchema
from server.dependencies import get_db, get_current_user

router = APIRouter()

UPLOAD_DIR = "uploaded_images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.get("/parties", response_model=List[PartySchema])
def list_all_parties(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    joined_ids = db.query(PartyMember.party_id).filter_by(user_id=current_user.id)
    return db.query(PartyModel).filter(~PartyModel.id.in_(joined_ids)).all()


@router.get("/my-parties", response_model=List[PartySchema])
def get_my_parties(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    party_ids = db.query(PartyMember.party_id).filter_by(user_id=current_user.id)
    return db.query(PartyModel).filter(PartyModel.id.in_(party_ids)).all()


@router.get("/unjoined-parties", response_model=List[PartySchema])
def get_unjoined_parties(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    joined_ids = db.query(PartyMember.party_id).filter_by(user_id=current_user.id)
    return db.query(PartyModel).filter(~PartyModel.id.in_(joined_ids)).all()


@router.post("/parties/{party_id}/join")
def join_party(
    party_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 중복 가입 확인
    existing = db.query(PartyMember).filter_by(
        user_id=current_user.id,
        party_id=party_id
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="이미 가입된 파티입니다.")

    membership = PartyMember(user_id=current_user.id, party_id=party_id)
    db.add(membership)
    db.commit()
    return {"message": "가입 성공"}


@router.post("/upload-party")
async def upload_party(
    name: str = Form(...),
    one_liner: str = Form(...),
    category: str = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 파일명 생성
    ext = os.path.splitext(image.filename)[1]
    unique_filename = f"{uuid.uuid4().hex}{ext}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)

    # 파일 저장
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    # DB에 파티 저장
    image_url = f"/{UPLOAD_DIR}/{unique_filename}"
    db_party = PartyModel(
        name=name,
        one_liner=one_liner,
        category=category,
        image_url=image_url,
        creator_id=current_user.id,
    )
    db.add(db_party)
    db.commit()
    db.refresh(db_party)

    # 만든 사람도 자동으로 가입
    membership = PartyMember(user_id=current_user.id, party_id=db_party.id)
    db.add(membership)
    db.commit()

    return {"msg": "파티 생성 완료", "party_id": db_party.id}
