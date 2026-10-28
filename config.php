<?php
declare(strict_types=1);

function loadEnv(string $path): array {
    $env = [];
    if (!is_file($path)) return $env;
    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) continue;
        [$key, $value] = array_map('trim', explode('=', $line, 2));
        $env[$key] = trim($value, "\"'");
    }
    return $env;
}

$ENV = loadEnv(dirname(__DIR__) . '/.env');
function envv(string $key, mixed $default = null): mixed { global $ENV; return $ENV[$key] ?? $default; }

ini_set('display_errors', envv('APP_DEBUG', 'false') === 'true' ? '1' : '0');
error_reporting(E_ALL);
date_default_timezone_set('Europe/Istanbul');

session_name((string)envv('SESSION_NAME', 'COBUYSESSID'));
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_set_cookie_params(['httponly'=>true,'samesite'=>'Lax','path'=>'/']);
    session_start();
}

function db(): PDO {
    static $pdo = null;
    if ($pdo instanceof PDO) return $pdo;
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', envv('DB_HOST','127.0.0.1'), envv('DB_PORT','3306'), envv('DB_DATABASE','cobuy'));
    try {
        $pdo = new PDO($dsn, (string)envv('DB_USERNAME','root'), (string)envv('DB_PASSWORD',''), [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        return $pdo;
    } catch (Throwable $e) {
        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['ok'=>false,'message'=>'Veritabanına bağlanılamadı. Önce database.sql dosyasını phpMyAdmin üzerinden içe aktarın.','detail'=>envv('APP_DEBUG','false')==='true'?$e->getMessage():null], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

function jsonInput(): array {
    $raw = file_get_contents('php://input');
    if (!$raw) return $_POST ?: [];
    $data = json_decode($raw, true);
    return is_array($data) ? $data : $_POST;
}
function respond(mixed $data, int $status=200): never {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}
function ok(mixed $data=null, string $message='İşlem başarılı'): never { respond(['ok'=>true,'message'=>$message,'data'=>$data]); }
function fail(string $message, int $status=400, mixed $errors=null): never { respond(['ok'=>false,'message'=>$message,'errors'=>$errors],$status); }
function user(): ?array { return $_SESSION['user'] ?? null; }
function requireUser(): array { $u=user(); if(!$u) fail('Bu işlem için giriş yapmalısınız.',401); return $u; }
function requireRole(array $roles): array { $u=requireUser(); if(!in_array($u['role'],$roles,true)) fail('Bu işlem için yetkiniz yok.',403); return $u; }
function clean(string $v): string { return trim(strip_tags($v)); }
function audit(?int $actor, string $action, string $entityType, ?int $entityId=null, array $meta=[]): void {
    try { $s=db()->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,metadata) VALUES(?,?,?,?,?)'); $s->execute([$actor,$action,$entityType,$entityId,json_encode($meta,JSON_UNESCAPED_UNICODE)]); } catch(Throwable) {}
}
