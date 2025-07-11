from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from server.database import Base

class Movie(Base):
    __tablename__ = "movies"

    id = Column(Integer, primary_key=True, index=True)
    tmdb_id = Column(Integer, index=True)  # TMDB 고유 ID
    title = Column(String)
    poster_path = Column(String)

    party_id = Column(Integer, ForeignKey("parties.id"))
    party = relationship("Party", back_populates="movies")
    reviews = relationship("Review", back_populates="movie", cascade="all, delete")
