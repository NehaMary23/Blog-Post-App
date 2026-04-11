#!/bin/bash
set -e

echo "Starting Laravel application..."

# Ensure .env exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
fi

# Generate APP_KEY if not set or empty
if ! grep -q "^APP_KEY=.\+" .env; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Ensure directories exist
mkdir -p storage/framework/sessions \
         storage/framework/views \
         storage/framework/cache \
         storage/logs \
         bootstrap/cache \
         database

chmod -R 775 storage bootstrap/cache

# Create SQLite database file if not exists
if [ ! -f /app/database/database.sqlite ]; then
    echo "Creating SQLite database..."
    touch /app/database/database.sqlite
fi

# Set correct SQLite path in .env
sed -i 's|DB_DATABASE=.*|DB_DATABASE=/app/database/database.sqlite|' .env

# Cache config
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
echo "Running migrations..."
php artisan migrate --force --no-interaction

# Run discovery
echo "Discovering packages..."
php artisan package:discover --ansi || true

echo "Starting server..."
php artisan serve --host=0.0.0.0 --port=8000