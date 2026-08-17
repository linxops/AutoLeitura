import 'package:autoleitura/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autoleitura/login.dart';
import 'package:autoleitura/leitura.dart';

void main() {
  testWidgets('Teste Home', (WidgetTester tester) async {
    // Construir nossa tela Home e acionar um frame.
    await tester.pumpWidget(const MaterialApp(home: Home()));

    // Aguardar a árvore de widgets se estabilizar.
    await tester.pumpAndSettle();

    // Verificar se o texto de boas-vindas está presente.
    expect(
        find.text('Seja Bem-Vindo ao sistema de Auto Leitura'), findsOneWidget);

    // Localizar o botão pelo texto.
    final buttonFinder = find.text('Clique para inserir seu código');
    expect(buttonFinder, findsOneWidget);

    // Tocar no botão.
    await tester.tap(buttonFinder);

    // Aguardar a árvore de widgets se estabilizar.
    await tester.pumpAndSettle();

    // Verificar se a tela de login está presente.
    expect(find.byType(Login), findsOneWidget);
  });

  testWidgets('Teste de Login', (WidgetTester tester) async {
    // Construir nossa tela Login e acionar um frame.
    await tester.pumpWidget(const MaterialApp(home: Login()));

    // Aguardar a árvore de widgets se estabilizar.
    await tester.pumpAndSettle();

    // Verificar se o texto de boas-vindas está presente.
    expect(find.text('Coloque seu código aqui'), findsOneWidget);

    // Preencher o campo de código com '1234'.
    await tester.enterText(find.byType(TextFormField), '1');

    // Verificar se o botão está presente.
    expect(find.text('Enviar para Validação'), findsOneWidget);

    // Tocar no botão.
    await tester.tap(find.text('Enviar para Validação'));

    // Aguardar a árvore de widgets se estabilizar.
    await tester.pumpAndSettle();

    // Verificar se o diálogo está presente.
    expect(find.text('Confira seu código'), findsOneWidget);

    // Tocar no botão 'Validar' no diálogo.
    await tester.tap(find.text('Validar'));

    // Aguardar a árvore de widgets se estabilizar.
    await tester.pumpAndSettle();

    // Verificar se a tela de leitura está presente.
    expect(find.byType(Leitura), findsOneWidget);
  });
}
