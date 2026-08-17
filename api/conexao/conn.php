<?php
include_once("env.php");
date_default_timezone_set('America/Sao_Paulo');

$logDir = __DIR__ . '/../logs';
try{
	
	$pdo = new PDO("mysql:dbname=$banco;host=$host;charset=utf8", "$user", "$senha");
        $mensagem_log = "LOG: Conectado ao Banco de Dados " . date("Y-m-d H:i:s") . PHP_EOL;
    } catch (Exception $e) {
	    $mensagem_log = "LOG: Conexão mal sucedida - " . $e->getMessage() . " " . date("Y-m-d H:i:s") . PHP_EOL;
} 

	file_put_contents($logDir.'/logs.log', $mensagem_log, FILE_APPEND);

?>


