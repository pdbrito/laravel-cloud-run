#!/usr/bin/with-contenv sh
set -e;

# Start PHP-FPM
php-fpm -R --nodaemonize
