FROM python:3.12

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

WORKDIR /app

CMD ["sh", "-c", "python manage.py migrate && python manage.py loaddata products.yaml && python manage.py loaddata exercise.yaml && python manage.py runserver 0.0.0.0:8000"]