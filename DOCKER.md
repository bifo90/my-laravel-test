# Docker Deployment Guide

This Laravel 12 application is configured for Docker deployment based on the DDEV configuration (PHP 8.3, nginx-fpm).

## Quick Start

### Build and Run with Docker Compose

```bash
# Build the image
docker-compose build

# Start all services (app, database, redis)
docker-compose up -d

# Run migrations
docker-compose exec app php artisan migrate --force

# Generate application key (if needed)
docker-compose exec app php artisan key:generate

# Access the application
open http://localhost:8080
```

### Build and Run with Docker Only

```bash
# Build the image
docker build -t laravel-app .

# Run the container
docker run -d \
  -p 8080:80 \
  --name laravel-app \
  -e APP_ENV=production \
  -e APP_KEY=your-app-key-here \
  laravel-app
```

## Configuration

### Environment Variables

The container accepts all standard Laravel environment variables. Key variables:

-   `APP_ENV` - Application environment (production, staging, etc.)
-   `APP_KEY` - Application encryption key
-   `APP_DEBUG` - Debug mode (false for production)
-   `DB_CONNECTION` - Database connection type
-   `DB_HOST` - Database host
-   `DB_DATABASE` - Database name
-   `DB_USERNAME` - Database username
-   `DB_PASSWORD` - Database password
-   `CACHE_STORE` - Cache driver
-   `QUEUE_CONNECTION` - Queue connection
-   `SESSION_DRIVER` - Session driver
-   `REDIS_HOST` - Redis host

### Volumes

For persistent storage, mount these volumes:

```bash
docker run -d \
  -v $(pwd)/storage:/var/www/html/storage \
  -v $(pwd)/.env:/var/www/html/.env \
  laravel-app
```

## Production Deployment

### Before Deployment

1. Set `APP_ENV=production` and `APP_DEBUG=false`
2. Generate a secure `APP_KEY` using `php artisan key:generate`
3. Configure your database connection
4. Set up proper cache and session drivers (Redis recommended)
5. Configure email settings

### Running Migrations

```bash
docker-compose exec app php artisan migrate --force
```

### Cache Optimization

```bash
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
```

### Clearing Cache

```bash
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
```

## Services Included

The Docker image includes:

-   **nginx** - Web server (port 80)
-   **php-fpm** - PHP 8.3 FastCGI Process Manager
-   **supervisor** - Process manager for services
-   **queue worker** - Laravel queue processor

All services are managed by Supervisor and start automatically.

## Health Checks

The container includes a health check that runs every 30 seconds:

```bash
docker inspect --format='{{json .State.Health}}' laravel-app
```

## Logs

View logs from all services:

```bash
# All logs
docker-compose logs -f

# Application logs only
docker-compose logs -f app

# Nginx logs
docker-compose exec app tail -f /dev/stderr

# Laravel logs
docker-compose exec app tail -f /var/www/html/storage/logs/laravel.log

# Queue worker logs
docker-compose exec app tail -f /var/www/html/storage/logs/worker.log
```

## Troubleshooting

### Permission Issues

If you encounter permission issues with storage:

```bash
docker-compose exec app chmod -R 775 storage bootstrap/cache
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
```

### Rebuild After Code Changes

```bash
docker-compose build --no-cache
docker-compose up -d
```

### Enter Container Shell

```bash
docker-compose exec app sh
```

## Performance Optimization

The image is optimized for production with:

-   Multi-stage build to minimize image size
-   OPcache enabled with JIT compilation
-   Composer autoloader optimization
-   Gzip compression
-   Static asset caching
-   Dedicated queue worker process

## Database

The `docker-compose.yml` includes MariaDB 10.11 matching your DDEV configuration.

### Connect to Database

```bash
docker-compose exec db mysql -u laravel -psecret laravel
```

### Database Backups

```bash
docker-compose exec db mysqldump -u laravel -psecret laravel > backup.sql
```

### Restore Database

```bash
docker-compose exec -T db mysql -u laravel -psecret laravel < backup.sql
```

## Redis

Redis is included for caching, sessions, and queues.

### Connect to Redis

```bash
docker-compose exec redis redis-cli
```

## Scaling

To run multiple queue workers:

Edit `docker/supervisor/supervisord.conf` and change `numprocs`:

```ini
[program:queue-worker]
numprocs=4  # Run 4 workers
```

## Security Notes

1. Change default database passwords in production
2. Use secrets management for sensitive environment variables
3. Keep the image updated with security patches
4. Use HTTPS with a reverse proxy (nginx, Traefik, etc.)
5. Implement rate limiting and DDoS protection

## Differences from DDEV

This Docker setup provides a production-ready container, while DDEV is for development:

-   Single container vs multiple services
-   Optimized for production performance
-   No development tools included
-   Smaller image size
-   Built-in process management with Supervisor

For development, continue using DDEV. Use this Docker setup for staging/production deployments.
