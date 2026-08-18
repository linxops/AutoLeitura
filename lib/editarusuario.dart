import 'dart:convert';
import 'package:autoleitura/api.dart';
import 'package:autoleitura/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiUrlCadastrar = '$apiBaseUrl/cadastrar_usuario';
const apiUrlAtualizar = '$apiBaseUrl/atualizar_usuario';

class EditarUsuarioScreen extends StatefulWidget {
  final User? usuario;

  const EditarUsuarioScreen({super.key, this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _localController;
  late final TextEditingController _celularController;
  late final TextEditingController _emailController;
  late final TextEditingController _senhaController;
  late String _role;
  bool _salvando = false;

  bool get _editando => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nomeController = TextEditingController(text: u?.nome ?? '');
    _localController = TextEditingController(text: u?.local ?? '');
    _celularController = TextEditingController(text: u?.celular ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _senhaController = TextEditingController();
    _role = u?.role ?? 'usuario';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _localController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final body = <String, dynamic>{
        'nome': _nomeController.text,
        'local': _localController.text,
        'celular': _celularController.text,
        'email': _emailController.text,
        'role': _role,
      };
      if (_senhaController.text.isNotEmpty) {
        body['senha'] = _senhaController.text;
      }
      if (_editando) {
        body['codigo'] = widget.usuario!.id;
      }
      final response = await http.post(
        Uri.parse(_editando ? apiUrlAtualizar : apiUrlCadastrar),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
      Map<String, dynamic> data = json.decode(response.body);
      if (data['code'] == 1) {
        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }
      if (!mounted) return;
      _mostrarAviso(data['message'] ?? 'Não foi possível salvar');
    } catch (_) {
      if (!mounted) return;
      _mostrarAviso('Erro ao salvar');
    } finally {
      if (mounted) setState(() => _salvando = false);
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
        title: Text(_editando ? 'Alterar Dados' : 'Cadastrar Usuário'),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _localController,
                  decoration: const InputDecoration(
                    labelText: 'Local (1 caractere)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 1,
                  validator: (v) => (v == null || v.trim().length != 1)
                      ? 'Local deve ter 1 caractere'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _celularController,
                  decoration: const InputDecoration(
                    labelText: 'Celular (11 dígitos)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final digitos = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    return digitos.length != 11
                        ? 'Celular deve ter 11 dígitos'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'Papel',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'usuario', child: Text('Usuário')),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'usuario'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _editando
                        ? 'Nova senha (opcional)'
                        : 'Senha',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (_editando && (v == null || v.isEmpty)) return null;
                    if (v == null || v.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Material(
                  color: const Color.fromARGB(255, 15, 76, 129),
                  borderRadius: BorderRadius.circular(20.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: _salvando ? null : _salvar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _salvando ? 'Salvando...' : 'Salvar',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}