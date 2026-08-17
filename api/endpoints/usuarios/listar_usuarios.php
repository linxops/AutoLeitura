<?php
#ini_set('display_errors', 1);
#error_reporting(E_ALL);

include_once(__DIR__ . '/../../conexao/conn.php');
$logDir = __DIR__ . '/../../logs';
$dados = array();

if (!isset($pdo)) {
    die("Erro: A variável \$pdo não foi definida.");
}

$sql = "SELECT * FROM tb_usuarios";
$stmt = $pdo->prepare($sql);
$stmt->execute();

$res = $stmt->fetchAll(PDO::FETCH_ASSOC);


for ($i = 0; $i < count($res); $i++) {
    foreach ($res[$i] as $key => $value) {
        
        $dados = $res;
    }
}

	$response = ($res) ?
    json_encode(array("code" => 1, "result" => $dados)) :
    json_encode(array("code" => 0, "message" => "Data Not Found"));

echo $response;

	$mensagem_log = ($res) ?
    "LOG: Data Found " . $response . " " . date("Y-m-d H:i:s") . PHP_EOL :
    "LOG: Data Not Found " . $response . " " . date("Y-m-d H:i:s") . PHP_EOL;

	file_put_contents($logDir.'/logs.log', $mensagem_log, FILE_APPEND);
?>
