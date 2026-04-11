FROM php:8.3-cli

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    zip \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Set permissions BEFORE composer install
RUN mkdir -p storage/framework/sessions \
             storage/framework/views \
             storage/framework/cache \
             storage/logs \
             bootstrap/cache \
             database \
    && chmod -R 775 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Run migrations and start server
CMD sh -c "if [ ! -f .env ]; then \
    if [ -f .env.example ]; then \
      cp .env.example .env; \
    else \
      echo 'APP_NAME=Laravel' > .env; \
      echo 'APP_ENV=production' >> .env; \
      echo 'APP_DEBUG=false' >> .env; \
      echo 'DB_CONNECTION=sqlite' >> .env; \
      echo 'DB_DATABASE=/app/database/database.sqlite' >> .env; \
    fi; \
  fi && \
  php artisan key:generate --force && \
  php artisan migrate --force --no-interaction && \
  php artisan serve --host=0.0.0.0 --port=8000"