#!/bin/sh

set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [[ "$role" = "app" ]]; then

    exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

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
