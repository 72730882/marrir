from datetime import timedelta
import json
from operator import and_, or_
from sqlalchemy.orm import Session
from faker import Faker
import random

from models.addressmodel import AddressModel
from models.batchreservemodel import BatchReserveModel
from models.batchtransfermodel import BatchTransferModel
from models.companyinfomodel import CompanyInfoModel
from models.cvmodel import CVModel
from models.educationmodel import EducationModel
from models.employeemodel import EmployeeModel
from models.jobmodel import JobModel
from models.notificationmodel import NotificationModel
from models.occupationmodel import OccupationModel
from models.promotionmodel import PromotionPackagesModel
from models.referencemodel import ReferenceModel
from models.reservemodel import ReserveModel
from models.servicemodel import ServiceModel
from models.transferrequestmodel import TransferRequestModel
from models.usermodel import UserModel
from models.userprofilemodel import UserProfileModel
from models.workexperiencemodel import WorkExperienceModel
from repositories.companyinfo import CompanyInfoRepository
from repositories.notification import NotificationRepository
from repositories.occupation import OccupationRepository
from repositories.service import ServiceRepository
from repositories.user import UserRepository
from schemas.companyinfoschema import CompanyInfoUpsertSchema
from schemas.cvschema import (
    LanguageProficiencySchema,
    MaritalStatusSchema,
    ReligionSchema,
    SkinToneSchema,
)
from schemas.jobschema import JobCreateSchema, JobTypeSchema
from schemas.notificationschema import (
    NotificationCreateSchema,
    NotificationReceipentTypeSchema,
    NotificationTypeSchema,
)
from schemas.occupationSchema import (
    OccupationCategoryCreateSchema,
    OccupationCreateSchema,
    OccupationTypeSchema,
)
from schemas.serviceschema import ServiceCreateSchema
from schemas.userschema import EducationStatusSchema, UserCreateSchema, UserRoleSchema
from pydantic_extra_types.phone_numbers import PhoneNumber

from utils.generate_qr import generate_qr_code

