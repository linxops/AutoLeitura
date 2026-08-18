import 'dart:convert';
import 'package:autoleitura/api.dart';
import 'package:autoleitura/editarusuario.dart';
import 'package:autoleitura/leitura.dart';
import 'package:autoleitura/minhaconta.dart';
import 'package:autoleitura/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiUrlUsuarios = '$apiBaseUrl/usuario';
const apiUrlCalcularConta = '$apiBaseUrl/calcular_conta';

class AdminHome extends StatefulWidget {
  final User user;

  const AdminHome({super.key, required this.user});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<User> _usuarios = [];
  bool _carregando = true;
  bool _erro = false;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      final response = await http.get(Uri.parse(apiUrlUsuarios));
      if (response.statusCode != 200) {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
      Map<String, dynamic> data = json.decode(response.body);
      List<User> usuarios = [];
      if (data['code'] == 1 && data['result'] is List) {
        usuarios = (data['result'] as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = true;
        _carregando = false;
      });
    }
  }

  List<User> get _filtrados {
    if (_busca.isEmpty) return _usuarios;
    final b = _busca.toLowerCase();
    return _usuarios.where((u) {
      return u.nome.toLowerCase().contains(b) ||
          u.local.toLowerCase().contains(b) ||
          '${u.id}'.contains(b);
    }).toList();
  }

  void _mostrarAcoes(User usuario) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(usuario.nome),
              subtitle: Text(
                'Código ${usuario.id} • Local ${usuario.local} • '
                '${usuario.role}',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Inserir Leitura'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Leitura(
                      userId: usuario.id,
                      nomeUsuario: usuario.nome,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Emitir Conta'),
              onTap: () {
                Navigator.pop(context);
                _emitirConta(usuario);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Alterar Dados'),
              onTap: () async {
                Navigator.pop(context);
                final alterou = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarUsuarioScreen(usuario: usuario),
                  ),
                );
                if (alterou == true) _carregarUsuarios();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _emitirConta(User usuario) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlCalcularConta),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'codigo': usuario.id}),
      );
      if (response.statusCode != 200) {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
      Map<String, dynamic> data = json.decode(response.body);
      if (!mounted) return;
      if (data['code'] == 1 &&
          data['result'] is List &&
          (data['result'] as List).isNotEmpty) {
        final res = (data['result'] as List).first as Map<String, dynamic>;
        final valor = double.tryParse('${res['valorconta']}') ?? 0;
        final mes = res['mesreferencia'] ?? '';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Conta emitida'),
            content: Text(
              'Conta de $mes para ${usuario.nome}: '
              'R\$ ${valor.toStringAsFixed(2)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MinhaConta(user: usuario),
                    ),
                  );
                },
                child: const Text('Ver Conta'),
              ),
            ],
          ),
        );
      } else {
        _mostrarAviso(data['message'] ?? 'Não foi possível emitir a conta');
      }
    } catch (_) {
      if (!mounted) return;
      _mostrarAviso('Erro ao emitir conta');
    }
  }

  void _mostrarAviso(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aviso'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Administração'),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final criou = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditarUsuarioScreen(),
            ),
          );
          if (criou == true) _carregarUsuarios();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Cadastrar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _busca = v),
              decoration: const InputDecoration(
                labelText: 'Buscar usuário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: _buildLista()),
        ],
      ),
    );
  }

  Widget _buildLista() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro) {
      return const Center(child: Text('Erro ao carregar usuários'));
    }
    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      return const Center(child: Text('Nenhum usuário encontrado'));
    }
    return ListView.builder(
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final usuario = filtrados[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(usuario.local)),
            title: Text(usuario.nome),
            subtitle: Text('Código ${usuario.id} • ${usuario.role}'),
            onTap: () => _mostrarAcoes(usuario),
          ),
        );
      },
    );
  }
}