#!/bin/bash
VERSION="1.8.1"
SOURCE="http://nginx.org/download/nginx-$VERSION.tar.gz"

PREFIX="/etc/nginx"
PID="/run/nginx.pid"
LOGS="/var/log/nginx/"
ERR_LOG="/var/log/nginx/error.log"
HTTP_LOG="/var/log/nginx/access.log"
CONF="/etc/nginx/nginx.conf"
SBIN="/sbin"
USER="www-data"
GROUP="www-data"
ARGS="--with-http_ssl_module --with-pcre-jit"

# To be used later on..
BASE_DIR=`pwd`

# Install deps
yum install -y openssl gzip httpd-devel pcre perl pcre-devel zlib zlib-devel

# Get source
mkdir "/tmp/nginx-install"
cd "/tmp/nginx-install"
wget $SOURCE
tar -zxf "nginx-$VERSION.tar.gz"
cd "nginx-$VERSION"

# Configure
./configure --prefix=$PREFIX --sbin-path=$SBIN --conf-path=$CONF --pid-path=$PID --error-log-path=$ERR_LOG --http-log-path=$HTTP_LOG --user=$USER --group=$GROUP $ARGS
sudo make install

if [ $? -ne 0 ]; then
    echo "Some error occured..."
    exit 1
fi

echo "##### Nginx Is Installed #####"
sudo rm -rf "/tmp/nginx-install"

# VServers & Conf file
sudo mkdir "$PREFIX/conf.d" "$PREFIX/sites-available" "$PREFIX/sites-enabled"
sudo cp $BASE_DIR/default "$PREFIX/sites-available"
cd "$PREFIX/sites-enabled" && sudo ln -s $BASE_DIR/default default

cd $BASE_DIR
sudo cp -rf nginx.conf /etc/nginx

# Setup Upstart init script.
sudo cp ./centos/nginx.service /lib/systemd/system/
