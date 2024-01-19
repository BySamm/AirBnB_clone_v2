#!/usr/bin/env bash
# Setup a web servers for the deployment of web_static.

#Check if nginx exists already

nginx_dir="/var/www/html"

if [ -d "$nginx_dir" ]; then
        echo "Nginx EXIST"
else
	echo "Nginx doesn't exist. Installing ..."
	sudo apt update -y
	sudo apt install -y ngnix
fi

mkdir -p /data
mkdir -p /data/web_static
mkdir -p /data/web_static/releases
mkdir -p /data/web_static/shared
mkdir -p /data/web_static/releases/test
echo "<!DOCTYPE html>
<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | tee /data/web_static/releases/test/index.html
sudo ln -sfn /data/web_static/releases/test/ /data/web_static/current
sudo chown -R ubuntu:ubuntu /data

# Check if the block is not already present before inserting it
if ! grep -q "location /hbnb_static {" /etc/nginx/sites-enabled/default; then
    sudo sed -i '6 i\\tlocation /hbnb_static {\n\t\talias /data/web_static/current;\n\t}\n' /etc/nginx/sites-enabled/default
fi
sudo service nginx restart
