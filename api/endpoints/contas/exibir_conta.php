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

$sql = "SELECT tb_usuarios.nome, tb_usuarios.id, tb_usuarios.local, tb_contas.mesreferencia,
               tb_contas.dataemissao, tb_contas.datavencimento, tb_contas.valorconta,
               tb_contas.valormetrocubico, tb_contas.leituraatual, tb_contas.leituraanterior,
               tb_contas.mensagem
        FROM tb_contas
        INNER JOIN tb_usuarios ON tb_contas.codigouser = tb_usuarios.id
        WHERE tb_usuarios.id = :codigo
        ORDER BY tb_usuarios.nome, tb_usuarios.id, tb_usuarios.local";

$stmt = $pdo->prepare($sql);
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->execute();
$res = $stmt->fetchAll(PDO::FETCH_ASSOC);

if ($res) {
    resposta(1, $res);
} else {
    resposta(0, null, "Data Not Found");
}