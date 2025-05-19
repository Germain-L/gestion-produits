<?php
function connectToDatabase() {
    $host = getenv('DB_HOST') ?: 'db';
    $username = getenv('DB_USER') ?: 'root';
    $password = getenv('DB_PASSWORD') ?: 'root';
    $dbname = getenv('DB_NAME') ?: 'gestion_produits';
    $port = getenv('DB_PORT') ?: '3306';

    $maxRetries = 5;
    $retryDelay = 2; // seconds
    
    for ($i = 0; $i < $maxRetries; $i++) {
        try {
            $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_TIMEOUT            => 5,
            ];
            
            $pdo = new PDO($dsn, $username, $password, $options);
            return $pdo;
            
        } catch (PDOException $e) {
            if ($i === $maxRetries - 1) {
                // Last attempt, re-throw the exception
                throw new PDOException(
                    "Failed to connect to database after $maxRetries attempts: " . $e->getMessage(),
                    (int)$e->getCode()
                );
            }
            
            error_log(sprintf(
                'Connection attempt %d/%d failed: %s. Retrying in %d seconds...',
                $i + 1,
                $maxRetries,
                $e->getMessage(),
                $retryDelay
            ));
            
            sleep($retryDelay);
        }
    }
}

try {
    $db = connectToDatabase();
} catch (PDOException $e) {
    // Log the full error but show a user-friendly message
    error_log('Database connection error: ' . $e->getMessage());
    die('Unable to connect to the database. Please try again later.');
}
?>