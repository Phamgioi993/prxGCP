#!/bin/bash
apt update -y && apt upgrade -y
apt install -y dante-server

USER="proxy$(tr -dc a-z0-9 </dev/urandom | head -c6)"
PASS="$(tr -dc A-Za-z0-9 </dev/urandom | head -c10)"
PORT=$(shuf -i 10000-60000 -n 1)

useradd -M -s /usr/sbin/nologin "$USER"
echo "$USER:$PASS" | chpasswd

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

systemctl restart danted
systemctl enable danted

IP=$(curl -s ifconfig.me)
cat > /root/proxy-info.txt <<EOF
==============================
   SOCKS5 PROXY ĐÃ TẠO
==============================
IP: $IP
Port: $PORT
Username: $USER
Password: $PASS
Proxy URL: socks5://$USER:$PASS@$IP:$PORT
==============================
EOF

cat /root/proxy-info.txt
