<?php
include_once(__DIR__ . '/../../conexao/conn.php');
require_once __DIR__ . '/../../functions/functions.php';

$logDir = __DIR__ . '/../../logs';

// Recebe dados JSON da requisição POST
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data["codigo"]) || !is_numeric($data["codigo"])) {
    resposta(0, null, "Erro nos dados recebidos");
    exit;
}

$codigo = (int) $data["codigo"];

// Verifica se o usuário existe
$stmt = $pdo->prepare("SELECT id, nome, local, celular, email, role, senha FROM tb_usuarios WHERE id = :codigo");
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->execute();
$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    resposta(0, null, "Usuário não encontrado");
    exit;
}

// Campos atualizáveis (somente os enviados)
$campos = array();
$valores = array();

$mapear = function ($chave) use ($data) {
    return isset($data[$chave]) && $data[$chave] !== '';
};

if ($mapear("nome")) {
    $nome = trim($data["nome"]);
    if ($nome === '') {
        resposta(0, null, "Nome inválido");
        exit;
    }
    $campos[] = "nome = :nome";
    $valores[":nome"] = $nome;
}

if ($mapear("local")) {
    $local = trim($data["local"]);
    if (strlen($local) !== 1) {
        resposta(0, null, "Local deve ter 1 caractere");
        exit;
    }
    $campos[] = "local = :local";
    $valores[":local"] = $local;
}

if ($mapear("celular")) {
    $celular = preg_replace('/\D/', '', $data["celular"]);
    if (strlen($celular) !== 11) {
        resposta(0, null, "Celular inválido (11 dígitos)");
        exit;
    }
    $chk = $pdo->prepare("SELECT id FROM tb_usuarios WHERE celular = :celular AND id <> :codigo");
    $chk->bindParam(":celular", $celular);
    $chk->bindParam(":codigo", $codigo, PDO::PARAM_INT);
    $chk->execute();
    if ($chk->fetch()) {
        resposta(0, null, "Celular já cadastrado para outro usuário");
        exit;
    }
    $campos[] = "celular = :celular";
    $valores[":celular"] = $celular;
}

if ($mapear("email")) {
    $email = trim($data["email"]);
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        resposta(0, null, "E-mail inválido");
        exit;
    }
    $chk = $pdo->prepare("SELECT id FROM tb_usuarios WHERE email = :email AND id <> :codigo");
    $chk->bindParam(":email", $email);
    $chk->bindParam(":codigo", $codigo, PDO::PARAM_INT);
    $chk->execute();
    if ($chk->fetch()) {
        resposta(0, null, "E-mail já cadastrado para outro usuário");
        exit;
    }
    $campos[] = "email = :email";
    $valores[":email"] = $email;
}

if ($mapear("role")) {
    $role = $data["role"];
    if (!in_array($role, array("usuario", "admin"), true)) {
        resposta(0, null, "Role inválido (usuario ou admin)");
        exit;
    }
    $campos[] = "role = :role";
    $valores[":role"] = $role;
}

if ($mapear("senha")) {
    $senha = $data["senha"];
    if (strlen($senha) < 6) {
        resposta(0, null, "Senha deve ter pelo menos 6 caracteres");
        exit;
    }
    $campos[] = "senha = :senha";
    $valores[":senha"] = password_hash($senha, PASSWORD_DEFAULT);
}

if (empty($campos)) {
    resposta(0, null, "Nenhum campo para atualizar");
    exit;
}

try {
    $sql = "UPDATE tb_usuarios SET " . implode(", ", $campos) . " WHERE id = :codigo";
    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
    foreach ($valores as $ph => $valor) {
        $stmt->bindValue($ph, $valor);
    }
    if (!$stmt->execute()) {
        throw new PDOException("Falha ao atualizar usuário");
    }

    // Retorna o usuário atualizado (sem senha)
    $stmt = $pdo->prepare("SELECT id, local, nome, celular, email, role FROM tb_usuarios WHERE id = :codigo");
    $stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
    $stmt->execute();
    $atualizado = $stmt->fetch(PDO::FETCH_ASSOC);

    resposta(1, [$atualizado]);

    $mensagem_log = "LOG: Usuário $codigo atualizado " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
} catch (PDOException $e) {
    $mensagem_log = "LOG: Erro ao atualizar usuário $codigo: " . $e->getMessage() . " " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
    resposta(1, null, "Erro ao atualizar o usuário");
}