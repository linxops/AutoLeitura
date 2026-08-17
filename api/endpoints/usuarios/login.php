<?php
include_once(__DIR__ . '/../../conexao/conn.php');
include_once(__DIR__ . '/../../configs/config.php');
require_once __DIR__ . '/../../functions/functions.php';

$logDir = __DIR__ . '/../../logs';

// Recebe dados JSON da requisição POST
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data["codigo"]) || !isset($data["senha"]) || !is_numeric($data["codigo"])) {
    resposta(0, null, "Erro nos dados recebidos");
    $mensagem_log = "LOG: Login - dados inválidos " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
    exit;
}

$codigo = (int) $data["codigo"];
$senha = $data["senha"];

// Busca o usuário pelo código (id). Prepared statement evita SQL injection.
$stmt = $pdo->prepare(
    "SELECT id, local, nome, celular, email, role, senha FROM tb_usuarios WHERE id = :codigo"
);
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->execute();
$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    resposta(0, null, "Usuário não encontrado");
    $mensagem_log = "LOG: Login - usuário $codigo não encontrado " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
    exit;
}

if (!password_verify($senha, $usuario["senha"])) {
    resposta(0, null, "Senha incorreta");
    $mensagem_log = "LOG: Login - senha incorreta para usuário $codigo " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
    exit;
}

// Rehash automático caso o algoritmo/custo padrão mude
if (password_needs_rehash($usuario["senha"], PASSWORD_DEFAULT)) {
    $nova = password_hash($senha, PASSWORD_DEFAULT);
    $upd = $pdo->prepare("UPDATE tb_usuarios SET senha = :senha WHERE id = :codigo");
    $upd->bindParam(":senha", $nova);
    $upd->bindParam(":codigo", $codigo, PDO::PARAM_INT);
    $upd->execute();
}

unset($usuario["senha"]);

resposta(1, [$usuario]);

$mensagem_log = "LOG: Login - sucesso usuário $codigo (role {$usuario['role']}) " . date("Y-m-d H:i:s") . PHP_EOL;
file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);