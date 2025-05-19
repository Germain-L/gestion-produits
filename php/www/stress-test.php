<?php
header('Content-Type: application/json');

// Endpoint de calcul intensif (CPU)
if ($_SERVER['REQUEST_METHOD'] === 'GET' && parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/stress-test/cpu') {
    $iterations = isset($_GET['iterations']) ? (int)$_GET['iterations'] : 1000000;
    $start = microtime(true);
    $result = 0;
    
    for ($i = 0; $i < $iterations; $i++) {
        $result += sqrt($i) * tan($i) * sin($i);
    }
    
    $executionTime = round(microtime(true) - $start, 4);
    
    echo json_encode([
        'status' => 'success',
        'test_type' => 'cpu',
        'iterations' => $iterations,
        'execution_time_seconds' => $executionTime,
        'iterations_per_second' => round($iterations / $executionTime),
        'memory_usage' => round(memory_get_usage() / 1024 / 1024, 2) . 'MB',
        'peak_memory_usage' => round(memory_get_peak_usage() / 1024 / 1024, 2) . 'MB',
        'server' => gethostname(),
        'timestamp' => date('c')
    ], JSON_PRETTY_PRINT);
    exit;
}

// Endpoint de consommation mémoire
if ($_SERVER['REQUEST_METHOD'] === 'GET' && parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/stress-test/memory') {
    $mb = min(4096, isset($_GET['mb']) ? (int)$_GET['mb'] : 10); // Max 4GB pour des raisons de sécurité
    $duration = isset($_GET['duration']) ? (int)$_GET['duration'] : 5;
    
    $start = microtime(true);
    
    // Allouer X MB de mémoire
    $data = str_repeat('x', $mb * 1024 * 1024);
    $allocated = strlen($data) / 1024 / 1024;
    
    // Maintenir la mémoire allouée pendant X secondes
    sleep($duration);
    
    $executionTime = round(microtime(true) - $start, 4);
    
    echo json_encode([
        'status' => 'success',
        'test_type' => 'memory',
        'memory_allocated_mb' => $allocated,
        'memory_used' => round(memory_get_usage() / 1024 / 1024, 2) . 'MB',
        'peak_memory_usage' => round(memory_get_peak_usage() / 1024 / 1024, 2) . 'MB',
        'duration_seconds' => $duration,
        'total_execution_time_seconds' => $executionTime,
        'server' => gethostname(),
        'timestamp' => date('c')
    ], JSON_PRETTY_PRINT);
    
    // Libérer la mémoire explicitement
    unset($data);
    exit;
}

// Endpoint de statut
if ($_SERVER['REQUEST_METHOD'] === 'GET' && parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/stress-test/status') {
    echo json_encode([
        'status' => 'ok',
        'server' => gethostname(),
        'timestamp' => date('c'),
        'memory_usage' => round(memory_get_usage() / 1024 / 1024, 2) . 'MB',
        'memory_limit' => ini_get('memory_limit'),
        'max_execution_time' => ini_get('max_execution_time') . 's',
        'php_version' => phpversion(),
        'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'N/A'
    ], JSON_PRETTY_PRINT);
    exit;
}

// Endpoint par défaut
http_response_code(404);
echo json_encode([
    'status' => 'error',
    'message' => 'Endpoint non trouvé',
    'available_endpoints' => [
        'GET /stress-test/cpu?iterations=1000000',
        'GET /stress-test/memory?mb=10&duration=5',
        'GET /stress-test/status'
    ],
    'server' => gethostname(),
    'timestamp' => date('c')
], JSON_PRETTY_PRINT);