faker = Faker()
roles = [
    UserRoleSchema.EMPLOYEE,
    UserRoleSchema.SPONSOR,
    UserRoleSchema.RECRUITMENT,
    UserRoleSchema.AGENT,
]
education_levels = [
    EducationStatusSchema.NO_EDUCATION,
    EducationStatusSchema.PRIMARY_EDUCATION,
    EducationStatusSchema.SECONDARY_EDUCATION,
    EducationStatusSchema.VOCATIONAL,
    EducationStatusSchema.DIPLOMA,
    EducationStatusSchema.SOME_COLLEGE_COURSES,
    EducationStatusSchema.BSC,
    EducationStatusSchema.MSC,
    EducationStatusSchema.PHD,
]
job_types = [
    JobTypeSchema.CONTRACTUAL,
    JobTypeSchema.FULL_TIME,
    JobTypeSchema.TEMPORARY,
    JobTypeSchema.RECRUITING_WORKER,
    JobTypeSchema.WORKER_TRANSPORT_SERVICE,
    JobTypeSchema.HIRING_WORKER,
]
skin_tones = [
    SkinToneSchema.VERY_LIGHT,
    SkinToneSchema.LIGHT,
    SkinToneSchema.MEDIUM,
    SkinToneSchema.DARK,
    SkinToneSchema.VERY_DARK,
]
religions = [
    ReligionSchema.NONE,
    ReligionSchema.CHURCH_OF_THE_EAST,
    ReligionSchema.ORIENTAL_ORTHODOXY,
    ReligionSchema.EASTERN_ORTHODOXY,
    ReligionSchema.ROMAN_CATHOLICISM,
    ReligionSchema.PROTESTANTISM,
    ReligionSchema.ISLAM,
    ReligionSchema.BUDDHISM,
]
marital_statuses = [
    MaritalStatusSchema.SINGLE,
    MaritalStatusSchema.MARRIED,
    MaritalStatusSchema.SEPARATED,
    MaritalStatusSchema.DIVORCED,
    MaritalStatusSchema.WIDOWED,
]
jobs = [
    OccupationTypeSchema.COFFEE_SERVANT,
    OccupationTypeSchema.DRIVER,
    OccupationTypeSchema.HOUSE_NURSE,
    OccupationTypeSchema.NANNY,
]
occupations = {
    "Non-Graduate": [
        "Housekeeper",
        "Nanny",
        "Coffee Servant",
        "Driver",
        "House Cook",
        "Home Tailor",
        "Physiotherapists",
        "House Waiter",
        "Home Farmer",
        "Special Speaking and Hearing Specialist",
        "House Butler",
        "House Manager",
        "Home Guard",
        "Personal Helper",
        "House Nurse",
    ],
    "Healthcare and Medicine": [
        "Doctor",
        "Nurse",
        "Pharmacist",
        "Medical Technician",
    ],
    "Information Technology": [
        "Software Developer",
        "Cybersecurity Specialist",
        "Network Engineer",
        "Data Scientist",
    ],
    "Engineering": [
        "Civil Engineer",
        "Mechanical Engineer",
        "Electrical Engineer",
        "Chemical Engineer",
        "Aerospace Engineer",
    ],
    "Education": [
        "Teacher",
        "Professor",
        "Educational Administrator",
        "School Counselor",
    ],
    "Finance and Accounting": [
        "Accountant",
        "Financial Analyst",
        "Investment Banker",
        "Auditor",
    ],
    "Arts and Entertainment": [
        "Actor",
        "Musician",
        "Writer",
        "Graphic Designer",
    ],
    "Business and Management": [
        "Marketing Manager",
        "Human Resources Specialist",
        "Business Analyst",
        "Project Manager",
    ],
    "Law and Public Policy": [
        "Lawyer",
        "Paralegal",
        "Policy Analyst",
        "Government Official",
    ],
    "Science and Research": [
        "Biologist",
        "Chemist",
        "Physicist",
        "Environmental Scientist",
    ],
    "Construction and Skilled Trades": [
        "Carpenter",
        "Electrician",
        "Plumber",
        "Welder",
    ],
    "Hospitality and Tourism": [
        "Hotel Manager",
        "Travel Agent",
        "Event Planner",
        "Chef",
    ],
    "Sales and Marketing": [
        "Sales Representative",
        "Marketing Coordinator",
        "Market Research Analyst",
        "Public Relations Specialist",
    ],
    "Transportation and Logistics": [
        "Truck Driver",
        "Logistics Coordinator",
        "Pilot",
        "Supply Chain Manager",
    ],
    "Agriculture and Environmental Services": [
        "Farmer",
        "Agricultural Technician",
        "Environmental Consultant",
        "Conservation Scientist",
    ],
}
proficiency = [
    LanguageProficiencySchema.NONE,
    LanguageProficiencySchema.BASIC,
    LanguageProficiencySchema.INTERMEDIATE,
    LanguageProficiencySchema.FLUENT,
]

countries = ["Kenya", "Ethiopia", "Sudan", "Saudi Arabia", "Egypt"]

phone_numbers = [
    PhoneNumber("+251912345670"),
    PhoneNumber("+251912345671"),
    PhoneNumber("+251912345672"),
    PhoneNumber("+251912345673"),
    PhoneNumber("+251912345674"),
    PhoneNumber("+251912345675"),
    PhoneNumber("+251912345676"),
    PhoneNumber("+251912345677"),
    PhoneNumber("+251912345678"),
    PhoneNumber("+251912345679"),
    PhoneNumber("+251912345680"),
    PhoneNumber("+251912345681"),
    PhoneNumber("+251912345682"),
    PhoneNumber("+251912345683"),
    PhoneNumber("+251912345684"),
]

user_repo = UserRepository(UserModel)
service_repo = ServiceRepository(ServiceModel)
notification_repo = NotificationRepository(NotificationModel)


