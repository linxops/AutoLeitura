<?php
include_once(__DIR__ . '/../../conexao/conn.php');
include_once(__DIR__ . '/../../date.php');
include_once(__DIR__ . '/../../configs/config.php');
require_once __DIR__ . '/../../functions/functions.php';

$logDir = __DIR__ . '/../../logs';

// Recebe dados JSON da requisição POST
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data["codigo"]) || !isset($data["leitura"]) || !is_numeric($data["codigo"]) || !is_numeric($data["leitura"])) {
    resposta(0, null, "Erro nos dados recebidos");
    exit;
}

$codigo = (int) $data["codigo"];
$leitura = (int) $data["leitura"];
$dataLeitura = date("Y-m-d");

// Valida o usuário
$stmt = $pdo->prepare("SELECT id FROM tb_usuarios WHERE id = :codigo");
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->execute();
if (!$stmt->fetch()) {
    resposta(0, null, "Usuário não encontrado");
    exit;
}

// Upsert: insere ou atualiza a leitura do mês (UNIQUE codigo + mes)
$stmt = $pdo->prepare("SELECT id FROM tb_leituras WHERE codigo = :codigo AND mes = :mes");
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->bindParam(":mes", $mesAtual);
$stmt->execute();
$existe = $stmt->fetch();

if ($existe) {
    $sql = "UPDATE tb_leituras SET leitura = :leitura, data = :dataLeitura
            WHERE codigo = :codigo AND mes = :mes";
} else {
    $sql = "INSERT INTO tb_leituras (mes, leitura, data, codigo)
            VALUES (:mes, :leitura, :dataLeitura, :codigo)";
}

$stmt = $pdo->prepare($sql);
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->bindParam(":mes", $mesAtual);
$stmt->bindParam(":leitura", $leitura, PDO::PARAM_INT);
$stmt->bindParam(":dataLeitura", $dataLeitura);

try {
    if (!$stmt->execute()) {
        throw new PDOException("Falha ao executar a consulta");
    }
    $acao = $existe ? "atualizada" : "inserida";
    resposta(0, null, "Leitura $acao com sucesso para o usuario codigo:$codigo no mes: $mesAtual");
    $mensagem_log = "LOG: Leitura $acao para o usuario codigo:$codigo no mes: $mesAtual " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
} catch (PDOException $e) {
    $mensagem_log = "LOG: Erro ao salvar leitura do usuário $codigo: " . $e->getMessage() . " " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
    resposta(1, null, "Erro ao inserir leitura para o usuario codigo:$codigo na data --> " . date("Y-m-d H:i:s"));
}