from datetime import datetime

from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.util import hybridproperty

from logger import logger


class EntityBaseModel:
    __abstract__ = True
    id: Mapped[int] = mapped_column(primary_key=True, index=True, autoincrement=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(default=None, onupdate=datetime.utcnow, nullable=True)
    deleted_at: Mapped[datetime] = mapped_column(default=None, nullable=True)

    def get_owner(self):
        if hasattr(self, 'email'):
            return self.email
        elif hasattr(self, 'created_by'):
            return self.created_by
        else:
            logger.error('resource does not have an owner')
            raise Exception('resource does not have an owner')

    @hybridproperty
    def is_deleted(self):
        return self.deleted_at is not None

    @staticmethod
    def get_resource_name(name: str | None):
        try:
            assert type(name) is str
            name = name.split('Model')[0]
            assert len(name) > 0
            return name.lower()
        except Exception:
            return 'entity'