class UniqueRandom:
    def __init__(self, list):
        self.ids = list
        random.shuffle(self.ids)

    def get_random(self):
        try:
            return self.ids.pop()
        except IndexError:
            raise Exception("No more ids available.")


def seed_users(db: Session, number_of_rows: int = 10):
    for i in range(number_of_rows):
        user_data = UserCreateSchema(
            first_name=faker.first_name(),
            last_name=faker.last_name(),
            email=faker.email(),
            country=faker.random_element(elements=countries),
            phone_number=phone_numbers[i],
            password="Password@1",
            role=faker.random_element(elements=roles),
        )

        user_repo.create(db, obj_in=user_data)

    employee = UserCreateSchema(
        first_name="Employee",
        last_name="Employee",
        email="employee@example.com",
        country=faker.random_element(elements=countries),
        phone_number="+251929394943",
        password="Employee123#",
        role=UserRoleSchema.EMPLOYEE,
    )

    sponsor = UserCreateSchema(
        first_name="Sponsor",
        last_name="Sponsor",
        email="sponsor@example.com",
        country=faker.random_element(elements=countries),
        phone_number="+251929394945",
        password="Sponsor123#",
        role=UserRoleSchema.SPONSOR,
    )
    agent = UserCreateSchema(
        first_name="Agent",
        last_name="Agent",
        email="agent@example.com",
        country=faker.random_element(elements=countries),
        phone_number="+251929394947",
        password="Agent123#",
        role=UserRoleSchema.AGENT,
    )
    recruitment = UserCreateSchema(
        first_name="Recruitment",
        last_name="Recruitment",
        email="recruitment@example.com",
        country=faker.random_element(elements=countries),
        phone_number="+251929394949",
        password="Recruitment123#",
        role=UserRoleSchema.RECRUITMENT,
    )
    admin = UserCreateSchema(
        first_name="Admin",
        last_name="Admin",
        email="admin@example.com",
        country=faker.random_element(elements=countries),
        phone_number="+251929394951",
        password="Admin123#",
        role=UserRoleSchema.ADMIN,
    )
    user_repo.create(db, obj_in=employee)
    user_repo.create(db, obj_in=agent)
    user_repo.create(db, obj_in=recruitment)
    user_repo.create(db, obj_in=sponsor)
    user_repo.create(db, obj_in=admin)


def seed_company(db: Session):
    companies = []
    non_employees_and_admins = (
        db.query(UserModel)
        .filter(
            and_(
                UserModel.role != UserRoleSchema.EMPLOYEE,
                UserModel.role != UserRoleSchema.ADMIN,
            )
        )
        .all()
    )

    for i in range(len(non_employees_and_admins)):
        company = CompanyInfoModel(
            alternative_email=faker.email(),
            alternative_phone=faker.phone_number(),
            company_name=faker.company(),
            location=faker.name(),
            user_id=non_employees_and_admins[i].id,
            year_established=faker.year(),
            company_logo="images/Logo.jpg",
        )

        companies.append(company)

    db.add_all(companies)
    db.commit()


def seed_services(db: Session):
    transfer = ServiceCreateSchema(
        name="Transfer Profile",
        description="Transfer Profile Payment",
        amount=1,
        recurring=False,
    )
    reserve = ServiceCreateSchema(
        name="Reserve Profile",
        description="Reserve Profile Payment",
        amount=10,
        recurring=False,
    )

    promote = ServiceCreateSchema(
        name="Promote Profile",
        description="Profile Promotion Payment",
        amount=10,
        recurring=False,
    )

    agent_accept = ServiceCreateSchema(
        name="Accept Employee Process Fee",
        description="Agent Accept Employee Process Payment",
        amount=1,
        recurring=False,
    )

    service_repo.create(db, obj_in=transfer)
    service_repo.create(db, obj_in=reserve)
    service_repo.create(db, obj_in=promote)
    service_repo.create(db, obj_in=agent_accept)


