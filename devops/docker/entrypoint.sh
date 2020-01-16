#!/bin/sh
set -euxo pipefail

env=${APP_ENV:-production}
migrate=${DB_MIGRATE:-0}

sed -i "s/\$PORT/$port/g" /etc/nginx/nginx.conf

PID_FILE=/tmp/php-fpm.pid
php-fpm -g $PID_FILE -D
while [ ! -f $PID_FILE ]; do sleep 0.1; done
nginx -g 'daemon off;'
