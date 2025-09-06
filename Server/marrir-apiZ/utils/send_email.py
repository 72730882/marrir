import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from core.security import Settings

settings = Settings()

def send_email(*, email: str, title: str, description: str) -> None:
    """Send an email."""
    try:
        context = ssl.create_default_context()

        message = MIMEMultipart("alternative")

        message["Subject"] = f"Marri - {title}"

        message["From"] = settings.EMAIL

        message["To"] = email

        text = f"""\
        Hi,
        {description}
        """

        html = f"""\
        <html>
        <body>
            <p>Hi,<br>
            {description}</strong>
            </p>
        </body>
        </html>
        """
        part1 = MIMEText(text, "plain")

        part2 = MIMEText(html, "html")

        message.attach(part1)

        message.attach(part2)

        with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
            server.login(settings.EMAIL, settings.APP_PASSWORD)

            server.sendmail(settings.EMAIL, email, message.as_string())
    except Exception as e:
        print(e)