def seed_jobs(db: Session):
    jobs_local = []
    sponsors_recruitments = (
        db.query(UserModel)
        .filter(
            or_(
                UserModel.role == UserRoleSchema.SPONSOR,
                UserModel.role == UserRoleSchema.RECRUITMENT,
            )
        )
        .all()
    )

    for i in range(len(sponsors_recruitments)):
        job = JobModel(
            name=faker.job(),
            description=faker.text(max_nb_chars=50),
            location=faker.city(),
            education_status=faker.random_element(elements=education_levels),
            occupation=faker.random_element(elements=jobs),
            amount=faker.random_int(min=1, max=10),
            type=faker.random_element(elements=job_types),
            posted_by=sponsors_recruitments[i].id,
            is_open=random.choice([True, False]),
        )

        jobs_local.append(job)
    db.add_all(jobs_local)
    db.commit()


def seed_occupations(db: Session):
    occupation_repo = OccupationRepository(OccupationModel)

    for key, value in occupations.items():
        obj_in = OccupationCategoryCreateSchema(name=key)
        category = occupation_repo.create_category(db, obj_in=obj_in)
        for occuption in value:
            occ_obj_in = OccupationCreateSchema(name=occuption, category_id=category.id)
            occupation_repo.create(db, obj_in=occ_obj_in)


def seed_cvs(db: Session):
    employee = db.query(UserModel).filter_by(email="employee@example.com").first()

    random_category_name = faker.random_element(elements=list(occupations.keys()))
    random_occupation = faker.random_element(elements=occupations[random_category_name])

    cv = CVModel(
        passport_number=faker.unique.bothify(text="??########"),
        user_id=employee.id,
        email="employee@example.com",
        national_id=faker.unique.bothify(text="##########"),
        english_full_name="Employee Employee",
        amharic_full_name="ኢምፕሎዪ ኢምፕሎዪ",
        arabic_full_name="إمبلويي إمبلويي",
        sex=faker.random_element(elements=["male", "female"]),
        phone_number="+251929394943",
        height=faker.random_int(min=150, max=180),
        weight=faker.random_int(min=50, max=80),
        skin_tone=faker.random_element(elements=skin_tones),
        date_of_birth=str(faker.date_of_birth(minimum_age=18, maximum_age=65)),
        place_of_birth=faker.country_code(representation="alpha-3"),
        nationality=faker.country_code(representation="alpha-3"),
        religion=faker.random_element(elements=religions),
        marital_status=faker.random_element(elements=marital_statuses),
        number_of_children=faker.random_int(min=0, max=5),
        occupation_category=random_category_name,
        occupation=random_occupation,
        amharic=faker.random_element(elements=proficiency),
        arabic=faker.random_element(elements=proficiency),
        english=faker.random_element(elements=proficiency),
        head_photo="images/Profile.jpeg",
        full_body_photo="images/FullBody.jpeg",
        facebook=faker.url(),
        x=faker.url(),
        telegram=faker.url(),
        tiktok=faker.url(),
    )

    db.add(cv)
    db.commit()

    address = AddressModel(
        country=faker.country(),
        region=faker.state(),
        city=faker.city(),
        street3=faker.text(max_nb_chars=10),
        street2=faker.text(max_nb_chars=10),
        zip_code=faker.zipcode(),
        street1=faker.text(max_nb_chars=10),
        house_no=faker.numerify(text="##A"),
        po_box=faker.random_int(min=1000, max=9999),
        street=faker.street_address(),
    )

    education = EducationModel(
        cv_id=cv.id,
        highest_level=faker.random_element(elements=education_levels),
        institution_name=faker.company(),
        country=faker.country(),
        city=faker.city(),
        grade=faker.random_element(elements=["A", "B", "C", "D", "F"]),
    )

    start_date = faker.date_object()

    work = WorkExperienceModel(
        cv_id=cv.id,
        company_name=faker.company(),
        country=faker.country(),
        city=faker.city(),
        start_date=start_date,
        end_date=start_date + timedelta(days=faker.random_int(min=50, max=2000)),
    )

    reference = ReferenceModel(
        cv_id=cv.id,
        name=faker.name(),
        phone_number=faker.phone_number(),
        email=faker.email(),
        birth_date=str(faker.date_of_birth(minimum_age=18, maximum_age=65)),
        gender=faker.random_element(elements=["male", "female"]),
        country=faker.country(),
        city=faker.city(),
        sub_city=faker.text(max_nb_chars=10),
        zone=faker.text(max_nb_chars=10),
        po_box=faker.random_int(min=1000, max=9999),
        house_no=faker.numerify(text="##A"),
    )

    db.add(education)
    db.add(work)
    db.add(reference)
    db.add(address)
    db.commit()
    cv.address_id = address.id
    db.commit()


