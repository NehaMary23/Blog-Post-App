#!/bin/bash
set -e

echo "Starting Laravel application..."

# Create .env directly
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

# Generate APP_KEY
echo "Generating APP_KEY..."
php artisan key:generate --force

# Ensure directories exist
mkdir -p storage/framework/sessions \
         storage/framework/views \
         storage/framework/cache \
         storage/logs \
         bootstrap/cache \
         database

chmod -R 775 storage bootstrap/cache

# Create SQLite database file
touch /app/database/database.sqlite

# Cache config AFTER key is generated
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Running migrations..."
php artisan migrate --force --no-interaction

php artisan package:discover --ansi || true

echo "Starting server..."
php artisan serve --host=0.0.0.0 --port=8000