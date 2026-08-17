<?php
function calcularConta($consumo, $valormetrocubico) {
    $conta = $consumo * $valormetrocubico;
    return number_format($conta, 2, '.', '');
  }  
function calcularConsumo($leituraatual, $leituraanterior) {
	$consumo = $leituraatual - $leituraanterior;
	return $consumo;
	}

/**
 * Monta a resposta padrão da API:
 *   {"code":0|1, "result":[...]} ou {"code":0|1, "message":"..."}
 */
function resposta(int $code, ?array $result = null, ?string $message = null): void {
    $response = array("code" => $code);
    if ($result !== null) {
        $response["result"] = $result;
    } else {
        $response["message"] = $message ?? '';
    }
    echo json_encode($response);
}

/**
 * Verifica se o usuário tem papel admin (role = 'admin').
 * Usado para restringir endpoints administrativos.
 */
function isAdmin(PDO $pdo, int $codigo): bool {
    $stmt = $pdo->prepare("SELECT role FROM tb_usuarios WHERE id = :codigo");
    $stmt->bindParam(":codigo", $codigo, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchColumn() === 'admin';
}
?>