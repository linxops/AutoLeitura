<?php
include_once(__DIR__ . '/../../conexao/conn.php');
include_once(__DIR__ . '/../../date.php');
require_once __DIR__ . '/../../functions/functions.php';

$logDir = __DIR__ . '/../../logs';

// Recebe dados JSON da requisição POST
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data["codigo"]) || !is_numeric($data["codigo"])) {
    resposta(0, null, "Erro nos dados recebidos");
    exit;
}

$codigo = (int) $data["codigo"];

// Valida o usuário
$stmt = $pdo->prepare("SELECT id FROM tb_usuarios WHERE id = :codigo");
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->execute();
if (!$stmt->fetch()) {
    resposta(0, null, "Usuário não encontrado");
    exit;
}

// Leitura do mês atual e do mês anterior
$stmt = $pdo->prepare("SELECT leitura FROM tb_leituras WHERE codigo = :codigo AND mes = :mes");
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->bindParam(":mes", $mesAtual);
$stmt->execute();
$leituraatual = $stmt->fetchColumn();

$stmt->bindParam(":mes", $mesAnterior);
$stmt->execute();
$leituraanterior = $stmt->fetchColumn();

if ($leituraatual === false || $leituraanterior === false) {
    resposta(0, null, "Leituras não encontradas para o mês atual ou anterior");
    exit;
}

// Valor do m³ vigente (registro mais recente)
$valor = $pdo->query("SELECT valor FROM tb_valor ORDER BY id DESC LIMIT 1")->fetchColumn();
if ($valor === false) {
    resposta(0, null, "Valor do metro cúbico não cadastrado");
    exit;
}

$consumo = calcularConsumo($leituraatual, $leituraanterior);
$valorconta = calcularConta($consumo, $valor);
$mensagem = "Seu consumo foi de $consumo metros cubicos";

// Insere ou recalcula a conta do mês (UNIQUE codigouser + mesreferencia)
$stmt = $pdo->prepare("SELECT id FROM tb_contas WHERE codigouser = :codigo AND mesreferencia = :mes");
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->bindParam(":mes", $mesAtual);
$stmt->execute();
$existe = $stmt->fetch();

$campos = "dataemissao = CURDATE(), datavencimento = DATE_ADD(CURDATE(), INTERVAL 10 DAY),
           valorconta = :valorconta, valormetrocubico = :valor, leituraatual = :leituraatual,
           leituraanterior = :leituraanterior, mensagem = :mensagem";

if ($existe) {
    $sql = "UPDATE tb_contas SET $campos WHERE codigouser = :codigo AND mesreferencia = :mes";
} else {
    $sql = "INSERT INTO tb_contas (mesreferencia, dataemissao, datavencimento, valorconta,
                                   valormetrocubico, leituraatual, leituraanterior, mensagem, codigouser)
            VALUES (:mes, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 10 DAY), :valorconta,
                    :valor, :leituraatual, :leituraanterior, :mensagem, :codigo)";
}

$stmt = $pdo->prepare($sql);
$stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
$stmt->bindParam(":mes", $mesAtual);
$stmt->bindParam(":valorconta", $valorconta);
$stmt->bindParam(":valor", $valor);
$stmt->bindParam(":leituraatual", $leituraatual, PDO::PARAM_INT);
$stmt->bindParam(":leituraanterior", $leituraanterior, PDO::PARAM_INT);
$stmt->bindParam(":mensagem", $mensagem);

if (!$stmt->execute()) {
    $mensagem_log = "LOG: Erro ao salvar conta do usuário $codigo: " . implode(' ', $stmt->errorInfo()) . " " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($logDir . '/logs.log', $mensagem_log, FILE_APPEND);
    resposta(0, null, "Erro ao calcular a conta");
    exit;
}

resposta(1, [[
    "codigouser" => $codigo,
    "mesreferencia" => $mesAtual,
    "leituraatual" => (int) $leituraatual,
    "leituraanterior" => (int) $leituraanterior,
    "consumo" => (int) $consumo,
    "valormetrocubico" => (float) $valor,
    "valorconta" => (float) $valorconta,
    "mensagem" => $mensagem,
]]);