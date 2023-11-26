#!/bin/bash

# อัพเดตรายการแพ็คเกจ
sudo apt-get update

# ติดตั้ง Nginx
sudo apt install nginx

# เข้าไปที่ไดเร็กทอรีการกำหนดค่า Nginx
cd /etc/nginx/conf.d

# ถามเพื่อกำหนด server_name
read -p "Enter your desired server_name (e.g., example.com): " server_name

# สร้างหรือแก้ไขไฟล์ v2ray.conf
sudo tee v2ray.conf > /dev/null << EOL
server {
  listen 80;
  server_name $server_name;

  index index.html;
  root /usr/share/nginx/html/;

  access_log /var/log/nginx/v2ray.access;
  error_log /var/log/nginx/v2ray.error;

  location /ray {
    if (\$http_upgrade != "websocket") {
      return 404;
    }
    proxy_redirect off;
    proxy_pass http://127.0.0.1:11112;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }
}
EOL

# เข้ากลับไปที่ไดเร็กทอรีหลัก
cd

# ตรวจสอบสถานะ UFW
sudo ufw status numbered

# ติดตั้ง curl
sudo apt install curl

# ดาวน์โหลดสคริปต์ติดตั้ง V2Ray
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh

# รันสคริปต์ติดตั้ง V2Ray
sudo bash install-release.sh

# เข้าไปที่ไดเร็กทอรีการกำหนดค่า V2Ray
cd /usr/local/etc/v2ray

# ถามเพื่อกำหนด server_name
read -p "Enter your desired server_name (e.g., example.com): " server_name

# สร้างหรือแก้ไขไฟล์ config.json
sudo tee config.json > /dev/null << EOL
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
