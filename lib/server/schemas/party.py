from pydantic import BaseModel
from typing import List, Optional
from .movie import Movie

class PartyCreate(BaseModel):
    name: str
    one_liner: str
    category: str
    image_url: str

class Party(BaseModel):
    id: int
    name: str
    one_liner: str
    category: str
    image_url: str
    creator_id: int
    movies: List[Movie] = []  #연결된 영화 목록

    class Config:
        orm_mode = True
