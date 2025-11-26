#!/bin/sh

# Enable fail-fast to stop the script on any error
set -e

php artisan vendor:publish --force --tag=livewire:assets

php artisan optimize
php artisan view:cache
