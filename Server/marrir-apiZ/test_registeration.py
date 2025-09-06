import pytest
from httpx import AsyncClient
from main import app  # Adjust if your app import is different
from unittest.mock import patch, MagicMock
import uuid
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from schemas.userschema import (
    UserCreateSchema,
    UserRoleSchema,
)

from main import app  # Adjust import to your FastAPI app
from models import UserModel
from repositories.user import UserRepository
from utils.send_email import send_email
from utils.generate_qr import generate_qr_code

valid_uuid = uuid.UUID("be75b312-1093-4e61-8eef-a84bb3377ef9")

@pytest.mark.asyncio
@patch("requests.post")
@patch("requests.get")
async def test_auth_google(mock_get, mock_post):
    # Mock Google's token endpoint response
    mock_post.return_value = MagicMock(
        status_code=200,
        json=lambda: {"access_token": "fake-access-token"}
    )
    # Mock Google's userinfo endpoint response
    mock_get.return_value = MagicMock(
        status_code=200,
        json=lambda: {
            "id": valid_uuid,
            "email": "muktarabdulmelik999@gmail.com",
            "verified_email": True,
            "name": "Test User",
            "given_name": "Test",
            "family_name": "User",
            "picture": "https://example.com/photo.jpg",
            "locale": "en"
        }
    )

    # Simulate a code received from Google OAuth
    payload = {"code": "fake-auth-code"}
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.post("/api/v1/user/auth/google", params=payload)
    assert response.status_code == 200
    data = response.json()
    # Adjust these assertions to match your user_tokens structure
    assert "access_token" in data
    assert "refresh_token" in data


'''

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def user_create_payload():
    return {
        "first_name": "John",
        "last_name": "Doe",
        "email": "john.doe@example445221.com",
        "phone_number": "+251941169889",
        "country": "USA",
        "password":  "StrongPassword123!",
        "role": "admin",
    }




@patch("core.context_vars.context_set_response_code_message", new_callable=MagicMock)
@patch("core.context_vars.context_actor_user_data", new_callable=MagicMock)
@patch("utils.generate_qr.generate_qr_code")
@patch("utils.send_email.send_email")
@patch("models.db.get_db_session")
def test_create_user_success(
    mock_get_db_session,
    mock_send_email,
    mock_generate_qr_code,
    mock_context_actor_user_data,
    mock_context_set_response_code_message, # This is the MagicMock object
    client,
    user_create_payload,
):
    mock_db = MagicMock()
    mock_get_db_session.return_value = mock_db
    mock_generate_qr_code.return_value = "fake_qr_code"

    # Directly set the return value for the 'get' method on the MagicMock
    mock_context_set_response_code_message.get.return_value = MagicMock(
        status_code=201, message="created", error=False
    )

    mock_context_actor_user_data.get.return_value = None
    mock_db.add.return_value = None
    mock_db.commit.return_value = None
    mock_db.refresh.return_value = None

    with patch.object(UserRepository, "create", return_value={"id": "fake-id", **user_create_payload}):
        response = client.post("/api/v1/user/", json=user_create_payload)

    assert response.status_code == 201
    data = response.json()
    assert data["status_code"] == 201
    assert data["message"] == "created"
    assert data["error"] is False
    assert data["data"]["email"] == user_create_payload["email"]


@patch("core.context_vars.context_set_response_code_message", new_callable=MagicMock) # This is the MagicMock object
def test_create_user_conflict(mock_context_set_response_code_message, client, user_create_payload): # Renamed to match the patch
    # Directly set the return value for the 'get' method on the MagicMock
    mock_context_set_response_code_message.get.return_value = MagicMock(
        status_code=409, message="User Already Exists!", error=True
    )

    with patch("models.db.get_db_session", return_value=MagicMock()), \
         patch.object(UserRepository, "create", return_value=None):
        response = client.post("/api/v1/user/", json=user_create_payload)

        # The assertion was correct, the issue was the mocked return value
        assert response.status_code == 409
        data = response.json()
        assert data["error"] is True
        assert data["message"] == "User Already Exists!"

'''

# In test_registeration.py
# In test_registeration.py

# Define a reusable mock for the object returned by context_set_response_code_message.get()
def create_context_res_data_mock(status_code, message, error):
    mock_res_data = MagicMock()
    mock_res_data.status_code = status_code
    mock_res_data.message = message
    mock_res_data.error = error
    return mock_res_data

# Define a reusable mock for the context_vars.ContextVar object itself
# This mock will simulate the behavior of a ContextVar for testing
def create_context_var_mock(default_value=None):
    mock_context_var = MagicMock()
    # Configure the get() method to return a specific mock object when called
    # We'll set the actual return_value in each test case
    mock_context_var.get.return_value = default_value # Default return value for get()

    # Mock the set() method if it's called by your application logic
    mock_context_var.set.return_value = None # Or whatever set() might return

    return mock_context_var


@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def user_create_payload():
    return {
        "first_name": "John",
        "last_name": "Doe",
        "email": "john.doe@example445221.com",
        "phone_number": "+251941169889", # Corrected phone number format
        "country": "USA",
        "password":  "StrongPassword123!",
        "role": "admin", # Or "EMPLOYEE" depending on which test case
    }


# Test case for successful user creation
@patch("core.context_vars.context_actor_user_data", new_callable=MagicMock)
@patch("utils.generate_qr.generate_qr_code")
@patch("utils.send_email.send_email")
@patch("models.db.get_db_session")
# Patch the core.context_vars.context_set_response_code_message name directly
@patch("core.context_vars.context_set_response_code_message", new_callable=create_context_var_mock)
def test_create_user_success(
    mock_context_set_response_code_message_var, # This is the mock ContextVar object
    mock_get_db_session,
    mock_send_email,
    mock_generate_qr_code,
    mock_context_actor_user_data,
    client,
    user_create_payload,
):
    mock_db = MagicMock()
    mock_get_db_session.return_value = mock_db
    mock_generate_qr_code.return_value = "fake_qr_code"

    # Configure the mock ContextVar's get() method to return the desired response data mock
    mock_context_set_response_code_message_var.get.return_value = create_context_res_data_mock(
        status_code=201, message="created", error=False
    )

    mock_context_actor_user_data.get.return_value = None
    mock_db.add.return_value = None
    mock_db.commit.return_value = None
    mock_db.refresh.return_value = None

    with patch.object(UserRepository, "create", return_value={"id": "fake-id", **user_create_payload}):
        response = client.post("/api/v1/user/", json=user_create_payload)

    assert response.status_code == 201
    data = response.json()
    assert data["status_code"] == 201
    assert data["message"] == "created"
    assert data["error"] is False
    assert data["data"]["email"] == user_create_payload["email"]


# Test case for user conflict
# Patch the core.context_vars.context_set_response_code_message name directly
@patch("core.context_vars.context_set_response_code_message", new_callable=create_context_var_mock)
def test_create_user_conflict(mock_context_set_response_code_message_var, client, user_create_payload): # Renamed
    # Configure the mock ContextVar's get() method to return the desired response data mock
    mock_context_set_response_code_message_var.get.return_value = create_context_res_data_mock(
        status_code=409, message="User Already Exists!", error=True
    )

    with patch("models.db.get_db_session", return_value=MagicMock()), \
         patch.object(UserRepository, "create", return_value=None):
        response = client.post("/api/v1/user/", json=user_create_payload)

        assert response.status_code == 409
        data = response.json()
        assert data["error"] is True
        assert data["message"] == "User Already Exists!"
