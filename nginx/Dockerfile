# ใช้ base image ของ Nginx
FROM nginx:latest

# คัดลอกไฟล์ nginx.conf ที่แก้ไขแล้วเข้าไปใน container
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 สำหรับการเชื่อมต่อ
EXPOSE 80

# คำสั่งเริ่มต้นของ Nginx
CMD ["nginx", "-g", "daemon off;"]