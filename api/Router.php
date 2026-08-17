<?php
#ini_set('display_errors', 1);
#error_reporting(E_ALL);
#date_default_timezone_set('America/Sao_Paulo');
#include_once(__DIR__ . '/conexao/conn.php');
require_once __DIR__ . '/RouteSwitch.php';

class Router extends RouteSwitch
{
    public function run()
    {
        $requestUri = isset($_SERVER['REQUEST_URI']) ? strtok($_SERVER['REQUEST_URI'], '?') : '';
        $route = trim($requestUri, '/');

        #echo "Request URI: $requestUri<br>";
        #echo "Route: $route<br>";

        if ($route === '' || $route === 'index.php' || $route === 'endpoints') {
            $this->usuario();
           
        }
        if ($route === '' || $route === 'index.php' || $route === 'endpoints') {
            $this->leituras();
           
        }

        if ($route === '' || $route === 'index.php' || $route === 'endpoints') {
            $this->postLeituras();
           
        }

        if ($route === '' || $route === 'index.php' || $route === '/') {
            $this->admin();
           
        }

        if ($route === '' || $route === 'index.php' || $route === 'endpoints') {
            $this->home();
           
        }

        
          else {
            $method = $route;
            if (method_exists($this, $method)) {
                $this->$method();
            } else {
                
                $this->defaultRoute();
            }
        }
    }
}

$router = new Router;
#$router->run();
?>
