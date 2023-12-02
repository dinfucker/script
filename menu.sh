#!/bin/bash

# สร้างไฟล์เก็บ UUID
uuid_file="uuid_list.txt"

# ฟังก์ชันสำหรับเพิ่ม UUID
add_uuid() {
    new_uuid=$(uuidgen)
    echo "$new_uuid" >> "$uuid_file"
}

# ฟังก์ชันสำหรับแสดงเมนู
show_menu() {
    choice=$(whiptail --title "เมนูเพิ่ม UUID" --menu "กรุณาเลือกทำการ" 15 60 4 \
        "1" "เพิ่ม UUID" \
        "2" "แสดง UUID ทั้งหมด" \
        "3" "ออก" 3>&1 1>&2 2>&3)

    case $choice in
        1)
            add_uuid
            whiptail --title "เพิ่ม UUID" --msgbox "UUID ถูกเพิ่มเรียบร้อยแล้ว" 8 40
            show_menu
            ;;
        2)
            uuid_list=$(cat "$uuid_file" 2>/dev/null)
            whiptail --title "UUID ทั้งหมด" --msgbox "UUID ทั้งหมด:\n\n$uuid_list" 15 60
            show_menu
            ;;
        3)
            exit
            ;;
    esac
}

# ตรวจสอบว่าไฟล์ UUID มีหรือไม่
if [ ! -e "$uuid_file" ]; then
    touch "$uuid_file"
fi

# เรียกใช้งานเมนู
show_menu
