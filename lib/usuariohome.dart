import 'package:autoleitura/leitura.dart';
import 'package:autoleitura/minhaconta.dart';
import 'package:autoleitura/models.dart';
import 'package:flutter/material.dart';

class UsuarioHome extends StatelessWidget {
  final User user;

  const UsuarioHome({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(''),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                'Olá, ${user.nome}!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'O que deseja fazer?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _MenuButton(
                icon: Icons.edit_note,
                label: 'Inserir Leitura',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Leitura(
                        userId: user.id,
                        nomeUsuario: user.nome,
                      ),
                    ),
                  );
                },
              ),
              _MenuButton(
                icon: Icons.receipt_long,
                label: 'Ver Minha Conta',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MinhaConta(user: user),
                    ),
                  );
                },
              ),
              _MenuButton(
                icon: Icons.person,
                label: 'Meus Dados',
                onTap: () {
                  _mostrarDados(context);
                },
              ),
              _MenuButton(
                icon: Icons.logout,
                label: 'Sair',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDados(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Meus Dados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Código: ${user.id}'),
              Text('Nome: ${user.nome}'),
              Text('Local: ${user.local}'),
              Text('Celular: ${user.celular}'),
              Text('E-mail: ${user.email}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: const Color.fromARGB(255, 15, 76, 129),
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}