from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from server.database import get_db
from server.models import movie as movie_model
from server.models import party as party_model
from server.schemas import movie as movie_schema

router = APIRouter()

@router.post("/api/parties/{party_id}/movies", response_model=movie_schema.Movie)
def add_movie_to_party(party_id: int, movie: movie_schema.MovieCreate, db: Session = Depends(get_db)):
    new_movie = movie_model.Movie(
        tmdb_id=movie.tmdb_id,
        title=movie.title,
        poster_path=movie.poster_path,
        party_id=party_id
    )
    db.add(new_movie)
    db.commit()
    db.refresh(new_movie)
    return new_movie

@router.get("/api/parties/{party_id}/movies", response_model=list[movie_schema.Movie])
def get_party_movies(party_id: int, db: Session = Depends(get_db)):
    return db.query(movie_model.Movie).filter(movie_model.Movie.party_id == party_id).all()
