#!/bin/bash
set -e

# Set proper permissions for uploads directory
chown -R www-data:www-data /var/www/html/uploads
chmod -R 775 /var/www/html/uploads
chmod +t /var/www/html/uploads

# Execute the default command
apache2-foreground
