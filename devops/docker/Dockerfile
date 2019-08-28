#
# PHP, Nginx and Supervisord configuration
# Rebuilt if configuration files change
FROM php:7.3-apache-stretch

RUN apt-get -y update && apt-get -y install git zlib1g-dev libzip-dev && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer global require hirak/prestissimo

RUN docker-php-ext-install bcmath pcntl pdo pdo_mysql opcache zip

RUN sed -i 's#/var/www/html#/var/www/html/public#g' /etc/apache2/sites-available/000-default.conf

#Allow listen port to be confiured at runtime with PORT env variable
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

# Configure php
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Configure opcache
COPY ./devops/docker/config/opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

WORKDIR /var/www/html

COPY ./devops/docker/entrypoint.sh /opt/bin/entrypoint.sh

RUN chmod +x /opt/bin/entrypoint.sh

CMD ["/opt/bin/entrypoint.sh"]

COPY . /var/www/html

RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader --classmap-authoritative \
    && chown -R www-data /var/www/html/storage/
