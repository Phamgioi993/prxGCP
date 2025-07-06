#!/bin/bash

# --- CÀI ĐẶT DANTE PROXY SOCKS5 TỰ ĐỘNG ---

echo "[+] Cập nhật hệ thống..."
apt update -y && apt upgrade -y

echo "[+] Cài đặt dante-server..."
apt install -y dante-server

# --- TẠO USER & PORT NGẪU NHIÊN ---
USER="proxy$(tr -dc a-z0-9 </dev/urandom | head -c6)"
PASS="$(tr -dc A-Za-z0-9 </dev/urandom | head -c10)"
PORT=$(shuf -i 10000-60000 -n 1)

echo "[+] Tạo user $USER với pass ngẫu nhiên"
useradd -M -s /usr/sbin/nologin "$USER"
echo "$USER:$PASS" | chpasswd

# --- TẠO CẤU HÌNH DANTED ---
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: eth0 port = $PORT
external: eth0
method: username
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}
pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    method: username
    log: connect disconnect
}
EOF

# --- KHỞI ĐỘNG DỊCH VỤ ---
systemctl restart danted
systemctl enable danted

# --- LƯU THÔNG TIN PROXY ---
IP=$(curl -s ifconfig.me)
cat > /root/proxy-info.txt <<EOF
==============================
   SOCKS5 PROXY CREATED
==============================
IP: $IP
Port: $PORT
Username: $USER
Password: $PASS
Proxy URL: socks5://$USER:$PASS@$IP:$PORT
==============================
EOF

echo "[+] Proxy đã cài đặt. Kiểm tra tại: /root/proxy-info.txt"
