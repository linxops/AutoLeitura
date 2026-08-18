<?php
include_once(__DIR__ . '/../../conexao/conn.php');
require_once __DIR__ . '/../../functions/functions.php';

$logDir = __DIR__ . '/../../logs';

// Recebe dados JSON da requisição POST
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data["nome"]) || !isset($data["local"]) || !isset($data["celular"]) || !isset($data["senha"])) {
    resposta(0, null, "Erro nos dados recebidos");
    exit;
}

$nome = trim($data["nome"]);
$local = trim($data["local"]);
$celular = preg_replace('/\D/', '', $data["celular"]);
$email = (isset($data["email"]) && $data["email"] !== '') ? trim($data["email"]) : null;
$senha = $data["senha"];
$role = (isset($data["role"]) && $data["role"] !== '') ? $data["role"] : "usuario";

// Validações
if ($nome === '' || strlen($nome) > 100) {
    resposta(0, null, "Nome inválido");
    exit;
}
if (strlen($local) !== 1) {
    resposta(0, null, "Local deve ter 1 caractere");
    exit;
}
if (strlen($celular) !== 11) {
    resposta(0, null, "Celular inválido (11 dígitos)");
    exit;
}
if ($email !== null && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    resposta(0, null, "E-mail inválido");
    exit;
}
if (strlen($senha) < 6) {
    resposta(0, null, "Senha deve ter pelo menos 6 caracteres");
    exit;
}
if (!in_array($role, array("usuario", "admin"), true)) {
    resposta(0, null, "Role inválido (usuario ou admin)");
    exit;
}

// UNIQUE: celular e email não podem existir em outro usuário
$chk = $pdo->prepare("SELECT id FROM tb_usuarios WHERE celular = :celular");
$chk->bindParam(":celular", $celular);
$chk->execute();
if ($chk->fetch()) {
    resposta(0, null, "Celular já cadastrado");
    exit;
}

if ($email !== null) {
    $chk = $pdo->prepare("SELECT id FROM tb_usuarios WHERE email = :email");
    $chk->bindParam(":email", $email);
    $chk->execute();
    if ($chk->fetch()) {
        resposta(0, null, "E-mail já cadastrado");
        exit;
    }
}

$hash = password_hash($senha, PASSWORD_DEFAULT);

try {
    $sql = "INSERT INTO tb_usuarios (local, nome, celular, email, senha, role)
            VALUES (:local, :nome, :celular, :email, :senha, :role)";
    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(":local", $local);
    $stmt->bindParam(":nome", $nome);
    $stmt->bindParam(":celular", $celular);
    $stmt->bindParam(":email", $email);
    $stmt->bindParam(":senha", $hash);
    $stmt->bindParam(":role", $role);

    if (!$stmt->execute()) {
        throw new PDOException("Falha ao cadastrar usuário");
    }

    $id = (int) $pdo->lastInsertId();

    resposta(1, [[
        "id" => $id,
        "local" => $local,
        "nome" => $nome,
        "celular" => $celular,
        "email" => $email,
        "role" => $role,
    ]]);

    $mensagem_log = "LOG: Usuário cadastrado id:$id role:$role " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
} catch (PDOException $e) {
    $mensagem_log = "LOG: Erro ao cadastrar usuário: " . $e->getMessage() . " " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
    resposta(1, null, "Erro ao cadastrar o usuário");
}