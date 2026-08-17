<?php
if (!isset($_SERVER['PHP_AUTH_USER']) || !isset($_SERVER['PHP_AUTH_PW'])) {
header('WWW-Authenticate: Basic realm="Área Restrita"');
exit;
}

?>

<!DOCTYPE html>
<html lang="pt-br">
  <head>
  <link rel="icon" href="/img/icon_v1.png">
    <title>AutoLeitura</title>
    <meta charset="utf-8">
  </head>
  <body>
    <h3>API AUTOLEITURA DOCUMENTAÇÃO</h3>
    <br>
    <br>
    <p></p>
    <br>
    <br>
    <p>LINK VAZIO<a href="">Link Vazio</a>.</p>
    
  </body>
</html>