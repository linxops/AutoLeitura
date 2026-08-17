<?php
function calcularConta($consumo, $valormetrocubico) {
    $conta = $consumo * $valormetrocubico;
    return number_format($conta, 2, '.', '');
  }  
function calcularConsumo($leituraatual, $leituraanterior) {
	$consumo = $leituraatual - $leituraanterior;
	return $consumo;
	}   
    
?>
