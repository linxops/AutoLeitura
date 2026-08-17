<?php
include_once("../conexao/conn.php");
include_once("../date.php");
require "../functions/functions.php";
$dir = "../logs/logs.log";
$codigo=1;

##Calcula conta
//Leitura Atual
$query = $pdo->query("SELECT leitura FROM tb_leituras WHERE codigo = '$codigo' AND mes = '$mesAtual'");
$resul = $query->fetchAll(PDO::FETCH_ASSOC);
if($resul){
	$leituraatual=$resul[0]['leitura'];
}else{
echo "ERROR";
}

//Leitura Anterior
$query = $pdo->query("SELECT leitura FROM tb_leituras WHERE codigo = '$codigo'  AND mes = '$mesAnterior'");
$resul = $query->fetchAll(PDO::FETCH_ASSOC);
if($resul){
	$leituraanterior=$resul[0]['leitura'];
}else{
echo "ERROR";
}

//Busca Valor M³
$query = $pdo->query("SELECT valor FROM tb_valor ORDER BY id DESC LIMIT 1;");
$res = $query->fetch(PDO::FETCH_ASSOC);

if ($res) {
	$valormetrocubico=$res['valor'];
} else {
    echo "Erro ao buscar valor";
    
}


$consumo=calcularConsumo($leituraatual, $leituraanterior);
$valorconta= calcularConta($consumo, $valormetrocubico);
echo "Consumo".$consumo;
echo "A conta calculada é: R$" .$valorconta;

// Query de inserção
$query = "INSERT INTO tb_contas (mesreferencia,dataemissao, datavencimento, valorconta, valormetrocubico, leituraatual, leituraanterior, mensagem, codigouser) VALUES ('$mesAtual', now(), date_add(now(),interval 10 day), $valorconta, $valormetrocubico, $leituraatual, $leituraanterior, 'Seu consumo foi de $consumo metros cubicos', $codigo)";

try {
    // Executar a query
    $pdo->exec($query);

    #echo "Inserção realizada com sucesso!";
} catch (PDOException $e) {
    $mensagem_log = "LOG: Erro ao inserir na tabela tb_contas: " . $e->getMessage(). " " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($dir, $mensagem_log, FILE_APPEND);
}



?>
