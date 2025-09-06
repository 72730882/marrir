from sqlalchemy.orm import Session
from sqlalchemy import func, extract, Column, desc
from typing import List, Optional, Any

from repositories.base import EntityType


def get_aggregated_stats(
    db: Session,
    date_column: Column,
    period: str,
    filters: Optional[List[Any]] = None,
    value_column: Optional[Column] = None,
    join_conditions: Optional[List[Any]] = None
) -> EntityType | None:
    query = db.query(extract("year", date_column).label("year"))
    
    if join_conditions:
        for join_model, join_condition in join_conditions:
            query = query.join(join_model, join_condition)

    if filters:
        for condition in filters:
            query = query.filter(condition)

    if period == "monthly":
        query = query.add_columns(
            extract("month", date_column).label("month")
        ).group_by(
            extract("year", date_column),
            extract("month", date_column)
        ).order_by(
            desc(extract("year", date_column)), 
            desc(extract("month", date_column))
        )


    elif period == "quarterly":
        query = query.add_columns(
            func.ceil(extract("month", date_column) / 3).label("quarter")
        ).group_by("year", "quarter")
    elif period == "yearly":
        query = query.group_by("year")

    if value_column:
        query = query.add_columns(func.sum(value_column).label("total_value"))
    else:
        query = query.add_columns(func.count().label("total_value"))

    results = query.all()

    if not results:
        return {"value": 0, "change": None}

    aggregated_values = [result[-1] for result in results]
    current_value = aggregated_values[0]
    change = None

    if len(aggregated_values) > 1:
        previous_value = aggregated_values[1]
        if previous_value != 0:
            change = round(((current_value - previous_value) / previous_value) * 100)

    return {"value": current_value, "change": change}
