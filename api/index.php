<?php
date_default_timezone_set('America/Sao_Paulo');
#include_once(__DIR__ . '/conexao/conn.php');
require_once __DIR__ . '/Router.php';

$requestUri = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : '';

$router = new Router;
$router->run();
#echo "Request URI: $requestUri<br>";
#echo "Route: $route<br>";




?>
