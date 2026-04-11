#!/bin/bash
set -e

echo "Installing dependencies..."
composer install --no-interaction --optimize-autoloader --no-dev

echo "Generating application key..."
php artisan key:generate --force

echo "Running migrations..."
php artisan migrate --force

echo "Build complete!"
