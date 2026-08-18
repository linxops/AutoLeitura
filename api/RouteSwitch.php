<?php
#ini_set('display_errors', 1);
#error_reporting(E_ALL);
#date_default_timezone_set('America/Sao_Paulo');
#include_once(__DIR__ . '/conexao/conn.php');
abstract class RouteSwitch
{
   
    
    protected function usuario()
    {
        require __DIR__ . '/endpoints/usuarios/listar_usuarios.php';
    }

    protected function leituras()
    {
        require __DIR__ . '/endpoints/leituras/listar_leituras.php';
    }
    
    protected function postLeituras()
    {
        require __DIR__ . '/endpoints/leituras/leituras.php';
    }

    protected function login()
    {
        require __DIR__ . '/endpoints/usuarios/login.php';
    }

    protected function atualizar_usuario()
    {
        require __DIR__ . '/endpoints/usuarios/atualizar_usuario.php';
    }

    protected function cadastrar_usuario()
    {
        require __DIR__ . '/endpoints/usuarios/cadastrar_usuario.php';
    }

    protected function calcular_conta()
    {
        require __DIR__ . '/endpoints/contas/calcular_conta.php';
    }

    protected function exibir_conta()
    {
        require __DIR__ . '/endpoints/contas/exibir_conta.php';
    }

    protected function listar_conta()
    {
        require __DIR__ . '/endpoints/contas/listar_conta.php';
    }

    protected function admin()
    {
        require __DIR__ . '/logs/logs.log';
    }
    
    /*
    */

    protected function defaultRoute()
    {
       http_response_code(404);
       require __DIR__ . '/404.html';
        
           
    }
    protected function home()
    {
        require __DIR__ . '/endpoints/home/home.php';

    }
   
}
?>
