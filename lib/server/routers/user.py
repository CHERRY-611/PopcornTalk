from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Header
from sqlalchemy.orm import Session
from server.database import SessionLocal
from server.models.user import User
from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta
from pydantic import BaseModel
from jose import JWTError, jwt
import shutil
import os

# JWT 설정
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class UserCreate(BaseModel):
    username: str
    password: str

def extract_user_id_from_token(token: str) -> int:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise ValueError("토큰에 사용자 ID가 없습니다.")
        return int(user_id)
    except JWTError:
        raise ValueError("유효하지 않은 토큰입니다.")

# 유저 정보 조회 API
@router.get("/me")
def get_me(
    db: Session = Depends(get_db),
    authorization: str = Header(...)
):
    token = authorization.replace("Bearer ", "")
    try:
        user_id = extract_user_id_from_token(token)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    return {
        "nickname": user.nickname,
        "profile_image": user.profile_image if user.profile_image else None
    }


# 회원가입
@router.post("/signup")
def signup(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == user.username).first():
        raise HTTPException(status_code=400, detail="이미 존재하는 ID입니다.")

    hashed_pw = pwd_context.hash(user.password)

    default_image = "/assets/default_profile.jpg"
    new_user = User(
        username=user.username,
        hashed_password=hashed_pw,
        nickname=user.username,
        profile_image=default_image
    )
    db.add(new_user)
    db.commit()
    return {"msg": "회원가입 완료!"}

# 로그인
@router.post("/login")
def login(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()
    if not db_user or not pwd_context.verify(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="ID 또는 비밀번호가 올바르지 않습니다.")

    access_token = jwt.encode(
        {"sub": str(db_user.id), "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)},
        SECRET_KEY,
        algorithm=ALGORITHM,
    )

    return {
        "access_token": access_token,
        "user": {
            "id": db_user.id,
            "username": db_user.username,
            "nickname": db_user.nickname,
            "profile_image": db_user.profile_image,
        }
    }

@router.post("/update-profile")
def update_profile(
    nickname: str = Form(...),
    profile_image: UploadFile = File(None),
    db: Session = Depends(get_db),
    authorization: str = Header(...), 
):
    token = authorization.replace("Bearer ", "") 
    user_id = extract_user_id_from_token(token) 

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    user.nickname = nickname

    if profile_image:
        file_ext = os.path.splitext(profile_image.filename)[-1]
        filename = f"{user.id}_{datetime.now().timestamp()}{file_ext}"
        file_path = f"uploaded_images/{filename}"
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(profile_image.file, buffer)
        user.profile_image = f"/{file_path}"

    db.commit()
    return {"msg": "프로필 업데이트 완료!"}
