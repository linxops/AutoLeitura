import 'dart:io' as io;
import 'package:autoleitura/models.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> gerarPdf(Conta conta) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Conta',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Nome: ${conta.nome}'),
          pw.Text('Código: ${conta.id}'),
          pw.Text('Local: ${conta.local}'),
          pw.SizedBox(height: 8),
          pw.Text('Mês de Referência: ${conta.mesReferencia}'),
          pw.Text('Data de Emissão: ${conta.dataEmissao}'),
          pw.Text('Data de Vencimento: ${conta.dataVencimento}'),
          pw.SizedBox(height: 8),
          pw.Text('Leitura Atual: ${conta.leituraAtual}'),
          pw.Text('Leitura Anterior: ${conta.leituraAnterior}'),
          pw.Text('Consumo: ${conta.leituraAtual - conta.leituraAnterior} m³'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Valor do Metro Cúbico: R\$ '
            '${conta.valorMetroCubico.toStringAsFixed(2)}',
          ),
          pw.Text(
            'Valor da Conta: R\$ ${conta.valorConta.toStringAsFixed(2)}',
          ),
          if (conta.mensagem.isNotEmpty) pw.Text(conta.mensagem),
        ],
      ),
    ),
  );

  final dir = await io.Directory.systemTemp.createTemp('autoleitura_pdf');
  final file = io.File('${dir.path}/conta_${conta.id}.pdf');
  await file.writeAsBytes(await pdf.save());
  OpenFile.open(file.path);
}