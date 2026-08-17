import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

var apiUrl = 'https://api.autoleitura.online/postLeituras';

class Leitura extends StatefulWidget {
  final int userId;

  const Leitura({super.key, required this.userId});

  @override
  _LeituraState createState() => _LeituraState();
}

class _LeituraState extends State<Leitura> {
  final leituraController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(''),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
        //centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Insira a leitura abaixo',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: leituraController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Leitura',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              Material(
                color:
                    const Color.fromARGB(255, 15, 76, 129), // Azul mais claro
                borderRadius: BorderRadius.circular(20.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.0),
                  onTap: () async {
                    String leitura = leituraController.text;

                    int leituraInt = int.parse(leitura);

                    try {
                      int userId = widget.userId;

                      final response = await http.post(
                        Uri.parse(apiUrl),
                        body: jsonEncode({
                          'codigo': userId,
                          'leitura': leituraInt,
                        }),
                        headers: {'Content-Type': 'application/json'},
                      );

                      if (response.statusCode == 200) {
                        Map<String, dynamic> data = json.decode(response.body);
                        print(data);
                        if (data.containsKey('code') && data['code'] == 0) {
                          _mostrarDialog(
                              context, 'Leitura inserida com sucesso');
                        } else {
                          _mostrarDialog(context, 'Erro ao inserir leitura');
                        }
                      } else {
                        _mostrarDialog(context,
                            'Erro na requisição: ${response.statusCode}');
                      }
                    } catch (error) {
                      print('Erro ao inserir leitura: $error');
                      _mostrarDialog(context, 'Erro ao inserir leitura');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'Inserir Leitura',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _mostrarDialog(BuildContext context, String mensagem) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Resultado da Inserção'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void main() {
  runApp(const MaterialApp(
    home: Leitura(userId: 1), // Substitua 1 pelo ID do usuário obtido no login
  ));
}
