import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';
import 'package:tcc_mobile/main.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

Future<void> entrarComDadosValidos(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
  await tester.pumpAndSettle();

  final campos = find.byType(TextFormField);
  expect(campos, findsNWidgets(2));

  await tester.enterText(campos.at(0), 'teste@fhive.com');
  await tester.enterText(campos.at(1), '123456');

  final botao = find.widgetWithText(ElevatedButton, 'Entrar');
  await tester.ensureVisible(botao);
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AparelhosStore.reset();
    RotinasStore.reset();
  });

  testWidgets('O app abre na tela inicial', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    expect(find.text('Fhive'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Criar Conta'), findsOneWidget);
  });

  testWidgets('Login abre a Home', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();

    await entrarComDadosValidos(tester);

    expect(find.text('Minha casa'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
  });

  testWidgets('Navegação inferior abre Aparelhos, Gráficos e Rotinas', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();
    expect(find.text('Aparelho'), findsNothing);
    expect(find.textContaining('2 aparelhos'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pie_chart));
    await tester.pumpAndSettle();
    expect(find.text('Aparelhos monitorados'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Suas rotinas'), findsOneWidget);
  });

  testWidgets('Cadastro IoT percorre identificação, conexão e revisão', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Nome do dispositivo'), findsOneWidget);
    expect(find.text('ID do dispositivo'), findsOneWidget);
    expect(find.text('Etapa 1 de 4'), findsOneWidget);

    final campos = find.byType(TextFormField);
    expect(campos, findsNWidgets(2));
    await tester.enterText(campos.at(0), 'Sensor do quarto');
    await tester.enterText(campos.at(1), 'FH-SENSOR-TESTE-001');

    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Fabricante'), findsOneWidget);
    expect(find.text('Local do aparelho'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Testar conexão'), findsOneWidget);

    await tester.tap(find.text('Ethernet'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Testar conexão'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Etapa 4 de 4'), findsOneWidget);
    expect(find.text('FH-SENSOR-TESTE-001'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Adicionar aparelho'), findsOneWidget);
  });

  testWidgets('A seta de local expande e recolhe os aparelhos', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsOneWidget);
    expect(find.text('Ar condicionado'), findsOneWidget);

    final cabecalho = find.ancestor(
      of: find.text('Sala de Estar'),
      matching: find.byType(InkWell),
    ).first;

    await tester.tap(cabecalho);
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsNothing);
    expect(find.text('Ar condicionado'), findsNothing);

    await tester.tap(cabecalho);
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsOneWidget);
  });

  testWidgets('Favorito pode ser removido diretamente na Home', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Adicionar aos favoritos').first);
    await tester.pumpAndSettle();
    expect(AparelhosStore.favoritosLista.length, 1);

    await tester.tap(find.bySemanticsLabel('Início'));
    await tester.pumpAndSettle();

    expect(find.text('TV - Cristal'), findsOneWidget);
    await tester.tap(find.byTooltip('Remover dos favoritos'));
    await tester.pumpAndSettle();

    expect(AparelhosStore.favoritosLista, isEmpty);
    expect(find.text('Ainda não há favoritos.'), findsOneWidget);
  });

  testWidgets('Favorito abre diretamente as opções do aparelho', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);

    AparelhosStore.alternarFavorito('FH-TV-CRISTAL-001');
    await tester.tap(find.bySemanticsLabel('Início'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('TV - Cristal'));
    await tester.pumpAndSettle();

    expect(find.text('Ligar/Desligar'), findsOneWidget);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Streamings'), findsOneWidget);
    expect(find.text('Minha casa'), findsNothing);
  });

  testWidgets('Detalhes mudam conforme o tipo cadastrado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TelaDetalhesAparelho(
          nome: 'Ar da sala',
          id: 'FH-AC-TESTE-001',
          tipo: 'Ar condicionado',
          fabricante: 'Fhive',
          modelo: 'Smart Air',
          local: 'Sala de Estar',
          conexao: 'Wi-Fi',
          status: 'Online',
          icone: Icons.air,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ar da sala'), findsOneWidget);
    expect(find.text('Ligar/Desligar'), findsOneWidget);
    expect(find.text('Temperatura'), findsOneWidget);
    expect(find.text('Velocidade'), findsOneWidget);
  });

  testWidgets('A tela de detalhes permite favoritar e abrir informações', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TelaDetalhesAparelho(
          nome: 'TV Teste',
          id: 'FH-TV-TESTE-002',
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

    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pumpAndSettle();
    expect(AparelhosStore.favoritos.value, isEmpty);

    // A tela independente não possui o aparelho no store; o teste verifica
    // que a ação é segura mesmo quando o registro não está cadastrado.
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('menu-informacoes-aparelho')));
    await tester.pumpAndSettle();
    expect(find.text('FH-TV-TESTE-002'), findsOneWidget);
  });

  testWidgets('Configurações abre as telas de conta e ajuda', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Minha conta'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);

    await tester.tap(find.text('Ajuda'));
    await tester.pumpAndSettle();
    expect(find.text('Como adicionar um aparelho?'), findsOneWidget);
  });


  test('Store de aparelhos cria, edita, favorita e remove', () {
    final original = AparelhosStore.porId('FH-TV-CRISTAL-001');
    expect(original, isNotNull);

    AparelhosStore.alternarFavorito(original!.id);
    expect(AparelhosStore.ehFavorito(original.id), isTrue);

    final alterado = original.copyWith(
      nome: 'TV Principal',
      id: 'FH-TV-CRISTAL-999',
      local: 'Quarto',
    );
    AparelhosStore.atualizar(alterado, idAnterior: original.id);

    expect(AparelhosStore.porId('FH-TV-CRISTAL-999')!.nome, 'TV Principal');
    expect(AparelhosStore.ehFavorito('FH-TV-CRISTAL-999'), isTrue);

    AparelhosStore.removerPorId('FH-TV-CRISTAL-999');
    expect(AparelhosStore.porId('FH-TV-CRISTAL-999'), isNull);
    expect(AparelhosStore.ehFavorito('FH-TV-CRISTAL-999'), isFalse);
  });

  test('Store de rotinas adiciona, executa, alterna e remove', () {
    expect(RotinasStore.rotinas.value.length, 4);

    RotinasStore.adicionar(
      nome: 'Teste',
      local: 'Sala de Estar',
      horario: '18:00',
      acoes: ['Ligar TV'],
    );
    final nova = RotinasStore.rotinas.value.last;

    RotinasStore.alternar(nova.id);
    expect(RotinasStore.porId(nova.id)!.ativa, isFalse);

    RotinasStore.executar(nova.id);
    expect(RotinasStore.porId(nova.id)!.ultimaExecucao, isNotNull);

    RotinasStore.remover(nova.id);
    expect(RotinasStore.porId(nova.id), isNull);
  });
}