def seed_user_managed_employees(db: Session):
    non_employees_and_admins = (
        db.query(UserModel)
        .filter(
            and_(
                UserModel.role != UserRoleSchema.EMPLOYEE,
                UserModel.role != UserRoleSchema.ADMIN,
            )
        )
        .all()
    )

    for i in range(len(non_employees_and_admins)):
        for j in range(10):
            random_category_name = faker.random_element(
                elements=list(occupations.keys())
            )
            random_occupation = faker.random_element(
                elements=occupations[random_category_name]
            )

            cv = CVModel(
                passport_number=faker.unique.bothify(text="??########"),
                nationality=faker.country_code(representation="alpha-3"),
                english_full_name=faker.name(),
                sex=faker.random_element(elements=["male", "female"]),
                date_of_birth=str(faker.date_of_birth(minimum_age=18, maximum_age=65)),
                height=faker.random_int(min=150, max=180),
                weight=faker.random_int(min=50, max=80),
                occupation_category=random_category_name,
                occupation=random_occupation,
                religion=faker.random_element(elements=religions),
                marital_status=faker.random_element(elements=marital_statuses),
                amharic=faker.random_element(elements=proficiency),
                arabic=faker.random_element(elements=proficiency),
                english=faker.random_element(elements=proficiency),
            )

            db.add(cv)
            db.commit()

            education = EducationModel(
                cv_id=cv.id,
                highest_level=faker.random_element(elements=education_levels),
            )

            db.add(education)
            db.commit

            new_user = UserModel()
            new_user.role = UserRoleSchema.EMPLOYEE
            db.add(new_user)
            db.commit()
            cv.user_id = new_user.id
            qr_code_data = generate_qr_code(new_user.id)
            new_user_profile = UserProfileModel(
                user_id=new_user.id, qr_code=qr_code_data
            )
            employee = EmployeeModel(
                user_id=new_user.id,
                manager_id=non_employees_and_admins[i].id,
            )

            db.add(new_user_profile)
            db.add(employee)
            db.commit()


