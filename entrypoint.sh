#!/bin/sh
set -e

export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-final.settings}"
export PYTHONUNBUFFERED=1

# wait Postgres (psycopg v3)
python - <<'PY'
import os, time, sys
try:
    import psycopg
except ModuleNotFoundError:
    sys.exit("psycopg (v3) not installed. Ensure requirements has psycopg[binary].")
host='db'
port=int(os.getenv('POSTGRES_PORT','5432'))
user=os.getenv('POSTGRES_USER'); pwd=os.getenv('POSTGRES_PASSWORD'); db=os.getenv('POSTGRES_DB')
for _ in range(60):
    try:
        with psycopg.connect(host=host, port=port, user=user, password=pwd, dbname=db) as c:
            with c.cursor() as cur: cur.execute("SELECT 1")
        break
    except Exception:
        time.sleep(1)
else:
    sys.exit("Postgres not ready")
PY

# migrate + static
python manage.py makemigrations --noinput || true
python manage.py migrate --noinput
python manage.py collectstatic --noinput

# seed users (auto-hash) + fixtures
python - <<'PY'
import os, django, pathlib
os.environ.setdefault("DJANGO_SETTINGS_MODULE", os.getenv("DJANGO_SETTINGS_MODULE","final.settings"))
django.setup()
from django.core.management import call_command
from django.apps import apps

def exists(p): return pathlib.Path(p).is_file()

DEFAULT_EMAIL = os.getenv("DEFAULT_USER_EMAIL", "t1@test.co")
DEFAULT_PASS  = os.getenv("DEFAULT_USER_PASSWORD", "123456")

try:
    Users = apps.get_model('vfit','Users')
    # load user.yaml ถ้าจำเป็น
    if Users.objects.count()==0 or not Users.objects.filter(email=DEFAULT_EMAIL).exists():
        for f in ["vfit/fixtures/user.yaml","user.yaml"]:
            if exists(f):
                try:
                    call_command('loaddata', f, verbosity=0); print("Loaded user fixture:", f); break
                except Exception as e:
                    print("Skip user fixture:", f, "->", e)

    # rehash ถ้ายังเป็น plain-text
    updated = 0
    for u in Users.objects.all():
        if not u.password or "$" not in u.password:
            raw = u.password or DEFAULT_PASS
            u.set_password(raw); u.save(update_fields=["password"]); updated += 1
    print(f"Rehashed plain-text passwords: {updated}")

    # ensure default account
    u, created = Users.objects.get_or_create(
        email=DEFAULT_EMAIL,
        defaults=dict(full_name="Test One", tel_number="0812345678",
                      sex="M", address="Demo Address", is_superuser=True),
    )
    u.set_password(DEFAULT_PASS); u.save()
    print(("Created" if created else "Updated"), "default user:", DEFAULT_EMAIL)
except Exception as e:
    print("Users seeding error:", e)

# products/exercise (ถ้ายังว่าง)
try:
    Product = apps.get_model('vfit','Product')
    if Product.objects.count()==0:
        for f in ["vfit/fixtures/products.yaml","vfit/fixtures/exercise.yaml","products.yaml","exercise.yaml"]:
            if exists(f):
                try:
                    call_command('loaddata', f, verbosity=0); print("Loaded:", f)
                except Exception as e:
                    print("Skip fixture:", f, "->", e)
except Exception as e:
    print("Product fixtures error:", e)
PY

# run Gunicorn (no reverse proxy)
exec gunicorn final.wsgi:application --bind 0.0.0.0:8000 --workers ${GUNICORN_WORKERS:-3} --timeout ${GUNICORN_TIMEOUT:-60}
