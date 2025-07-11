from sqlalchemy import Column, Integer, String
from server.database import Base
from sqlalchemy.orm import relationship
from server.models.party_member import PartyMember

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)

    nickname = Column(String, nullable=True)
    profile_image = Column(String, nullable=True)  

    reviews = relationship("Review", back_populates="user", cascade="all, delete")
    joined_parties = relationship("PartyMember", back_populates="user", cascade="all, delete-orphan")