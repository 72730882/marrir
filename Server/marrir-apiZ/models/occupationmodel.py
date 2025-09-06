from sqlalchemy import ForeignKey, Integer, String
from models.base import EntityBaseModel
from models.db import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship

class OccupationModel(Base, EntityBaseModel):
    __tablename__ = "table_occupations"
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    category_id: Mapped[int] = mapped_column(
        ForeignKey("table_occupation_categories.id"), nullable=False
    )
    category = relationship("OccupationCategoryModel", back_populates="occupations")
    