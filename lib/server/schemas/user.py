from pydantic import BaseModel
from typing import Optional

class UserSummary(BaseModel):
    id: int
    username: str
    nickname: str
    profile_image: Optional[str] = None

    class Config:
        orm_mode = True