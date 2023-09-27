#!/usr/bin/env sh

sed -i 's@$nginx@'"$NGINX_USER"'@' /etc/nginx/nginx.conf