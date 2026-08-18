import 'package:autoleitura/home.dart';
import 'package:autoleitura/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Teste Home', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));
    await tester.pumpAndSettle();

    final buttonFinder = find.text('Clique para inserir seu código');
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(Login), findsOneWidget);
  });

  testWidgets('Teste de Login', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Login()));
    await tester.pumpAndSettle();

    expect(find.text('Coloque seu código aqui'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Enviar para Validação'), findsOneWidget);
  });
}