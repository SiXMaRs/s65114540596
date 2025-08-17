FROM python:3.12
WORKDIR /app

COPY requirements.txt /app/
RUN python -m pip install --upgrade pip setuptools wheel \
 && pip install --no-cache-dir -r requirements.txt

COPY . /app/

# ไม่ต้องพึ่งสิทธิ์ execute บน Windows: เรียกผ่าน sh โดยตรง
CMD ["sh", "-c", "/bin/sh entrypoint.sh"]
