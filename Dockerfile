FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www/html

# Copy PHP configuration files
COPY /docker/php/php.ini "${PHP_INI_DIR}/conf.d/php.ini"
COPY /docker/php/opcache.ini "${PHP_INI_DIR}/conf.d/opcache.ini"
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

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

# Copy composer binary from official composer image
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy nginx configuration
COPY /docker/nginx/site.conf /etc/nginx/sites-available/default

# Add this to your Dockerfile
RUN mkdir -p /var/log/nexus && \
    chown -R www-data:www-data /var/log/nexus

# Copy supervisord configuration
COPY /docker/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy project files
COPY . /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Install Node.js dependencies and build assets
RUN npm install \
    && npm run build \
    && rm -rf node_modules

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Copy the pre-start script and make it executable
COPY /docker/start-web.sh /docker/start-web.sh
RUN chmod +x /docker/*.sh

# Expose port 80 for nginx
EXPOSE 80

# Start the application
CMD ["/docker/start-web.sh"]
