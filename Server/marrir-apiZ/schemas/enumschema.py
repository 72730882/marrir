from enum import Enum, unique


@unique
class CheckoutTypeSchema(str, Enum):
    TRANSFER_REQUEST = "transfer_request"
    RESERVE_PROFILE = "reserve_profile"
    ANNUAL_SUBSCRIPTION = "annual_subscription"
    ACCEPT_EMPLOYEE_PROCESS = "accept_employee_process"
    ACCEPT_JOB_APPLICATION = "accept_job_application"
    PROFILE_PROMOTION = "profile_promotion"
    PROCESS_JOB_APPLICATION = "process_job_application"

    def __str__(self):
        return super().__str__()


@unique
class PaidStatusSchema(str, Enum):
    PAID = "paid"
    UNPAID = "unpaid"

    def __str__(self):
        return super().__str__()


@unique
class SexSchema(str, Enum):
    MALE = "male"
    FEMALE = "female"


@unique
class SkinToneSchema(str, Enum):
    VERY_LIGHT = "very_light"
    LIGHT = "light"
    MEDIUM = "medium"
    DARK = "dark"
    VERY_DARK = "very_dark"


@unique
class MaritalStatusSchema(str, Enum):
    SINGLE = "single"
    MARRIED = "married"
    DIVORCED = "divorced"
    WIDOWED = "widowed"
    SEPARATED = "separated"


@unique
class ReligionSchema(str, Enum):
    NONE = "none"
    CHURCH_OF_THE_EAST = "church_of_the_east"
    ORIENTAL_ORTHODOXY = "oriental_orthodoxy"
    EASTERN_ORTHODOXY = "eastern_orthodoxy"
    ROMAN_CATHOLICISM = "roman_catholicism"
    PROTESTANTISM = "protestantism"
    ISLAM = "islam"
    BUDDHISM = "buddhism"


@unique
class LanguageProficiencySchema(str, Enum):
    FLUENT = "fluent"
    INTERMEDIATE = "intermediate"
    BASIC = "basic"
    NONE = "none"


@unique
class JobTypeSchema(str, Enum):
    CONTRACTUAL = "contractual"
    TEMPORARY = "temporary"
    FULL_TIME = "full_time"
    RECRUITING_WORKER = "recruiting_worker"
    WORKER_TRANSPORT_SERVICE = "worker_transport_service"
    HIRING_WORKER = "hiring_worker"

    def __str__(self):
        return super().__str__()


@unique
class NotificationTypeSchema(str, Enum):
    INFO = "info"
    SUCCESS = "success"
    FAILURE = "failure"
    TRANSFER_REQUEST = "transfer_request"
    RESERVE_PROFILE = "reserve_profile"
    AGENT_ASSIGNMENT = "agent_assignment"
    OFFER = "offer"

    def __str__(self):
        return super().__str__()


@unique
class NotificationReceipentTypeSchema(str, Enum):
    ALL = "all"
    USER = "user"
    ADMIN = "admin"
    AGENT = "agent"
    EMPLOYEE = "employee"
    SPONSOR = "sponsor"
    RECRUITMENT = "recruitment"
    NONE = "none"

    def __str__(self):
        return super().__str__()


@unique
class OccupationTypeSchema(str, Enum):
    HOUSEKEEPER = "housekeeper"
    NANNY = "nanny"
    COFFEE_SERVANT = "coffee_servant"
    DRIVER = "driver"
    HOUSE_COOK = "house_cook"
    HOME_TAILOR = "home_tailor"
    PHYSIOTHERAPISTS = "physiotherapists"
    HOUSE_WAITER = "house_waiter"
    HOME_FARMER = "home_farmer"
    SPECIAL_SPEAKING_AND_HEARING_SPECIALIST = "special_speaking_and_hearing_specialist"
    HOUSE_BUTLER = "house_butler"
    HOUSE_MANAGER = "house_manager"
    HOME_GUARD = "home_guard"
    PERSONAL_HELPER = "personal_helper"
    HOUSE_NURSE = "house_nurse"
    OTHER = "other"

    def __str__(self):
        return super().__str__()


@unique
class OfferTypeSchema(str, Enum):
    ACCEPTED = "accepted"
    PENDING = "pending"
    DECLINED = "declined"

    def __str__(self):
        return super().__str__()


@unique
class PaymentTypeSchema(str, Enum):
    LOCAL = "local"
    INTERNATIONAL = "international"

    def __str__(self):
        return super().__str__()


@unique
class PaymentTypeSchema(str, Enum):
    LOCAL = "local"
    INTERNATIONAL = "international"

    def __str__(self):
        return super().__str__()


@unique
class PromotionPackageTypeSchema(str, Enum):
    ONE_MONTH = "1_month"
    THREE_MONTH = "3_months"
    SIX_MONTH = "6_months"
    TWELVE_MONTH = "12_months"

    def __str__(self):
        return super().__str__()


@unique
class RatingTypeSchema(str, Enum):
    ADMIN = "admin"
    TEST = "test"
    SPONSOR = "sponsor"

    def __str__(self):
        return super().__str__()


@unique
class RefundStatusSchema(str, Enum):
    SUCCESS = "success"
    FAILED = "failed"
    PENDING = "pending"

    def __str__(self):
        return super().__str__()


@unique
class TransferStatusSchema(str, Enum):
    ACCEPTED = "accepted"
    PENDING = "pending"
    DECLINED = "declined"
    CANCELLED = "cancelled"
    PAID = "paid"

    def __str__(self):
        return super().__str__()


@unique
class UserRoleSchema(str, Enum):
    ADMIN = "admin"
    AGENT = "agent"
    EMPLOYEE = "employee"
    SPONSOR = "sponsor"
    SELFSPONSOR = 'selfsponsor',
    RECRUITMENT = "recruitment"

    def __str__(self):
        return super().__str__()


@unique
class EducationStatusSchema(str, Enum):
    NO_EDUCATION = "no_education"
    PRIMARY_EDUCATION = "primary_education"
    SECONDARY_EDUCATION = "secondary_education"
    VOCATIONAL = "vocational"
    DIPLOMA = "diploma"
    SOME_COLLEGE_COURSES = "some_college_courses"
    BSC = "bsc"
    MSC = "msc"
    PHD = "phd"

    def __str__(self):
        return super().__str__()


@unique
class EmployeeStatusTypeSchema(str, Enum):
    STABLE = "stable"
    INCOMPETENCE = "incompetence"
    DISEASE = "disease"
    INJURY = "injury"
    DEATH = "death"
    ESCAPE = "escape"
    REFUSE_WORK = "refuse_work"
    CRIMINAL_CASE = "criminal_case"
    COMPLETE = "complete"
    INCOMPLETE = "incomplete"
    HOLD = "hold"
    OTHER = "other"

    def __str__(self):
        return super().__str__()


@unique
class StripePaymentStatusSchema(str, Enum):
    SUCCESS = "succeeded"
    PENDING = "pending"
    FAILED = "failed"


@unique
class ProcessStatusSchema(str, Enum):
    NOT_STARTED = "not_started"
    UNDER_PROCEDURE = "under_procedure"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
