#!/bin/bash

set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [[ "$role" = "app" ]]; then

    #check if socket exists
    FILE=/cloudsql/wonderkind-testing:europe-west4:development
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
    fi

    if [[ -f "/cloudsql/" ]]; then
        ls -la /cloudsql/
    else
        echo "/cloudsql/ does not exist"
    fi


    php /var/www/html/artisan migrate --force
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
