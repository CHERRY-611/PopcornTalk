from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from server.database import Base
from server.models.review import Review

class Party(Base):
    __tablename__ = "parties"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    one_liner = Column(String)
    category = Column(String)
    image_url = Column(String)
    creator_id = Column(Integer, ForeignKey("users.id"))

    movies = relationship("Movie", back_populates="party", cascade="all, delete")
    reviews = relationship("Review", back_populates="party", cascade="all, delete")
    members = relationship("PartyMember", back_populates="party", cascade="all, delete-orphan")