def seed_transfers(db: Session):
    sponsor_ids = (
        db.query(UserModel.id).filter(UserModel.role == UserRoleSchema.SPONSOR).all()
    )
    agent_ids = (
        db.query(UserModel.id).filter(UserModel.role == UserRoleSchema.AGENT).all()
    )
    recru_ids = (
        db.query(UserModel.id)
        .filter(UserModel.role == UserRoleSchema.RECRUITMENT)
        .all()
    )

    sponsor = (
        db.query(UserModel).filter(UserModel.email == "sponsor@example.com").first()
    )
    agent = db.query(UserModel).filter(UserModel.email == "agent@example.com").first()
    recru = (
        db.query(UserModel).filter(UserModel.email == "recruitment@example.com").first()
    )

    sponsor_employee_ids = (
        db.query(EmployeeModel.user_id).filter_by(manager_id=sponsor.id).all()
    )
    agent_employee_ids = (
        db.query(EmployeeModel.user_id).filter_by(manager_id=agent.id).all()
    )
    recru_employee_ids = (
        db.query(EmployeeModel.user_id).filter_by(manager_id=recru.id).all()
    )

    for i in range(min(3, len(sponsor_ids))):
        id = sponsor_ids[i]
        if id[0] != sponsor.id:
            batch_transfer = BatchTransferModel(
                receiver_id=id[0], requester_id=sponsor.id
            )
            db.add(batch_transfer)
            transfers = []
            unique_random_sponsor = UniqueRandom(sponsor_employee_ids)
            for i in range(3):
                single_transfer_request = TransferRequestModel(
                    requester_id=sponsor.id,
                    user_id=unique_random_sponsor.get_random()[0],
                    manager_id=id[0],
                )
                transfers.append(single_transfer_request)
            db.commit()
            for transfer in transfers:
                transfer.batch_id = batch_transfer.id
                db.add(transfer)
                db.commit()
                db.refresh(transfer)
            notification = NotificationCreateSchema(
                receipent_ids=[id[0]],
                description=f"There has been a transfer request made by {sponsor.email} for {len(transfers)} employee(s). Check the transfer page for more details",
                title="Transfer Request",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.TRANSFER_REQUEST,
                type_metadata=f"{batch_transfer.id}",
            )
            notification_repo.send(db, notification)

    for i in range(min(3, len(agent_ids))):
        id = agent_ids[i]
        if id[0] != agent.id:
            batch_transfer = BatchTransferModel(
                receiver_id=id[0], requester_id=agent.id
            )
            db.add(batch_transfer)
            transfers = []
            unique_random_agent = UniqueRandom(agent_employee_ids)
            for i in range(3):
                single_transfer_request = TransferRequestModel(
                    requester_id=sponsor.id,
                    user_id=unique_random_agent.get_random()[0],
                    manager_id=id[0],
                )
                transfers.append(single_transfer_request)

            db.commit()
            for transfer in transfers:
                transfer.batch_id = batch_transfer.id
                db.add(transfer)
                db.commit()
                db.refresh(transfer)
            notification = NotificationCreateSchema(
                receipent_ids=[id[0]],
                description=f"There has been a transfer request made by {agent.email} for {len(transfers)} employee(s). Check the transfer page for more details",
                title="Transfer Request",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.TRANSFER_REQUEST,
                type_metadata=f"{batch_transfer.id}",
            )
            notification_repo.send(db, notification)

    for i in range(min(3, len(recru_ids))):
        id = recru_ids[i]
        if id[0] != recru.id:
            batch_transfer = BatchTransferModel(
                receiver_id=id[0], requester_id=recru.id
            )
            db.add(batch_transfer)
            transfers = []
            unique_random_recru = UniqueRandom(recru_employee_ids)
            for i in range(3):
                single_transfer_request = TransferRequestModel(
                    requester_id=recru.id,
                    user_id=unique_random_recru.get_random()[0],
                    manager_id=id[0],
                )
                transfers.append(single_transfer_request)
            db.commit()
            for transfer in transfers:
                transfer.batch_id = batch_transfer.id
                db.add(transfer)
                db.commit()
                db.refresh(transfer)
            notification = NotificationCreateSchema(
                receipent_ids=[id[0]],
                description=f"There has been a transfer request made by {recru.email} for {len(transfers)} employee(s). Check the transfer page for more details",
                title="Transfer Request",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.TRANSFER_REQUEST,
                type_metadata=f"{batch_transfer.id}",
            )
            notification_repo.send(db, notification)

    transfer_requests = db.query(TransferRequestModel).all()
    for request in transfer_requests:
        request.status = "accepted"
        notification = NotificationCreateSchema(
            receipent_ids=[request.requester_id],
            description=f"Your transfer request for user {request.user_id} has been {request.status}",
            title="Transfer Request Response",
            receipent_type=NotificationReceipentTypeSchema.NONE,
            type=NotificationTypeSchema.SUCCESS,
        )
        notification_repo.send(db, notification)


