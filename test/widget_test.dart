import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tcc_mobile/main.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

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
  setUp(() {
    AparelhosStore.reset();
  });

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

  testWidgets('Cadastro IoT pede nome e ID e permite revisar o dispositivo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('Nome do dispositivo'), findsOneWidget);
    expect(find.text('ID do dispositivo'), findsOneWidget);
    expect(find.text('Etapa 1 de 4'), findsOneWidget);

    final camposIdentificacao = find.byType(TextFormField);
    expect(camposIdentificacao, findsNWidgets(2));
    await tester.enterText(camposIdentificacao.at(0), 'Sensor do quarto');
    await tester.enterText(camposIdentificacao.at(1), 'FH-SENSOR-TESTE-001');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Tipo de aparelho'), findsOneWidget);
    expect(find.text('Fabricante'), findsOneWidget);
    expect(find.text('Local do aparelho'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Configure a conexão'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('Bluetooth'), findsOneWidget);
    expect(find.text('Ethernet'), findsOneWidget);

    await tester.tap(find.text('Ethernet'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Revise o cadastro'), findsOneWidget);
    expect(find.text('FH-SENSOR-TESTE-001'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Adicionar aparelho'), findsOneWidget);
  });


  testWidgets('A seta do local recolhe os aparelhos da seção', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await entrarComDadosValidos(tester);
    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsOneWidget);
    expect(find.text('Ar condicionado'), findsOneWidget);

    final cabecalhoLocal = find.ancestor(
      of: find.text('Sala de Estar'),
      matching: find.byType(InkWell),
    ).first;

    final setaLocal = find.descendant(
      of: cabecalhoLocal,
      matching: find.byIcon(Icons.keyboard_arrow_up),
    );
    expect(setaLocal, findsOneWidget);
    await tester.tap(setaLocal);
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsNothing);
    expect(find.text('Ar condicionado'), findsNothing);

    final setaLocalFechado = find.descendant(
      of: cabecalhoLocal,
      matching: find.byIcon(Icons.keyboard_arrow_down),
    );
    expect(setaLocalFechado, findsOneWidget);
    await tester.tap(setaLocalFechado);
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsOneWidget);
    expect(find.text('Ar condicionado'), findsOneWidget);
  });

  testWidgets('Favorito na Home abre diretamente a tela de opções do aparelho', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await entrarComDadosValidos(tester);
    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Início'));
    await tester.pumpAndSettle();

    expect(find.text('Favoritos'), findsOneWidget);
    await tester.tap(find.text('TV - Cristal'));
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsOneWidget);
    expect(find.text('Ligar/Desligar'), findsOneWidget);
    expect(find.text('Streamings'), findsOneWidget);
    expect(find.text('Minha casa'), findsNothing);
  });

  testWidgets('Detalhes do aparelho mudam conforme o tipo cadastrado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TelaDetalhesAparelho(
          nome: 'TV da sala',
          id: 'FH-TV-TESTE-001',
          tipo: 'TV',
          fabricante: 'Fhive',
          modelo: 'Cristal',
          local: 'Sala de Estar',
          conexao: 'Wi-Fi',
          status: 'Online',
          icone: Icons.tv,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TV da sala'), findsOneWidget);
    expect(find.text('Ligar/Desligar'), findsOneWidget);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Streamings'), findsOneWidget);
    expect(find.text('Temperatura'), findsNothing);
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
