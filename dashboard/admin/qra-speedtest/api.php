<?php
// Located under /admin: retain Pi-Star's existing web-server authentication.
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
header('X-Content-Type-Options: nosniff');
ini_set('session.use_strict_mode', '1');
session_name('qra_speedtest');
session_set_cookie_params(0, '/admin/qra-speedtest/', '', !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off', true);
session_start();
if (empty($_SESSION['csrf'])) {
    $_SESSION['csrf'] = bin2hex(random_bytes(32));
}
$csrf = $_SESSION['csrf'];
session_write_close();

function fail_request($status, $message) {
    http_response_code($status);
    echo json_encode(array('error' => $message), JSON_UNESCAPED_UNICODE);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$action = 'state';
if ($method === 'POST') {
    if (intval(isset($_SERVER['CONTENT_LENGTH']) ? $_SERVER['CONTENT_LENGTH'] : 0) > 1024) {
        fail_request(413, 'Слишком большой запрос.');
    }
    $body = json_decode(file_get_contents('php://input', false, null, 0, 1025), true);
    if (!is_array($body) || !isset($body['csrf']) || !is_string($body['csrf']) || !hash_equals($csrf, $body['csrf'])) {
        fail_request(403, 'Обновите виджет и повторите запуск.');
    }
    if (!isset($body['action']) || $body['action'] !== 'start') {
        fail_request(400, 'Неизвестное действие.');
    }
    $action = 'start';
} elseif ($method !== 'GET') {
    header('Allow: GET, POST');
    fail_request(405, 'Метод не поддерживается.');
}
$socket = @stream_socket_client('unix:///run/qra-speedtest/agent.sock', $errno, $error, 3);
if (!$socket) {
    fail_request(503, 'Агент измерения на Pi-Star недоступен.');
}
stream_set_timeout($socket, 3);
fwrite($socket, json_encode(array('action' => $action)) . "\n");
$line = fgets($socket, 65536);
fclose($socket);
$response = json_decode($line === false ? '' : $line, true);
if (!is_array($response)) {
    fail_request(503, 'Агент не ответил.');
}
if (!empty($response['error'])) {
    fail_request(!empty($response['busy']) ? 409 : 502, $response['error']);
}
$response['csrf'] = $csrf;
echo json_encode($response, JSON_UNESCAPED_UNICODE);
