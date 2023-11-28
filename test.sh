#!/bin/bash

# ติดตั้ง Nginx
sudo apt update
sudo apt install -y nginx

# เริ่มบริการ Nginx
sudo systemctl start nginx

# ตั้งให้ Nginx เริ่มต้นทำงานทุกครั้งที่เปิดเครื่อง
sudo systemctl enable nginx

# ย้ายไปที่ไดเรกทอรีการกำหนดค่าของ nginx
cd /etc/nginx/conf.d

# สร้างหรือแก้ไขไฟล์ v2ray.conf โดยใช้ nano เป็นตัวแก้ไขข้อความ
nano v2ray.conf

# เพิ่มส่วนถาม server_name ก่อนที่จะเพิ่มคอนฟิกูเรชัน
read -p "กรุณากรอก server_name: " user_server_name

# เพิ่มคอนฟิกูเรชันต่อไปนี้ลงใน v2ray.conf
server {
  listen 80;
  server_name $user_server_name;

  index index.html;
  root /usr/share/nginx/html/;

  access_log /var/log/nginx/v2ray.access;
  error_log /var/log/nginx/v2ray.error;

  location /ray {
    if ($http_upgrade != "websocket") {
      return 404;
    }
    proxy_redirect off;
    proxy_pass http://127.0.0.1:11112;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}

# บันทึกและปิดไฟล์
# สามารถใช้ Ctrl + X, จากนั้นกด Y เพื่อยืนยันการบันทึก, และ Enter
# ย้ายกลับไปที่โฮมไดเรกทอรี
cd

# ตรวจสอบสถานะของ UFW
sudo ufw status numbered

# ติดตั้ง curl
sudo apt install curl

# ดาวน์โหลดสคริปต์การติดตั้ง V2Ray
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh

# รันสคริปต์การติดตั้ง V2Ray
sudo bash install-release.sh

# ย้ายไปที่ไดเรกทอรีการกำหนดค่าของ V2Ray
cd /usr/local/etc/v2ray

# สร้างหรือแก้ไขไฟล์ config.json โดยใช้ nano เป็นตัวแก้ไขข้อความ
nano config.json

# เพิ่มคอนฟิกูเรชันต่อไปนี้ลงใน config.json
{
  "inbounds": [
    {
      "port": 11112,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "fc82b95e-7ea1-4e55-b2b4-e431056aa94a",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/ray"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}

# ย้ายกลับไปที่โฮมไดเรกทอรี
cd

# เปิดให้บริการ V2Ray ทำงานทันทีเมื่อเริ่มเครื่อง
sudo systemctl enable v2ray

# เริ่มให้บริการ V2Ray
sudo systemctl start v2ray

# รีสตาร์ท nginx
sudo service nginx restart


