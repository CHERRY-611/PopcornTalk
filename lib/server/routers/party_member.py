from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from server.database import get_db
from server.models.party_member import PartyMember
from server.models.party import Party
from server.models.user import User
from server.dependencies import get_current_user

router = APIRouter()

@router.post("/api/parties/{party_id}/join")
def join_party(
    party_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 이미 가입되어 있는지 확인
    exists = db.query(PartyMember).filter_by(
        user_id=current_user.id, party_id=party_id
    ).first()

    if exists:
        raise HTTPException(status_code=400, detail="이미 가입된 파티입니다")

    party = db.query(Party).filter_by(id=party_id).first()
    if not party:
        raise HTTPException(status_code=404, detail="파티를 찾을 수 없습니다")

    member = PartyMember(user_id=current_user.id, party_id=party_id)
    db.add(member)
    db.commit()
    return {"message": "파티 가입 성공"}
