<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
include_once(__DIR__ . '/../../conexao/conn.php');
include_once(__DIR__ . '/../../date.php');
$logDir = __DIR__ . '/../../logs';

$dados = array();

$query = $pdo->query("SELECT *FROM tb_leituras WHERE mes = '$mesAtual'");
$res = $query->fetchAll(PDO::FETCH_ASSOC);

for ($i=0; $i < count($res); $i++){
	
	foreach ($res[$i] as $key => $value) {}
		$dados= $res;
	}
	
	$response = ($res) ?
	json_encode(array("code" => 1, "result" => $dados)):
	json_encode(array("code" => 0, "message" => "Data Not Found"));

echo $response;

	$mensagem_log = ($res) ?
	"LOG: Leituras do mes - Leitura Exibida  " . $response . " " . date("Y-m-d H:i:s") . PHP_EOL :
	"LOG: Leituras do mes - Nada a Exibir " . $response . " " . date("Y-m-d H:i:s") . PHP_EOL;

	file_put_contents($logDir.'/logs.log', $mensagem_log, FILE_APPEND);


?>