def seed_reserves(db: Session):
    sponsor = (
        db.query(UserModel).filter(UserModel.email == "sponsor@example.com").first()
    )
    agent = db.query(UserModel).filter(UserModel.email == "agent@example.com").first()
    recru = (
        db.query(UserModel).filter(UserModel.email == "recruitment@example.com").first()
    )

    employee_ids_sponsor = (
        db.query(EmployeeModel.user_id)
        .filter(EmployeeModel.manager_id != sponsor.id)
        .all()
    )
    employee_ids_agent = (
        db.query(EmployeeModel.user_id)
        .filter(EmployeeModel.manager_id != agent.id)
        .all()
    )
    employee_ids_recru = (
        db.query(EmployeeModel.user_id)
        .filter(EmployeeModel.manager_id != recru.id)
        .all()
    )

    unique_random_sponsor = UniqueRandom(employee_ids_sponsor)
    unique_random_agent = UniqueRandom(employee_ids_agent)
    unique_random_recru = UniqueRandom(employee_ids_recru)

    batch_reserve_sponsor = BatchReserveModel(reserver_id=sponsor.id)
    batch_reserve_agent = BatchReserveModel(reserver_id=agent.id)
    batch_reserve_recru = BatchReserveModel(reserver_id=recru.id)

    sponsor_reserves = []
    agent_reserves = []
    recru_reserves = []

    for i in range(3):
        id = unique_random_sponsor.get_random()
        cv = db.query(CVModel).filter_by(user_id=id[0]).first()
        if not cv:
            continue
        single_reserve = ReserveModel(cv_id=cv.id, reserver_id=sponsor.id)
        employee = db.query(EmployeeModel.manager_id).filter_by(user_id=id[0]).first()
        sponsor_reserves.append(single_reserve)

    db.add(batch_reserve_sponsor)
    db.commit()

    notification = NotificationCreateSchema(
        receipent_ids=[employee[0]],
        description=f"There has been a reserve request made by {sponsor.email} for {len(sponsor_reserves)} employee(s). Check the reserve page for more details",
        title="Reservation Request",
        receipent_type=NotificationReceipentTypeSchema.NONE,
        type=NotificationTypeSchema.RESERVE_PROFILE,
        type_metadata=f"{batch_reserve_sponsor.id}",
    )
    notification_repo.send(db, notification)

    for reserve in sponsor_reserves:
        reserve.batch_id = batch_reserve_sponsor.id
        db.add(reserve)
        db.commit()
        db.refresh(reserve)

    for i in range(3):
        id = unique_random_agent.get_random()
        cv = db.query(CVModel).filter_by(user_id=id[0]).first()
        if not cv:
            continue
        single_reserve = ReserveModel(cv_id=cv.id, reserver_id=agent.id)
        employee = db.query(EmployeeModel.manager_id).filter_by(user_id=id[0]).first()

        agent_reserves.append(single_reserve)

    db.add(batch_reserve_agent)
    db.commit()

    notification = NotificationCreateSchema(
        receipent_ids=[employee[0]],
        description=f"There has been a reserve request made by {agent.email} for {len(agent_reserves)} employee(s). Check the reserve page for more details",
        title="Reservation Request",
        receipent_type=NotificationReceipentTypeSchema.NONE,
        type=NotificationTypeSchema.RESERVE_PROFILE,
        type_metadata=f"{batch_reserve_agent.id}",
    )
    notification_repo.send(db, notification)

    for reserve in agent_reserves:
        reserve.batch_id = batch_reserve_agent.id
        db.add(reserve)
        db.commit()
        db.refresh(reserve)

    for i in range(3):
        id = unique_random_recru.get_random()
        cv = db.query(CVModel).filter_by(user_id=id[0]).first()
        if not cv:
            continue
        single_reserve = ReserveModel(cv_id=cv.id, reserver_id=recru.id)
        employee = db.query(EmployeeModel.manager_id).filter_by(user_id=id[0]).first()
        recru_reserves.append(single_reserve)

    db.add(batch_reserve_recru)
    db.commit()

    notification = NotificationCreateSchema(
        receipent_ids=[employee[0]],
        description=f"There has been a reserve request made by {recru.email} for {len(recru_reserves)} employee(s). Check the reserve page for more details",
        title="Reservation Request",
        receipent_type=NotificationReceipentTypeSchema.NONE,
        type=NotificationTypeSchema.RESERVE_PROFILE,
        type_metadata=f"{batch_reserve_recru.id}",
    )
    notification_repo.send(db, notification)

    for reserve in recru_reserves:
        reserve.batch_id = batch_reserve_recru.id
        db.add(reserve)
        db.commit()
        db.refresh(reserve)

    reserve_requests = db.query(ReserveModel).all()

    for request in reserve_requests:
        request.status = "accepted"
        if request.status == "accepted":
            notification = NotificationCreateSchema(
                receipent_ids=[request.reserver_id],
                description="You can start the travel process",
                title="Reserve Request Accepted",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.SUCCESS,
            )

