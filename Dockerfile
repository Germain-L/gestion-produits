# Use the official PHP 8.1 Apache image as base
FROM php:8.1-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mysqli zip

# Enable Apache modules
RUN a2enmod rewrite headers

# Copy Apache configuration
COPY php/www/000-default.conf /etc/apache2/sites-available/000-default.conf

# Set the working directory
WORKDIR /var/www/html

# Create uploads directory (permissions will be set in entrypoint)
RUN mkdir -p /var/www/html/uploads

# Copy the application files (exclude 000-default.conf to avoid override)
COPY php/www/ /var/www/html/
RUN rm -f /var/www/html/000-default.conf

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 80
EXPOSE 80

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command
CMD ["apache2-foreground"]