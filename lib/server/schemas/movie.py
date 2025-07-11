from pydantic import BaseModel
from typing import Optional

class MovieBase(BaseModel):
    tmdb_id: int         # TMDB에서 받은 영화 ID
    title: str
    poster_path: Optional[str] = None

class MovieCreate(MovieBase):
    pass

class Movie(MovieBase):
    id: int              # DB 내부의 primary key
    party_id: int        # 어떤 파티에 속한 영화인지

    class Config:
        orm_mode = True
