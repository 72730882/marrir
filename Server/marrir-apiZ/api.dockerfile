FROM python:latest
WORKDIR /app
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . /app
EXPOSE 8001:8000
CMD ["python", "-u", "main.py"]