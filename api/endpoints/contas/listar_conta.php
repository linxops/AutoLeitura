<?php
include_once(__DIR__ . '/../../conexao/conn.php');
require_once __DIR__ . '/../../functions/functions.php';

$logDir = __DIR__ . '/../../logs';

$sql = "SELECT tb_usuarios.nome, tb_usuarios.id, tb_usuarios.local, tb_contas.mesreferencia,
               tb_contas.dataemissao, tb_contas.datavencimento, tb_contas.valorconta,
               tb_contas.valormetrocubico, tb_contas.leituraatual, tb_contas.leituraanterior,
               tb_contas.mensagem
        FROM tb_contas
        INNER JOIN tb_usuarios ON tb_contas.codigouser = tb_usuarios.id
        ORDER BY tb_usuarios.nome, tb_usuarios.id, tb_usuarios.local";

$stmt = $pdo->prepare($sql);
$stmt->execute();
$res = $stmt->fetchAll(PDO::FETCH_ASSOC);

if ($res) {
    resposta(1, $res);
} else {
    resposta(0, null, "Data Not Found");
}