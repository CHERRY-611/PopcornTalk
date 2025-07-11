import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

from fastapi import FastAPI
from server.routers.user import router as user_router
from server.routers.party import router as party_router
from server.database import Base, engine
from fastapi.staticfiles import StaticFiles
from server.routers import movie
from server.routers import review


app = FastAPI()

# 이미지
current_dir = os.path.dirname(os.path.abspath(__file__))
base_dir = os.path.abspath(os.path.join(current_dir, "..", ".."))
image_dir = os.path.join(base_dir, "uploaded_images")
app.mount("/uploaded_images", StaticFiles(directory=image_dir), name="uploaded_images")
assets_dir = os.path.join(base_dir, "assets")
app.mount("/assets", StaticFiles(directory=assets_dir), name="assets")

# DB 테이블 생성
Base.metadata.create_all(bind=engine)

# 라우터 등록
app.include_router(user_router, prefix="/api")
app.include_router(party_router, prefix="/api")
app.include_router(review.router, prefix="/api")
app.include_router(movie.router)
