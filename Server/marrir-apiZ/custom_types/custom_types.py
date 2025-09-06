from typing import Annotated

from pydantic import AfterValidator


def password_validator(password):
    password = str(password)
    """
    Validates that the password is at least 8 characters long,
    contains at least one uppercase letter, one lowercase letter,
    one number, and one special character.
    """
    special_chars = {'!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '+', '='}
    if len(password) < 8:
        raise ValueError('password must be at least 8 characters long')
    if not any(char.isupper() for char in password):
        raise ValueError('password must contain at least one uppercase letter')
    if not any(char.islower() for char in password):
        raise ValueError('password must contain at least one lowercase letter')
    if not any(char.isdigit() for char in password):
        raise ValueError('password must contain at least one number')
    if not any(char in special_chars for char in password):
        raise ValueError('password must contain at least one special character')
    return password


Password = Annotated[str, AfterValidator(password_validator)]
