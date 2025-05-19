#!/bin/bash

# Wait for database to be ready
echo "Waiting for database to be ready..."
until mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; do
  echo "Database not ready yet. Waiting..."
  sleep 5
done

echo "Database is ready. Checking if initialization is needed..."

# Check if database exists and has data
if ! mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DATABASE; SELECT 1 FROM produits LIMIT 1;" &>/dev/null; then
  echo "Initializing database..."
  
  # Create database if it doesn't exist
  mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "
    CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE 
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  
  # Import the SQL file
  echo "Importing database schema and data..."
  mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" < /docker-entrypoint-initdb.d/init.sql
  
  echo "Database initialization completed successfully."
else
  echo "Database already initialized. Skipping initialization."
fi

echo "Database setup complete."
