#!/bin/sh
set -e

# ให้ Django เห็น settings เสมอ (แก้ชื่อให้ตรงโปรเจ็กต์ถ้าจำเป็น)
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-final.settings}"
export PYTHONUNBUFFERED=1

# รอ Postgres (ใช้ psycopg v3 ให้ตรงกับ requirements)
python - <<'PY'
import os, time, sys
try:
    import psycopg
except ModuleNotFoundError:
    sys.exit("psycopg (v3) not installed. Ensure requirements has psycopg[binary].")
host='db'
port=int(os.getenv('POSTGRES_PORT','5432'))
user=os.getenv('POSTGRES_USER')
pwd=os.getenv('POSTGRES_PASSWORD')
db=os.getenv('POSTGRES_DB')
for _ in range(60):
    try:
        with psycopg.connect(host=host, port=port, user=user, password=pwd, dbname=db) as conn:
            with conn.cursor() as cur: cur.execute("SELECT 1")
        break
    except Exception:
        time.sleep(1)
else:
    sys.exit("Postgres not ready")
PY

# migrate
python manage.py makemigrations --noinput || true
python manage.py migrate --noinput

# seed fixtures เฉพาะครั้งแรก และเรียก Django อย่างถูกต้อง
python - <<'PY'
import os, django, pathlib
os.environ.setdefault("DJANGO_SETTINGS_MODULE", os.getenv("DJANGO_SETTINGS_MODULE","final.settings"))
django.setup()
from django.core.management import call_command
from django.apps import apps

def exists(p): return pathlib.Path(p).is_file()

try:
    Product = apps.get_model('vfit','Product')
    need_seed = Product.objects.count() == 0
except Exception:
    need_seed = False

if need_seed:
    for f in ["vfit/fixtures/products.yaml","vfit/fixtures/exercise.yaml","vfit/fixtures/user.yaml","products.yaml","exercise.yaml","user.yaml"]:
        if exists(f):
            try:
                call_command('loaddata', f, verbosity=0)
                print("Loaded:", f)
            except Exception as e:
                print("Skip fixture:", f, "->", e)
PY

exec python manage.py runserver 0.0.0.0:8000
