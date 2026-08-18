import 'dart:convert';
import 'package:autoleitura/api.dart';
import 'package:autoleitura/contadetalhe.dart';
import 'package:autoleitura/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiUrl = '$apiBaseUrl/exibir_conta';

class MinhaConta extends StatefulWidget {
  final User user;

  const MinhaConta({super.key, required this.user});

  @override
  State<MinhaConta> createState() => _MinhaContaState();
}

class _MinhaContaState extends State<MinhaConta> {
  late Future<List<Conta>> _contas;

  @override
  void initState() {
    super.initState();
    _contas = _buscarContas();
  }

  Future<List<Conta>> _buscarContas() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'codigo': widget.user.id}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
    Map<String, dynamic> data = json.decode(response.body);
    if (data['code'] == 1 && data['result'] is List) {
      return (data['result'] as List)
          .map((e) => Conta.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Minhas Contas'),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      body: FutureBuilder<List<Conta>>(
        future: _contas,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao buscar contas'));
          }
          final contas = snapshot.data ?? [];
          if (contas.isEmpty) {
            return const Center(child: Text('Nenhuma conta emitida ainda'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contas.length,
            itemBuilder: (context, index) {
              final conta = contas[index];
              return Card(
                child: ListTile(
                  title: Text(
                    '${conta.mesReferencia} — '
                    'R\$ ${conta.valorConta.toStringAsFixed(2)}',
                  ),
                  subtitle: Text('Vencimento: ${conta.dataVencimento}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContaDetalhe(conta: conta),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}