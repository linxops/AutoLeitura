import 'package:autoleitura/gerarpdf.dart';
import 'package:autoleitura/models.dart';
import 'package:flutter/material.dart';

class ContaDetalhe extends StatelessWidget {
  final Conta conta;

  const ContaDetalhe({super.key, required this.conta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('AUTOLEITURA - Conta'),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _bloco([
                const Text(
                  'Conta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Mês de Referência: ${conta.mesReferencia}'),
                Text('Data de Emissão: ${conta.dataEmissao}'),
                Text('Data de Vencimento: ${conta.dataVencimento}'),
              ]),
              const SizedBox(height: 10),
              _bloco([
                Text('Nome: ${conta.nome}'),
                Text('Código: ${conta.id}'),
                Text('Local: ${conta.local}'),
              ]),
              const SizedBox(height: 10),
              _bloco([
                Text('Leitura Atual: ${conta.leituraAtual}'),
                Text('Leitura Anterior: ${conta.leituraAnterior}'),
                Text('Consumo: ${conta.leituraAtual - conta.leituraAnterior} m³'),
              ]),
              const SizedBox(height: 10),
              _bloco([
                Text(
                  'Valor do Metro Cúbico: R\$ '
                  '${conta.valorMetroCubico.toStringAsFixed(2)}',
                ),
                Text(
                  'Valor da Conta: R\$ ${conta.valorConta.toStringAsFixed(2)}',
                ),
                if (conta.mensagem.isNotEmpty) Text(conta.mensagem),
              ]),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GerarPDFScreen(conta: conta),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text('Gerar PDF'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pagamento em breve')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text('Pagar Conta'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bloco(List<Widget> filhos) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(border: Border.all(width: 2.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filhos,
      ),
    );
  }
}