def seed_promotion_package(db: Session):
    package = db.query(PromotionPackagesModel).all()

    if not package:
        promotion_packages = [
            PromotionPackagesModel(
                category="promotion",
                role="employee",
                duration="ONE_MONTH",
                profile_count=1,
                price=91.825
            ),
            PromotionPackagesModel(
                category="promotion",
                role="employee",
                duration="THREE_MONTHS",
                profile_count=1,
                price=183.65
            ),
            PromotionPackagesModel(
                category="promotion",
                role="agent",
                duration="ONE_MONTH",
                profile_count=49,
                price=91.825
            ),
            PromotionPackagesModel(
                category="promotion",
                role="agent",
                duration="THREE_MONTHS",
                profile_count=149,
                price=73.46
            ),
            PromotionPackagesModel(
                category="promotion",
                role="agent",
                duration="TWELVE_MONTHS",
                profile_count=500,
                price=44.076
            ),
            PromotionPackagesModel(
                category="promotion",
                role="sponsor",
                duration="ONE_MONTH",
                profile_count=49,
                price=91.825
            ),
            PromotionPackagesModel(
                category="promotion",
                role="sponsor",
                duration="THREE_MONTHS",
                profile_count=149,
                price=73.46
            ),
            PromotionPackagesModel(
                category="promotion",
                role="sponsor",
                duration="TWELVE_MONTHS",
                profile_count=500,
                price=44.076
            ),
            PromotionPackagesModel(
                category="promotion",
                role="recruitment",
                duration="ONE_MONTH",
                profile_count=49,
                price=91.825
            ),
            PromotionPackagesModel(
                category="promotion",
                role="recruitment",
                duration="THREE_MONTHS",
                profile_count=149,
                price=73.46
            ),
            PromotionPackagesModel(
                category="promotion",
                role="recruitment",
                duration="TWELVE_MONTHS",
                profile_count=500,
                price=44.076
            ),
            PromotionPackagesModel(
                category="transfer",
                role="agent",
                price=3.673
            ),
            PromotionPackagesModel(
                category="transfer",
                role="sponsor",
                price=3.673
            ),
            PromotionPackagesModel(
                category="transfer",
                role="recruitment",
                price=3.673
            ),
            PromotionPackagesModel(
                category="reservation",
                role="agent",
                price=183.65
            ),
            PromotionPackagesModel(
                category="reservation",
                role="sponsor",
                price=183.65
            ),
            PromotionPackagesModel(
                category="reservation",
                role="recruitment",
                price=183.65
            ),
            PromotionPackagesModel(
                category="employee_process",
                role="recruitment",
                price=367.3
            ),
            PromotionPackagesModel(
                category="job_application",
                role="recruitment",
                price=10
            ),
            PromotionPackagesModel(
                category="job_application",
                role="sponsor",
                price=10
            ),                
        ]

        db.add_all(promotion_packages)

        try:
            db.commit()
        except Exception as e:
            db.rollback()
            print(e)
            print("Error in seeding promotion packages")