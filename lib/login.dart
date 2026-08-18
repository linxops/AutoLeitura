import 'dart:convert';
import 'package:autoleitura/adminhome.dart';
import 'package:autoleitura/api.dart';
import 'package:autoleitura/models.dart';
import 'package:autoleitura/usuariohome.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';

const apiUrl = '$apiBaseUrl/login';

class UserModel extends Model {
  late User _currentUser;

  User get currentUser => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}

class LoginModel extends Model {
  late UserModel _userModel;

  UserModel get userModel => _userModel;

  LoginModel(UserModel userModel) {
    _userModel = userModel;
  }

  Future<User?> login(int codigo, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'codigo': codigo, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('code') && data['code'] == 1) {
          List<dynamic> users = data['result'];

          if (users.isNotEmpty) {
            User user = User.fromJson(users.first);
            _userModel.setCurrentUser(user);
            return user;
          } else {
            throw Exception('Usuário não encontrado');
          }
        } else {
          String message = data['message'] ?? 'Falha no login';
          throw Exception(message);
        }
      } else {
        throw Exception('Erro ao realizar login: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro ao realizar login: $error');
    }
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final codigoUsuarioController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<LoginModel>(
      model: LoginModel(UserModel()),
      child: ScopedModelDescendant<LoginModel>(
        builder: (context, child, model) => Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text(''),
            backgroundColor: const Color.fromARGB(255, 217, 230, 247),
          ),
          backgroundColor: const Color.fromARGB(255, 217, 230, 247),
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Coloque seu código aqui',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: codigoUsuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Código Único de Usuário',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Material(
                    color: const Color.fromARGB(
                        255, 15, 76, 129), // Azul mais claro
                    borderRadius: BorderRadius.circular(20.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.0),
                      onTap: () async {
                        String idString = codigoUsuarioController.text;
                        String senha = senhaController.text;

                        try {
                          int id = int.parse(idString);
                          User? user = await model.login(id, senha);

                          if (user != null) {
                            _mostrarDialog(
                              context,
                              'Login válido. Nome: ${user.nome}',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => user.role == 'admin'
                                        ? AdminHome(user: user)
                                        : UsuarioHome(user: user),
                                  ),
                                );
                              },
                            );
                          } else {
                            _mostrarDialog(context, 'Usuário não encontrado');
                          }
                        } catch (error) {
                          if (kDebugMode) {
                            print('Erro ao validar código: $error');
                          }
                          _mostrarDialog(context, 'Código inválido');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'Enviar para Validação',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _mostrarDialog(BuildContext context, String mensagem,
    [VoidCallback? onPressed]) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Resultado da Validação'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onPressed != null) {
                onPressed();
              }
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
    home: Login(),
  ));
}
