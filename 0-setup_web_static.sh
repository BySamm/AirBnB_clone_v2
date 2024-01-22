#!/usr/bin/env bash
# Setup a web servers for the deployment of web_static.

#Check if nginx exists already

nginx_dir="/var/www/html"

if [ -d "$nginx_dir" ]; then
        echo "Nginx EXIST"
else
	echo "Nginx doesn't exist. Installing ..."

        #  updates the package lists for available software packages.
        sudo apt-get update -y
        # installs the Nginx web server.
        sudo apt-get install -y nginx
        # starting nginx service
        sudo service nginx start
        # allowing nginx on firewall
        sudo ufw allow 'Nginx HTTP'
        # Give the user ownership to website files for easy editing
        sudo chown -R "$USER":"$USER" /var/www/html
        sudo chmod -R 755 /var/www

        # Backup default index
        cp /var/www/html/index.nginx-debian.html /var/www/html/index.nginx-debian.html.bckp

        #  sets the content of the index.html file to "Hello World!" using the echo command.
        echo "Hello World!" > /var/www/html/index.nginx-debian.html

        # Sets Nginx to listen on port 80 and serve files from the default directory.
        printf %s "server {
                listen      80;
                listen      [::]:80 default_server;
                root        /var/www/html;
                index       index.nginx-debian.html index.html index.htm;
        }
        " > /etc/nginx/sites-enabled/default
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
