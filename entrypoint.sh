#!/bin/bash
set -e

echo "Starting Laravel application..."

# Ensure .env exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
fi

# Generate APP_KEY if not set
if ! grep -q "^APP_KEY=" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d= -f2)" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Ensure database directory exists
mkdir -p database
chmod -R 755 storage bootstrap/cache

# Run migrations
echo "Running migrations..."
php artisan migrate --force --no-interaction

# Run discovery
echo "Discovering packages..."
php artisan package:discover --ansi || true

echo "Starting server..."
php artisan serve --host=0.0.0.0 --port=8000
