FROM serversideup/php:8.4.1-fpm-nginx AS base

# Install any extensions...

FROM base AS build

COPY --chown=www-data:www-data . /var/www/html
USER www-data
# Run Composer...
RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Install required system packages and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    git \
    unzip \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    gosu \
    curl \
    nodejs \
    npm \
    supervisor \
    cron \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo pdo_mysql mbstring zip gd bcmath pcntl intl exif opcache xml mysqli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM base AS production

# Set env variables...
ENV PHP_OPCACHE_ENABLE=1
ENV AUTORUN_ENABLED="true"

EXPOSE 80

COPY --chown=www-data:www-data --from=build /var/www/html /var/www/html
USER www-data
