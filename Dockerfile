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

# Create .env file from .env.example
RUN cp .env.example .env

# Generate APP_KEY
RUN php artisan key:generate --force

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Build frontend assets
COPY package*.json ./
RUN npm install
RUN npm run build

# Run migrations
RUN php artisan migrate --force

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Start Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

# Run migrations and start server
CMD sh -c "if [ ! -f .env ]; then \
    echo 'APP_NAME=Laravel' > .env; \
    echo 'APP_ENV=production' >> .env; \
    echo 'APP_DEBUG=false' >> .env; \
    echo 'DB_CONNECTION=sqlite' >> .env; \
    echo 'DB_DATABASE=/app/database/database.sqlite' >> .env; \
    echo \"APP_KEY=${APP_KEY}\" >> .env; \
    echo \"APP_URL=${APP_URL}\" >> .env; \
    echo 'SESSION_DRIVER=file' >> .env; \
    echo 'CACHE_STORE=file' >> .env; \
  fi && \
  php artisan migrate --force --no-interaction && \
  php artisan serve --host=0.0.0.0 --port=8000"