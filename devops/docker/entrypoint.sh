#!/bin/bash

set -e

php /var/www/html/artisan migrate --force
docker-php-entrypoint apache2-foreground
