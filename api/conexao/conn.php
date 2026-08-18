<?php
include_once("env.php");
date_default_timezone_set('America/Sao_Paulo');

// CORS apenas para testes locais (Flutter web). Em produção/Android fica desativado:
// a origem é definida pela env ALLOW_CORS_ORIGIN no docker-compose.
$corsOrigem = getenv('ALLOW_CORS_ORIGIN');
if ($corsOrigem !== false && $corsOrigem !== '') {
    header("Access-Control-Allow-Origin: $corsOrigem");
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}

$logDir = __DIR__ . '/../logs';
try{
	
	$pdo = new PDO("mysql:dbname=$banco;host=$host;charset=utf8", "$user", "$senha");
        $mensagem_log = "LOG: Conectado ao Banco de Dados " . date("Y-m-d H:i:s") . PHP_EOL;
    } catch (Exception $e) {
	    $mensagem_log = "LOG: Conexão mal sucedida - " . $e->getMessage() . " " . date("Y-m-d H:i:s") . PHP_EOL;
} 

	file_put_contents($logDir.'/logs.log', $mensagem_log, FILE_APPEND);

?>


