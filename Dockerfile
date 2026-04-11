FROM php:8.3-fpm

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    zip \
    unzip \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# Create database directory and file
RUN mkdir -p database && touch database/database.sqlite

# Generate application key if not exists
RUN if [ ! -f .env ]; then cp .env.example .env; fi
RUN php artisan key:generate

# Expose port
EXPOSE 8000

# Run migrations and start server
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
