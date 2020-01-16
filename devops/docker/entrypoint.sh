#!/bin/sh

set -e

env=${APP_ENV:-production}
port=${PORT:-8080}

sed -i "s/\$PORT/$port/g" /etc/nginx/nginx.conf
exec /init
