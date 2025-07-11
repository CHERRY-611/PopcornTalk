from pydantic import BaseModel
from typing import Optional
from .user import UserSummary

class ReviewBase(BaseModel):
    content: str
    rating: Optional[float] = 0.0 

class ReviewCreate(ReviewBase):
    pass

class Review(ReviewBase):
    id: int
    user: UserSummary 
    movie_id: int
    party_id: int

    class Config:
        orm_mode = True
