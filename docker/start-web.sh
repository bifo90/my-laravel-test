#!/bin/sh

# Enable fail-fast to stop the script on any error
set -e

if [ -f /var/www/html/docker/pre-start-container.sh ]; then
  sh /var/www/html/docker/pre-start-container.sh
fi

php artisan migrate --force

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
