# Deployment Guide

## Deploy to Render.com

### Option 1: Using render.yaml (Recommended)

1. Push your code to GitHub with the `render.yaml` file
2. Log in to [Render.com](https://render.com)
3. Create a new Web Service and connect your GitHub repository
4. Render will automatically detect the `render.yaml` file and configure the deployment
5. Click Deploy

### Option 2: Manual Configuration

1. Connect your GitHub repository to Render
2. Set the **Build Command**: `composer install && php artisan key:generate --force`
3. Set the **Start Command**: `php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000`
4. Add Environment Variables:
    - `APP_ENV=production`
    - `APP_DEBUG=false`
    - `DB_CONNECTION=sqlite`
    - `LOG_CHANNEL=stdout`

### Environment Variables Setup

Add these in Render Dashboard:

```
APP_ENV=production
APP_DEBUG=false
APP_NAME=CRUD App
LOG_CHANNEL=stdout
```

### Database

SQLite database will be created automatically in `database/database.sqlite` during first deploy.

### Local Docker Testing

Before deploying, test locally with:

```bash
docker-compose up --build
```

Access at `http://localhost:8000`

## Troubleshooting

### Build Fails

- Check that all dependencies in `composer.json` are compatible
- Ensure PHP 8.3 is used
- Verify all system extensions are installed

### Database Issues

- SQLite database is auto-created during migration
- Check file permissions on `/app/database` directory
- Render's free tier uses ephemeral storage; database resets on redeploy

### Cold Start Issues

- Free tier services sleep after 15 minutes
- First request may take 30+ seconds
- This is normal behavior on Render's free plan
