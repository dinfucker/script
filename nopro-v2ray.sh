#!/bin/bash

# ติดตั้ง Nginx
sudo apt update
sudo apt install -y nginx

# เริ่มบริการ Nginx
sudo systemctl start nginx

# ตั้งให้ Nginx เริ่มต้นทำงานทุกครั้งที่เปิดเครื่อง
sudo systemctl enable nginx

# เข้าไปที่ไดเร็กทอรีการกำหนดค่า Nginx
cd /etc/nginx/conf.d

# ถามเพื่อกำหนด server_name
read -p "ใส่ชื่อ โฮสเนมเราเช่น (xxx.com): " server_name

# สร้างหรือแก้ไขไฟล์ v2ray.conf ในไดเร็กทอรี /etc/nginx/conf.d/
sudo tee /etc/nginx/conf.d/v2ray.conf > /dev/null << EOL
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

# เริ่มให้บริการ V2Ray
sudo systemctl start v2ray

# เปิดใช้บริการ V2Ray
sudo systemctl enable v2ray

# เข้าไปที่ไดเร็กทอรีการกำหนดค่า V2Ray
cd /usr/local/etc/v2ray

# สร้าง UUID ใหม่
new_uuid=$(uuidgen)

# สร้างหรือแก้ไขไฟล์ config.json ด้วย UUID ใหม่
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
            "id": "$new_uuid",
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
EOL

# เข้ากลับไปที่ไดเร็กทอรีหลัก
cd

# รีสตาร์ท Nginx
sudo service nginx restart

# รีสตาร์ท v2ray
sudo service v2ray restart
