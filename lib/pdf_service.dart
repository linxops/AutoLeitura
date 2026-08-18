import 'package:autoleitura/models.dart';
import 'pdf_service_stub.dart' if (dart.library.io) 'pdf_service_io.dart' as impl;

Future<void> gerarPdf(Conta conta) => impl.gerarPdf(conta);