<?php
include_once("../conexao/conn.php");
include_once("../date.php");
include_once("../configs/config.php");
$dir = "../logs/logs.log";
#$id=1;

// Recebe dados JSON da requisição POST
$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data["codigo"])) {
   
    $mensagem_log = "LOG: " . json_encode(array("code" => 0, "message" => "Erro nos dados recebidos")) . " " . date("Y-m-d H:i:s") . PHP_EOL;

    file_put_contents($dir, $mensagem_log, FILE_APPEND);
    exit;
}

// Extrai dados do JSON
$id = $data["codigo"];

##Calcula conta
//Leitura Atual
$query = $pdo->query("SELECT leitura FROM tb_leituras WHERE codigo = '$id' AND mes = '$mesAtual'");
$resul = $query->fetchAll(PDO::FETCH_ASSOC);
if($resul){
	$leituraatual=$resul[0]['leitura'];
}else{
echo "ERROR";
}

//Leitura Anterior
$query = $pdo->query("SELECT leitura FROM tb_leituras WHERE codigo = '$id'  AND mes = '$mesAnterior'");
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
$query = "INSERT INTO tb_contas (mesreferencia,dataemissao, datavencimento, valorconta, valormetrocubico, leituraatual, leituraanterior, mensagem, codigouser) VALUES ('$mesAtual', now(), date_add(now(),interval 10 day), $valorconta, $valormetrocubico, $leituraatual, $leituraanterior, 'Seu consumo foi de $consumo metros cubicos', $id)";

try {
    // Executar a query
    $pdo->exec($query);

    #echo "Inserção realizada com sucesso!";
} catch (PDOException $e) {
    $mensagem_log = "LOG: Erro ao inserir na tabela tb_contas: " . $e->getMessage(). " " . date("Y-m-d H:i:s") . PHP_EOL;
    file_put_contents($dir, $mensagem_log, FILE_APPEND);
}



$dados = array();

$query = $pdo->query("SELECT tb_usuarios.nome, tb_usuarios.id, tb_usuarios.local,tb_contas.mesreferencia, tb_contas.dataemissao, tb_contas.datavencimento, tb_contas.valorconta, tb_contas.valormetrocubico, tb_contas.leituraatual, tb_contas.leituraanterior, tb_contas.mensagem
FROM tb_contas
INNER JOIN tb_usuarios ON tb_contas.codigouser = tb_usuarios.id
WHERE tb_usuarios.id = $id
ORDER BY tb_usuarios.nome, tb_usuarios.id, tb_usuarios.local;");
$res = $query->fetchAll(PDO::FETCH_ASSOC);

for ($i=0; $i < count($res); $i++){
	
	foreach ($res[$i] as $key => $value) {}
		$dados= $res;
	}
	
	echo ($res) ?
	json_encode(array("code" => 1, "result" => $dados)):
	json_encode(array("code" => 0, "message" => "Data Not Found"))


?>
