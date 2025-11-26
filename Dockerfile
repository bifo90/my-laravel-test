FROM serversideup/php:8.4.1-fpm-nginx AS base

# Install any extensions...

FROM base AS build

COPY --chown=www-data:www-data . /var/www/html
USER www-data
# Run Composer...
RUN composer install --no-dev --prefer-dist --optimize-autoloader \
    && npm install \
    && npm run build

FROM base AS production

EXPOSE 8080
# Set env variables...
ENV PHP_OPCACHE_ENABLE=1
ENV AUTORUN_ENABLED="true"

COPY --chown=www-data:www-data --from=build /var/www/html /var/www/html
USER www-data
