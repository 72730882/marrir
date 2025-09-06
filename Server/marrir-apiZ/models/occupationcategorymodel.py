from sqlalchemy import ForeignKey, Integer, String
from models.base import EntityBaseModel
from models.db import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.occupationmodel import OccupationModel

class OccupationCategoryModel(Base, EntityBaseModel):
    __tablename__ = 'table_occupation_categories'
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    occupations = relationship(OccupationModel, back_populates="category")