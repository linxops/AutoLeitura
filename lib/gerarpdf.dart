import 'dart:io' as io;
import 'package:autoleitura/exibirdetalhes.dart';
// ignore: unused_import
import 'package:autoleitura/leitura.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class GerarPDFScreen extends StatelessWidget {
  final Usuario usuario;
  final leitura;
  final String mesAtual;

  GerarPDFScreen({
    super.key,
    required this.usuario,
    required this.leitura,
    required this.mesAtual,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AUTOLEITURA - Gerar PDF'),
        backgroundColor: const Color.fromARGB(255, 0, 5, 8),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _gerarPDF();
          },
          child: const Text('Gerar PDF'),
        ),
      ),
    );
  }

  void _gerarPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildContaSection(),
            _buildUserInfoSection(),
            _buildLeituraSection(),
            _buildValorSection(),
          ],
        ),
      ),
    );

    // Salva o PDF em um arquivo temporário
    final file = await _savePDF(pdf);

    // Abre o arquivo PDF
    OpenFile.open(file.path);
  }

  pw.Widget _buildContaSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Text(
        'Conta',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildUserInfoSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildText('Nome: ${usuario.nome}'),
          _buildText('Código: ${usuario.codigo}'),
        ],
      ),
    );
  }

  pw.Widget _buildLeituraSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildText(
              'Leitura Atual: ${leitura.leituraAtual.toStringAsFixed(2)}'),
          _buildText(
              'Leitura Anterior: ${leitura.leituraAnterior.toStringAsFixed(2)}'),
          _buildText('Mês Atual: $mesAtual'),
        ],
      ),
    );
  }

  pw.Widget _buildValorSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildText('Valor do Metro Cúbico: R\$ 1.15'),
          _buildText(
              'Valor Calculado: R\$ ${leitura.valorCalculado.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  pw.Text _buildText(String text) {
    return pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 16),
    );
  }

  Future<io.File> _savePDF(pw.Document pdf) async {
    final file = io.File('${DateTime.now().millisecondsSinceEpoch}_conta.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
