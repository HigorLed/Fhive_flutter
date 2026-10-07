import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tcc_mobile/main.dart';

Future<void> entrarComDadosValidos(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
  await tester.pumpAndSettle();

  final campos = find.byType(TextFormField);
  expect(campos, findsNWidgets(2));

  await tester.enterText(campos.at(0), 'teste@fhive.com');
  await tester.enterText(campos.at(1), '123456');

  final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');

  // Garante que o botão esteja visível antes do toque, mesmo em
  // ambientes de teste com altura reduzida. O ensureVisible usa o
  // Scrollable ancestral correto do widget.
  await tester.ensureVisible(botaoEntrar);
  await tester.pumpAndSettle();
  await tester.tap(botaoEntrar);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('O app abre na tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    expect(find.text('Fhive'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Criar Conta'), findsOneWidget);
  });

  testWidgets('Tela inicial > Entrar leva para Home após login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await entrarComDadosValidos(tester);

    expect(find.text('Minha casa'), findsOneWidget);
    expect(find.text('Painel'), findsOneWidget);
  });

  testWidgets('A barra inferior leva para a tela de aparelhos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();

    expect(find.text('Todos aparelhos'), findsOneWidget);
  });

  testWidgets('Tela inicial > Criar Conta abre a tela de cadastro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Conta'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });

  testWidgets('Configurações > Entrar abre o login e valida os campos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);

    final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.ensureVisible(botaoEntrar);
    await tester.pumpAndSettle();
    await tester.tap(botaoEntrar);
    await tester.pumpAndSettle();

    expect(find.text('Digite seu email'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is InputDecorator &&
            widget.decoration.errorText == 'Digite sua senha',
      ),
      findsOneWidget,
    );
  });
}
