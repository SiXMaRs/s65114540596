# Project_End

# Run ผ่าน docker 
1. ต้องติดตั้ง Docker บนเครื่องก่อน
ดาวน์โหลดและติดตั้ง Docker Desktop:
[🔗 Download Docker for Windows](https://www.docker.com/products/docker-desktop/)

2. Clone โปรเจกต์
เปิด Terminal หรือ Command Prompt แล้วพิมพ์คำสั่งนี้เพื่อ clone โปรเจกต์:

gh repo clone SiXMaRs/ST_65114540596

3. เข้าโฟลเดอร์โปรเจกต์
cd ST_65114540596/final
4. Run project ด้วย Docker Compose:
   
docker compose up --build

5. เข้าใช้งานระบบเปิด browser แล้วเข้า:
   
http://localhost:8000

---

# ถ้าอยากโคลนแล้วรันเองใช้อันนี้
* ลิงค์อ่านคู่มือ: https://docs.google.com/document/d/1OmLe5vo7JPqMDD_EwycapPnnmZwK6VxahHN9HjBnwvI/edit?usp=sharing *
---
เริ่มต้นโคลนอันนี้ไปสะ

- gh repo clone SiXMaRs/ST_65114540596

ถ้าไม่ได้มึงไปโหลดอันนี้สะ https://cli.github.com/

โคลนเสร็จมึงเข้าไปที่ cd ST_65114540596

เช็คว่ามีpython ไหมโดยคำสั่ง 

- python –version


ถ้าไม่มีpython ก็ไปโหลดก่อน https://www.python.org/downloads/

หรือมึงจะโหลดผ่าน scoop ก็ได้ ก่อนอื่นติดตั้ง scoop ด้วย

- Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

- Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression


แล้วก็โหลด python 

- scoop bucket add main

- scoop install main/python


โหลดเสร็จแล้วมึงก็สร้าง venv สะ ด้วยคำสั่ง 

- python -m venv venv 

สร้างเสร็จให้ activate venv จากคำสั่ง

- venv/scripts/activate


activate เสร็จให้เข้าไปที่ final โดย

- cd final


เมื่อเข้าไปแล้วให้ทำการโหลด

- pip install -r requirements.txt


ติดตั้ง mysql โดย https://dev.mysql.com/downloads/installer/

หรือโหลดใน extention vscod

![alt text](image.png)


โหลดเสร็จกดที่ไอคอนตามรูป กดcreate connection 

![alt text](image-1.png)


ตั้งค่าตามที่กำหนดไว้ในsetting  nameคือชื่อdatabase และ password 

![alt text](image-2.png)

![alt text](image-3.png)

ตั้งค่าเสร็จกด connect 


จากนั้นทำการ makemigrations และ migrate

- python manage.py makemigrations

- python manage.py migrate


ถ้าไม่ได้ให้ไปลบข้อมูลไมเกรทที่โฟลเดอร์ migrations ลบออกให้หมดเหลือไว้แค่ __init__

![alt text](image-4.png)


จากนั้นให้รันคำสั่งใหม่ 

- python manage.py makemigrations

- python manage.py migrate


เสร็จแล้วรันserver

python manage.py runserver


