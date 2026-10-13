import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';
import 'package:tcc_mobile/features/analytics/presentation/graficos.dart';
import 'package:tcc_mobile/main.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';
import 'package:tcc_mobile/shared/state/preferencias_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

Future<void> entrarComDadosValidos(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
  await tester.pumpAndSettle();

  final campos = find.byType(TextFormField);
  expect(campos, findsNWidgets(2));
  await tester.enterText(campos.at(0), AuthStore.emailDemonstracao);
  await tester.enterText(campos.at(1), AuthStore.senhaDemonstracao);

  final botao = find.widgetWithText(ElevatedButton, 'Entrar');
  await tester.ensureVisible(botao);
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AparelhosStore.reset();
    RotinasStore.reset();
    AuthStore.reset();
    PreferenciasStore.reset();
  });

  testWidgets('O aplicativo abre na tela inicial de autenticação', (
    tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    expect(find.text('Fhive'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Criar Conta'), findsOneWidget);
  });

  testWidgets('Login local de demonstração abre a Home', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);
    expect(find.text('Minha casa'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
  });

  testWidgets('A barra inferior navega pelas telas principais', (tester) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);

    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();
    expect(find.text('Todos aparelhos'), findsOneWidget);
    expect(find.text('TV - Cristal'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pie_chart));
    await tester.pumpAndSettle();
    expect(find.text('Gráficos disponíveis'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Acordar'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Configurações do Fhive'), findsOneWidget);
  });

  testWidgets('Cadastro IoT percorre as quatro etapas e adiciona o aparelho', (
    tester,
  ) async {
    await tester.pumpWidget(const FhiveApp());
    await tester.pumpAndSettle();
    await entrarComDadosValidos(tester);
    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Criar aparelho'));
    await tester.pumpAndSettle();

    expect(find.text('Etapa 1 de 4'), findsOneWidget);
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Sensor do quarto');
    await tester.enterText(campos.at(1), 'FH-SENSOR-TESTE-001');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Local do aparelho'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Configuração da conexão'), findsNothing);
    expect(find.text('Testar conexão'), findsOneWidget);

    await tester.tap(find.text('Ethernet'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Testar conexão'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Etapa 4 de 4'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar aparelho'));
    await tester.pumpAndSettle();

    expect(AparelhosStore.porId('FH-SENSOR-TESTE-001'), isNotNull);
    expect(
      AparelhosStore.porId('FH-SENSOR-TESTE-001')!.status,
      'Aguardando conexão',
    );
  });

  testWidgets('Favorito aparece na Home e pode ser removido por lá', (
    tester,
  ) async {
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

  testWidgets('Detalhes exibem controles e menu de informações', (
    tester,
  ) async {
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
    expect(find.text('Ligar/Desligar'), findsOneWidget);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Streamings'), findsOneWidget);

    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pumpAndSettle();
    expect(AparelhosStore.favoritos.value, isEmpty);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('menu-informacoes-aparelho')));
    await tester.pumpAndSettle();
    expect(find.text('FH-TV-TESTE-002'), findsOneWidget);
  });

  testWidgets('Cartões de indicadores abrem telas detalhadas próprias', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: TelaGraficosDetalhes(
          tipo: TipoAparelho.tv,
          nomePersonalizado: 'TV Cristal',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Energia'));
    await tester.pumpAndSettle();
    expect(find.text('Gasto diário'), findsOneWidget);
    expect(find.text('Limite de energia'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Uso'));
    await tester.pumpAndSettle();
    expect(find.text('Distribuição do uso'), findsOneWidget);
    expect(find.text('Total de Horas'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pontos de gestão'));
    await tester.pumpAndSettle();
    expect(find.text('Sua pontuação'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Uso ao longo do tempo'));
    await tester.tap(find.text('Uso ao longo do tempo'));
    await tester.pumpAndSettle();
    expect(find.text('Uso ao longo do tempo'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Recomendações'));
    await tester.tap(find.text('Recomendações'));
    await tester.pumpAndSettle();
    expect(find.text('Dicas para economizar'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Eficiência'));
    await tester.tap(find.text('Eficiência'));
    await tester.pumpAndSettle();
    expect(find.text('Índice de eficiência'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Configurações abre Perfil e Ajuda', (tester) async {
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

    await tester.tap(find.text('Ajuda'));
    await tester.pumpAndSettle();
    expect(find.text('Como adicionar um aparelho?'), findsOneWidget);
  });

  test('AuthStore cadastra, autentica e redefine senha localmente', () {
    const email = 'novo@fhive.com';
    const senhaInicial = 'Fhive@123';
    const senhaNova = 'Fhive@456';

    expect(
      AuthStore.cadastrar(
        nome: 'Pessoa de Teste',
        email: email,
        senha: senhaInicial,
      ),
      isNull,
    );
    expect(AuthStore.entrar(email: email, senha: senhaInicial), isNull);
    expect(AuthStore.usuarioAtual.value?.nome, 'Pessoa de Teste');
    expect(AuthStore.atualizarNome('Nome Atualizado'), isTrue);
    expect(AuthStore.usuarioAtual.value?.nome, 'Nome Atualizado');
    expect(
      AuthStore.redefinirSenha(email: email, novaSenha: senhaNova),
      isTrue,
    );
    expect(AuthStore.entrar(email: email, senha: senhaInicial), isNotNull);
    expect(AuthStore.entrar(email: email, senha: senhaNova), isNull);
    expect(
      AuthStore.cadastrar(nome: 'Duplicado', email: email, senha: senhaInicial),
      isNotNull,
    );
  });

  test('Perfil local permite alterar nome, e-mail e senha com validação', () {
    expect(
      AuthStore.entrar(
        email: AuthStore.emailDemonstracao,
        senha: AuthStore.senhaDemonstracao,
      ),
      isNull,
    );

    expect(
      AuthStore.atualizarPerfil(
        nome: 'Higor Teste',
        email: 'higor.teste@fhive.com',
      ),
      isNull,
    );
    expect(AuthStore.usuarioAtual.value?.nome, 'Higor Teste');
    expect(AuthStore.usuarioAtual.value?.email, 'higor.teste@fhive.com');

    expect(
      AuthStore.atualizarSenha(
        senhaAtual: AuthStore.senhaDemonstracao,
        novaSenha: 'NovaSenha@123',
      ),
      isNull,
    );
    expect(
      AuthStore.atualizarSenha(
        senhaAtual: 'senha-incorreta',
        novaSenha: 'OutraSenha@123',
      ),
      isNotNull,
    );
  });

  test('Preferências locais mantêm as escolhas até serem reiniciadas', () {
    PreferenciasStore.notificacoes = false;
    PreferenciasStore.sincronizarFavoritos = false;
    PreferenciasStore.sugestoes = false;

    expect(PreferenciasStore.notificacoes, isFalse);
    expect(PreferenciasStore.sincronizarFavoritos, isFalse);
    expect(PreferenciasStore.sugestoes, isFalse);

    PreferenciasStore.reset();
    expect(PreferenciasStore.notificacoes, isTrue);
    expect(PreferenciasStore.sincronizarFavoritos, isTrue);
    expect(PreferenciasStore.sugestoes, isTrue);
  });

  test('Store de aparelhos cria, edita, favorita e remove por ID', () {
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

  test('Store de rotinas adiciona, alterna, registra execução e remove', () {
    expect(RotinasStore.rotinas.value.length, 4);
    final nova = RotinasStore.adicionar(
      nome: 'Teste',
      local: 'Sala de Estar',
      horario: '18:00',
      acoes: const ['Ligar TV'],
    )!;

    expect(RotinasStore.alternar(nova.id), isTrue);
    expect(RotinasStore.porId(nova.id)!.ativa, isFalse);
    expect(RotinasStore.executar(nova.id), isFalse);
    RotinasStore.alternar(nova.id);
    expect(RotinasStore.executar(nova.id), isTrue);
    expect(RotinasStore.porId(nova.id)!.ultimaExecucao, isNotNull);
    expect(RotinasStore.remover(nova.id), isTrue);
    expect(RotinasStore.porId(nova.id), isNull);
  });
}
