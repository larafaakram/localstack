FROM python:3.12.10

COPY . . 

RUN pip install --upgrade pip
RUN pip3 install -r requirements.txt

cmd gunicorn --bind 0.0.0.0:5000 wsgi:app