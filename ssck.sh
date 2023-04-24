#!/bin/bash

DEBUG=0

while getopts d:e:g flag
do
    case "${flag}" in
        'd') DOMAIN_NAME=${OPTARG};;
        'e') EMAIL=${OPTARG};;
        'g') DEBUG=1;;
    esac
done

if [ -z $DOMAIN_NAME ]; then
  echo "Usage: ssck.sh -d <domain> -e <email> -g -r"
  echo "domain: domain name. (Required)."
  echo "email: email address to renew certificate (Optional)."
  echo "Example: ssck.sh -d mahsa.WomanLifeFreedom.com -e someone@mail.com"
  echo "Use -g to debug script"
  exit
fi

function printlog() {
  if [ $DEBUG == 1 ]; then
    read -p "$1. Press Enter to continue..."
  else
    echo -e "$1"
  fi
}

function purge() {
   rm -rf /tmp/ssck
   rm -f ./prereq.sh
}

# Packages
printlog "Installing Prerequisites..."
apt-get -qq -y update
apt-get -qq -y install wget > /dev/null
purge

wget -q https://raw.githubusercontent.com/sapranik/shadowsocks-cloak/main/prereq.sh && chmod +x prereq.sh
./prereq.sh

# Configuration files
printlog "Downloading configuration files..."
VER="1.0.7"
mkdir -p /tmp/ssck
wget https://github.com/sapranik/shadowsocks-cloak/archive/refs/tags/$VER.zip -q -O /tmp/ssck/$VER.zip
unzip -q /tmp/ssck/$VER.zip -d /tmp/ssck/
mv /tmp/ssck/shadowsocks-cloak-$VER/** /tmp/ssck/
rm -rf /tmp/ssck/shadowsocks-cloak-$VER /tmp/ssck/$VER.zip

cd /tmp/ssck/config

# Nginx
if [ ! -f /etc/nginx/sites-available/ssck ]; then
  printlog "Configuring nginx..."
  rm -f /etc/nginx/sites-enabled/*
  rm -f /var/www/html/index.nginx-debian.html
  mv index.html /var/www/html/index.html
  mkdir -p /etc/nginx/sites-available-bak/
  if [ -f /etc/nginx/sites-available/default ]; then
    mv /etc/nginx/sites-available/default /etc/nginx/sites-available-bak/
  fi
  sed -i -e "s|# server_tokens off;|server_tokens off;|g" /etc/nginx/nginx.conf
  sed -i -e "s|varDomain|$DOMAIN_NAME|g" nginx.default
  mv nginx.default /etc/nginx/sites-available/ssck
  ln -s /etc/nginx/sites-available/ssck /etc/nginx/sites-enabled/
  systemctl restart nginx
fi

# SSL
printlog "Configuring SSL..."
if [ -z $EMAIL ]; then
  certbot --nginx -n -q -d $DOMAIN_NAME --register-unsafely-without-email --agree-tos --reinstall
else
  certbot --nginx -n -q -d $DOMAIN_NAME -m $EMAIL --agree-tos --reinstall
fi

sed -i "s|443 ssl|8443 ssl|g" /etc/nginx/sites-available/ssck
systemctl restart nginx

# Shadowsocks
printlog "Configuring Shadowsocks..."
wget -q https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.15.3/shadowsocks-v1.15.3.x86_64-unknown-linux-gnu.tar.xz -O /tmp/ssck/shadowsocks-rust.tar.xz
tar -C /usr/local/bin/ -xf /tmp/ssck/shadowsocks-rust.tar.xz

mkdir -p -m 755 /etc/shadowsocks
SS_PASS=$(tr -dc 'a-z' </dev/urandom | head -c8)
sed -i -e "s|varShadowsocksPass|$SS_PASS|g" shadowsocks.json
mv -u shadowsocks.json /etc/shadowsocks/config.json
mv -u shadowsocks.service /etc/systemd/system/shadowsocks.service

systemctl -q daemon-reload
systemctl -q enable shadowsocks
systemctl -q start shadowsocks

# Cloak
printlog "Configuring Cloak..."
wget https://github.com/cbeuw/Cloak/releases/download/v2.7.0/ck-server-linux-amd64-v2.7.0 -q
mv ck-server-linux-amd64-v2.7.0 /usr/local/bin/ck-server
chmod +x /usr/local/bin/ck-server
setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/ck-server

mkdir -p /etc/cloak
KEY=$(ck-server -k)
PUBLIC_KEY=$(echo $KEY | cut -d ',' -f 1)
PRIVATE_KEY=$(echo $KEY | cut -d ',' -f 2)
USER_UID=$(ck-server -u)
ADMIN_UID=$(ck-server -u)
sed -i -e "s|varUserUID|$USER_UID|g" -e "s|varAdminUID|$ADMIN_UID|g" -e "s|varPrivateKey|$PRIVATE_KEY|g" ckserver.json;
mv -u ckserver.json /etc/cloak/ckserver.json

mv -u cloak.service /usr/lib/systemd/system/cloak.service
systemctl -q enable cloak
systemctl -q start cloak

# BBR
printlog "Tuning and configuring BBR..."
mv -u 50-bbr.conf /etc/sysctl.d/50-bbr.conf
mv -u 60-ssck.conf /etc/sysctl.d/60-ssck.conf
sysctl -q -p

purge

echo "-------------------------"
echo "   Connection parameters:"
echo "   Shadowsocks password: $SS_PASS"
echo "   Cloak UserUID: $USER_UID"
echo "   Cloak PublicKey: $PUBLIC_KEY"
