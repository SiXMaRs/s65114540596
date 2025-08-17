#!/bin/sh
set -e

# ให้ Django เห็น settings เสมอ (แก้ชื่อให้ตรงโปรเจ็กต์ถ้าจำเป็น)
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-final.settings}"
export PYTHONUNBUFFERED=1

# รอ Postgres (psycopg v3 ให้ตรงกับ requirements)
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

# SEED + REHASH PASSWORDS อัตโนมัติ (Users + Products)
python - <<'PY'
import os, django, pathlib
os.environ.setdefault("DJANGO_SETTINGS_MODULE", os.getenv("DJANGO_SETTINGS_MODULE","final.settings"))
django.setup()

from django.core.management import call_command
from django.apps import apps

def exists(p): return pathlib.Path(p).is_file()

DEFAULT_EMAIL = os.getenv("DEFAULT_USER_EMAIL", "t1@test.co")
DEFAULT_PASS  = os.getenv("DEFAULT_USER_PASSWORD", "123456")

# --- Users ---
try:
    Users = apps.get_model('vfit','Users')

    # 1) โหลด user.yaml ถ้าจำเป็น (ยังไม่มีผู้ใช้ หรือยังไม่มีอีเมลนี้)
    need_user_seed = (Users.objects.count() == 0) or (not Users.objects.filter(email=DEFAULT_EMAIL).exists())
    if need_user_seed:
        for f in ["vfit/fixtures/user.yaml", "user.yaml"]:
            if exists(f):
                try:
                    call_command('loaddata', f, verbosity=0)
                    print("Loaded user fixture:", f)
                    break
                except Exception as e:
                    print("Skip user fixture:", f, "->", e)

    # 2) Rehash: ถ้าพบรหัสผ่านที่ยังเป็น plain-text (ไม่มี '$') ให้แฮชให้หมด
    updated = 0
    for u in Users.objects.all():
        if not u.password or "$" not in u.password:
            # ถ้าเป็นค่าว่าง ใช้ DEFAULT_PASS ช่วยป้องกันบัญชีที่ไม่มีรหัส
            raw = u.password or DEFAULT_PASS
            u.set_password(raw)
            u.save(update_fields=["password"])
            updated += 1
    print(f"Rehashed plain-text passwords: {updated}")

    # 3) Ensure default user: สร้างหรืออัปเดตผู้ใช้หลัก พร้อมตั้งรหัสผ่าน
    u, created = Users.objects.get_or_create(
        email=DEFAULT_EMAIL,
        defaults=dict(full_name="Test One", tel_number="0812345678",
                      sex="M", address="Demo Address", is_superuser=True),
    )
    u.set_password(DEFAULT_PASS)
    u.save()
    print(("Created" if created else "Updated"), "default user:", DEFAULT_EMAIL)

except Exception as e:
    print("Users seeding error:", e)

# --- Products/Exercise ---
try:
    Product = apps.get_model('vfit','Product')
    if Product.objects.count() == 0:
        for f in ["vfit/fixtures/products.yaml","vfit/fixtures/exercise.yaml","products.yaml","exercise.yaml"]:
            if exists(f):
                try:
                    call_command('loaddata', f, verbosity=0)
                    print("Loaded:", f)
                except Exception as e:
                    print("Skip fixture:", f, "->", e)
except Exception as e:
    print("Product fixtures error:", e)
PY

# รันเซิร์ฟเวอร์
exec python manage.py runserver 0.0.0.0:8000
