#!/bin/bash

set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}
migrate=${DB_MIGRATE:-0}

if [[ "$role" = "app" ]]; then

    if [[ "$migrate" = "1" ]]; then
        php /var/www/html/artisan migrate --force
    fi
    docker-php-entrypoint apache2-foreground

elif [[ "$role" = "worker" ]]; then

    echo "Running the worker..."
    php /var/www/html/artisan horizon

elif [[ "$role" = "scheduler" ]]; then

    while [[ true ]]
    do
      php /var/www/html/artisan schedule:run --verbose --no-interaction &
      sleep 60
    done

else
    echo "Could not match the container role \"$role\""
    exit 1
fi
