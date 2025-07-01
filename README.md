# Project_End

เริ่มต้นโคลนอันนี้ไปสะ

gh repo clone SiXMaRs/ST_65114540596


โคลนเสร็จมึงเข้าไปที่ cd ST_65114540596

เช็คว่ามีpython ไหมโดยคำสั่ง 

python –version


ถ้าไม่มีpython ก็ไปโหลดก่อน https://www.python.org/downloads/

หรือมึงจะโหลดผ่าน scoop ก็ได้ ก่อนอื่นติดตั้ง scoop ด้วย

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression


แล้วก็โหลด python 

scoop bucket add main

scoop install main/python


โหลดเสร็จแล้วมึงก็สร้าง venv สะ ด้วยคำสั่ง 

python -m venv venv 

สร้างเสร็จให้ activate venv จากคำสั่ง

venv/scripts/activate


activate เสร็จให้เข้าไปที่ final โดย

cd final


เมื่อเข้าไปแล้วให้ทำการโหลด

pip install -r requirements.txt


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

python manage.py makemigrations

python manage.py migrate


ถ้าไม่ได้ให้ไปลบข้อมูลไมเกรทที่โฟลเดอร์ migrations ลบออกให้หมดเหลือไว้แค่ __init__

![alt text](image-4.png)


จากนั้นให้รันคำสั่งใหม่ 

python manage.py makemigrations

python manage.py migrate


เสร็จแล้วรันserver

python manage.py runserver


