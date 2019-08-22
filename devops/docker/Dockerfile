#
# PHP dependencies - composer install
# Rebuilt if composer dependencies change
FROM php:7.3-cli-alpine as composer
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
FROM node:lts-alpine as yarn-install

WORKDIR /app

COPY package.json yarn.lock /app/

RUN yarn install

#
# JS build - yarn production
# Rebuilt if javascript source files change
FROM yarn-install as yarn-build

WORKDIR /app

RUN mkdir -p /app/public

COPY webpack.mix.js /app/
COPY resources/sass /app/resources/sass/
COPY resources/js /app/resources/js/

RUN yarn production

#
# PHP, Nginx and Supervisord configuration
# Rebuilt if configuration files change
FROM trafex/alpine-nginx-php7:1.2.0 as php-nginx
USER root
RUN apk add --no-cache php7-pcntl php7-bcmath php7-pdo php7-pdo_mysql php7-tokenizer
COPY ./devops/docker/config/nginx.conf /etc/nginx/nginx.conf

#
# Application
# Rebuilt if php source files change
FROM php-nginx

COPY ./devops/docker/entrypoint.sh /opt/bin/entrypoint.sh

RUN chmod +x /opt/bin/entrypoint.sh

CMD ["/opt/bin/entrypoint.sh"]

COPY . /var/www/html
COPY --from=composer vendor /var/www/html/vendor/
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY --from=yarn-build /app/public/js /var/www/html/public/js/
COPY --from=yarn-build /app/public/css /var/www/html/public/css/
COPY --from=yarn-build /app/mix-manifest.json /var/www/html/mix-manifest.json

RUN chown -R nobody:nobody /var/www/html/ \
    && composer dump-autoload --optimize --classmap-authoritative \
    && php artisan view:cache

USER nobody
