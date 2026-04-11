#!/bin/bash
set -e

echo "Starting Laravel application..."

# Create .env directly if not exists
if [ ! -f /app/.env ]; then
    echo "Creating .env file..."
    cat > /app/.env << 'EOF'
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=sqlite
DB_DATABASE=/app/database/database.sqlite

SESSION_DRIVER=file
SESSION_LIFETIME=120

CACHE_STORE=file
QUEUE_CONNECTION=sync

FILESYSTEM_DISK=local
MAIL_MAILER=log
EOF
fi

# Generate APP_KEY if empty
if ! grep -q "^APP_KEY=.\+" /app/.env; then
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

# Create SQLite database file
if [ ! -f /app/database/database.sqlite ]; then
    echo "Creating SQLite database..."
    touch /app/database/database.sqlite
fi

php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Running migrations..."
php artisan migrate --force --no-interaction

php artisan package:discover --ansi || true

echo "Starting server..."
php artisan serve --host=0.0.0.0 --port=8000
