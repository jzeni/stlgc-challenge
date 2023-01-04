FROM python:3.8

WORKDIR /home/microservice

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python", "-u", "/home/microservice/main.py"]
