from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session, selectinload
from typing import List
from server.dependencies import get_db, get_current_user
from server.models.review import Review as ReviewModel
from server.schemas.review import Review, ReviewCreate  
from server.models.user import User

router = APIRouter()

@router.get("/parties/{party_id}/movies/{movie_id}/reviews", response_model=List[Review])
def get_reviews(party_id: int, movie_id: int, db: Session = Depends(get_db)):
    return (
        db.query(ReviewModel)
        .options(selectinload(ReviewModel.user)) 
        .filter(
            ReviewModel.party_id == party_id,
            ReviewModel.movie_id == movie_id
        )
        .all()
    )

@router.post("/parties/{party_id}/movies/{movie_id}/reviews")
def create_review(
    party_id: int,
    movie_id: int,
    review: ReviewCreate, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    db_review = ReviewModel(
        content=review.content,
        rating=review.rating,
        user_id=current_user.id,
        party_id=party_id,
        movie_id=movie_id,
    )
    db.add(db_review)
    db.commit()
    db.refresh(db_review)
    return {"msg": "리뷰 작성 완료", "review_id": db_review.id}
