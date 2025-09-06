from . import Base, engine


# noinspection PyUnresolvedReferences
# from . import UserModel, UserProfileModel, OfferModel, NotificationModel, JobModel, CVModel


def init_db():
    Base.metadata.create_all(bind=engine)
