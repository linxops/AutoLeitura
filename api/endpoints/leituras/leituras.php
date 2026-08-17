<?php
include_once("/../../conexao/conn.php");
include_once("/../../date.php");
include_once("/../../configs/config.php");


$dir = "../logs/logs.log";

// Recebe dados JSON da requisição POST
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data["codigo"]) || !isset($data["leitura"])) {
   
    $mensagem_log = "LOG: " . json_encode(array("code" => 0, "message" => "Erro nos dados recebidos")) . " " . date("Y-m-d H:i:s") . PHP_EOL;

    file_put_contents($dir, $mensagem_log, FILE_APPEND);
    exit;
}

// Obtém a data atual
$dataLeitura = date("Y-m-d");


// Extrai dados do JSON
$codigo = $data["codigo"];
$leitura = $data["leitura"];
  

// Prepara e executa a consulta SQL
$sql = "INSERT INTO tb_leituras (mes, leitura, data, codigo) VALUES (:mes, :leitura, :dataLeitura, :codigo)";
$stmt = $pdo->prepare($sql);

$stmt->bindParam(":mes", $mesAtual);
$stmt->bindParam(":leitura", $leitura);
$stmt->bindParam(":dataLeitura", $dataLeitura);
$stmt->bindParam(":codigo", $codigo);

$response = array();

if ($stmt->execute()) {
    // Se a execução for bem-sucedida, retorna uma mensagem de sucesso
    $response['code'] = 0;
    $mensagem_log = "LOG: " . $response['message'] = "Leitura inserida com sucesso para o usuario codigo:$codigo na data -->". date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($dir, $mensagem_log, FILE_APPEND);
} else {
    // Se houver um erro na execução, retorna uma mensagem de erro
    $response['code'] = 1;
    $mensagem_log = "LOG: " . $response['message'] = "Erro ao inserir leitura para o usuario codigo:$codigo na data --> ". date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($dir, $mensagem_log, FILE_APPEND);
}

echo json_encode($response);
?>
