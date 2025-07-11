from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from server.database import Base

class PartyMember(Base):
    __tablename__ = "party_members"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    party_id = Column(Integer, ForeignKey("parties.id"))

    user = relationship("User", back_populates="joined_parties")
    party = relationship("Party", back_populates="members")