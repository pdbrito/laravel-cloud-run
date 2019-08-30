#!/usr/bin/with-contenv sh
set -e;

port=${PORT:-8080}
sed -i "s/\$PORT/$port/g" /etc/nginx/nginx.conf

/bin/wait-for-it.sh -t 2 127.0.0.1:9000

nginx -g "daemon off;"
