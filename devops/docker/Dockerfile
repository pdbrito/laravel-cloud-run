#
# PHP dependencies - composer install
# Rebuilt if composer dependencies change
FROM php:7.3-cli-alpine AS composer-deps
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer global require hirak/prestissimo

COPY database database/

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --no-dev

#
# JS dependencies - yarn install
# Rebuilt if javascript dependencies change
FROM node:lts-alpine AS yarn-install

WORKDIR /app

COPY package.json yarn.lock /app/

RUN yarn install

#
# JS build - yarn production
# Rebuilt if javascript source files change
FROM yarn-install AS yarn-build

WORKDIR /app

RUN mkdir -p /app/public

COPY webpack.mix.js /app/
COPY resources/sass /app/resources/sass/
COPY resources/js /app/resources/js/

RUN yarn production

#
# PHP, Nginx and Supervisord configuration
# Rebuilt if configuration files change
FROM php:7.3-fpm-alpine AS php-nginx

RUN docker-php-ext-install bcmath pcntl pdo pdo_mysql opcache

RUN apk --no-cache add nginx supervisor fcgi

# Configure supervisord
COPY ./devops/docker/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure nginx
COPY ./devops/docker/config/nginx.conf /etc/nginx/nginx.conf

# Configure php-fpm
COPY ./devops/docker/config/www.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Configure php
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Configure opcache
COPY ./devops/docker/config/opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


#
# Docker entrypoint
# Rebuilt if our entrypoint script changes
FROM php-nginx as entrypoint
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY ./devops/docker/scripts/entrypoint.sh /opt/bin/entrypoint.sh

RUN chmod +x /opt/bin/entrypoint.sh /opt/bin/healthcheck.sh

RUN chmod +x /opt/bin/entrypoint.sh
CMD ["/opt/bin/entrypoint.sh"]


#
# Application
# Rebuilt if php source files change
FROM entrypoint as application

COPY . /var/www/html
COPY --from=composer-deps vendor /var/www/html/vendor/
COPY --from=yarn-build /app/public/js /var/www/html/public/js/
COPY --from=yarn-build /app/public/css /var/www/html/public/css/
COPY --from=yarn-build /app/mix-manifest.json /var/www/html/mix-manifest.json

RUN composer dump-autoload --optimize --classmap-authoritative --verbose \
    && chown -R www-data /var/www/html/storage/
