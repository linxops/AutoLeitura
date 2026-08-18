import 'package:autoleitura/models.dart';
import 'package:autoleitura/pdf_service.dart';
import 'package:flutter/material.dart';

class GerarPDFScreen extends StatelessWidget {
  final Conta conta;

  const GerarPDFScreen({super.key, required this.conta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('AUTOLEITURA - Gerar PDF'),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _gerarPDF(context),
          child: const Text('Gerar PDF'),
        ),
      ),
    );
  }

  Future<void> _gerarPDF(BuildContext context) async {
    try {
      await gerarPdf(conta);
    } catch (_) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aviso'),
          content: const Text(
            'Geração de PDF disponível apenas no Android.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}