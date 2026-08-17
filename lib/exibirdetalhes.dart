import 'package:flutter/material.dart';
import 'package:autoleitura/exibirconta.dart';

class ExibirDetalhes extends StatelessWidget {
  final usuario;
  final leitura;
  final String mesAtual;

  const ExibirDetalhes({
    super.key,
    required this.usuario,
    required this.leitura,
    required this.mesAtual,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AUTOLEITURA - DETALHES'),
        backgroundColor: const Color.fromARGB(255, 0, 5, 8),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Detalhes da Conta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Nome: ${usuario.nome}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Código: ${usuario.codigo}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Leitura Atual: ${leitura.leituraAtual.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Leitura Anterior: ${leitura.leituraAnterior.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Mês Atual: $mesAtual',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Valor do Metro Cúbico: R\$ 1.15',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Valor Calculado: R\$ ${leitura.valorCalculado.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navegar para a tela ExibirConta
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExibirConta(
                        usuario: usuario,
                        leitura: leitura,
                        mesAtual: mesAtual,
                      ),
                    ),
                  );
                },
                child: const Text('Exibir Conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Usuario {
  final String codigo;
  final String nome;

  const Usuario({required this.codigo, required this.nome});
}

class Leitura {
  final double leituraAtual;
  final double leituraAnterior;
  final double valorCalculado;

  const Leitura({
    required this.leituraAtual,
    required this.leituraAnterior,
    required this.valorCalculado,
  });
}
