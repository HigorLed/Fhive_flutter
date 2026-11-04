import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tcc_mobile/core/network/api_client.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';
import 'package:tcc_mobile/features/analytics/presentation/graficos.dart';
import 'package:tcc_mobile/main.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';
import 'package:tcc_mobile/shared/state/preferencias_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

const String emailTeste = 'teste@fhive.com';
const String senhaTeste = 'Fhive@123';

late MockClient _clienteMock;
late Map<String, dynamic> _usuarioMock;
String _senhaMock = senhaTeste;
int _contadorDispositivo = 0;

http.Response _resposta(Object? corpo, {int status = 200}) => http.Response(
  jsonEncode(corpo),
  status,
  headers: const {'content-type': 'application/json; charset=utf-8'},
);

Future<http.Response> _responder(http.Request request) async {
  final path = request.url.path;
  final metodo = request.method;
  final dynamic corpo = request.body.isEmpty ? <String, dynamic>{} : jsonDecode(request.body);
  final dados = corpo is Map ? Map<String, dynamic>.from(corpo) : <String, dynamic>{};

  if (metodo == 'POST' && path == '/usuarios/login') {
    if (dados['email'] != _usuarioMock['email'] || dados['senha'] != _senhaMock) {
      return _resposta({'mensagem': 'E-mail ou senha inválidos.'}, status: 401);
    }
    return _resposta({'token': 'token-de-teste', 'usuario': _usuarioMock});
  }
  if (metodo == 'POST' && path == '/usuarios') {
    _usuarioMock = <String, dynamic>{
      'id': 'user-1', 'nome': dados['nome'], 'email': dados['email'], 'fotoPerfil': null,
    };
    _senhaMock = '${dados['senha'] ?? senhaTeste}';
    return _resposta({'mensagem': 'Código de confirmação enviado.'}, status: 201);
  }
  if (metodo == 'POST' && path == '/usuarios/confirmarEmail') {
    return _resposta({'mensagem': 'E-mail confirmado.'}, status: 201);
  }
  if (metodo == 'GET' && path == '/usuarios/perfil') {
    return _resposta({'usuario': _usuarioMock});
  }
  if (metodo == 'PATCH' && path == '/usuarios/perfil') {
    if (dados['senhaAtual'] != null && dados['senhaAtual'] != _senhaMock) {
      return _resposta({'mensagem': 'A senha atual está incorreta.'}, status: 400);
    }
    if (dados['novaSenha'] is String) _senhaMock = dados['novaSenha'] as String;
    _usuarioMock = <String, dynamic>{
      ..._usuarioMock,
      'nome': dados['nome'] ?? _usuarioMock['nome'],
      'email': dados['email'] ?? _usuarioMock['email'],
      'fotoPerfil': dados['fotoPerfil'] ?? _usuarioMock['fotoPerfil'],
    };
    return _resposta({'usuario': _usuarioMock});
  }
  if (metodo == 'POST' && <String>[
    '/usuarios/esqueci-senha', '/usuarios/verificar-codigo-recuperacao',
    '/usuarios/redefinir-senha',
  ].contains(path)) {
    if (path == '/usuarios/redefinir-senha' && dados['novaSenha'] is String) {
      _senhaMock = dados['novaSenha'] as String;
    }
    return _resposta({'mensagem': 'Operação concluída.'});
  }
  if (metodo == 'GET' && path == '/dispositivos') {
    return _resposta([
      {
        'id': 'mongo-device-tv-1', 'deviceId': 'FH-TV-CRISTAL-001',
        'nome': 'TV - Cristal', 'tipo': 'TV', 'fabricante': 'Fhive',
        'modelo': 'Cristal', 'status': 'online', 'local': 'Sala de Estar', 'conexao': 'Wi-Fi',
      },
      {
        'id': 'mongo-device-ac-1', 'deviceId': 'FH-AC-SALA-001',
        'nome': 'Ar-condicionado', 'tipo': 'Ar condicionado', 'fabricante': 'Fhive',
        'modelo': 'Smart AC', 'status': 'offline', 'local': 'Sala de Estar', 'conexao': 'Wi-Fi',
      },
    ]);
  }
  if (metodo == 'POST' && path == '/dispositivos') {
    _contadorDispositivo++;
    return _resposta({
      'mensagem': 'Dispositivo criado com sucesso.',
      'dispositivo': {
        'id': 'mongo-device-new-$_contadorDispositivo',
        'deviceId': dados['deviceId'] ?? 'FH-TESTE-$_contadorDispositivo',
        'nome': dados['nome'] ?? 'Aparelho de teste', 'tipo': dados['tipo'] ?? 'Sensor',
        'fabricante': dados['fabricante'], 'modelo': dados['modelo'],
        'conexao': dados['conexao'] ?? 'Wi-Fi', 'local': dados['local'] ?? 'Sala de Estar',
        'status': 'offline',
      },
    }, status: 201);
  }
  if (metodo == 'GET' && path.endsWith('/telemetrias')) return _resposta(<dynamic>[]);
  if (metodo == 'GET' && path.startsWith('/dispositivos/')) {
    return _resposta({
      'id': 'mongo-device-tv-1', 'deviceId': 'FH-TV-CRISTAL-001',
      'nome': 'TV - Cristal', 'tipo': 'TV', 'local': 'Sala de Estar', 'status': 'online',
    });
  }
  if (metodo == 'DELETE' && path.startsWith('/dispositivos/')) {
    return _resposta({'mensagem': 'Dispositivo excluído com sucesso.'});
  }
  if (metodo == 'GET' && path == '/rotinas') {
    return _resposta([
      {
        'id': 'routine-1', 'nome': 'Acordar', 'horarioInicial': '07:00',
        'horarioFinal': null, 'diasSemana': {'segunda': true, 'terca': true},
        'acoes': [
          {'ordem': 1, 'horario': '07:00', 'tipo': 'ligar', 'instrucoes': {'estado': true}},
        ], 'ativo': true, 'dispositivo': {
          'id': 'mongo-device-tv-1', 'deviceId': 'FH-TV-CRISTAL-001',
          'nome': 'TV - Cristal', 'local': 'Sala de Estar',
        },
      },
    ]);
  }
  if (metodo == 'POST' && path == '/rotinas') {
    return _resposta({'rotina': {
      'id': 'routine-new', ...dados, 'ativo': true,
      'dispositivo': {'deviceId': dados['dispositivoId'], 'nome': 'TV - Cristal', 'local': 'Sala de Estar'},
    }}, status: 201);
  }
  if (metodo == 'PUT' && path.startsWith('/rotinas/')) {
    return _resposta({'rotina': {'id': path.split('/').last, ...dados}});
  }
  if (metodo == 'DELETE' && path.startsWith('/rotinas/')) {
    return _resposta({'mensagem': 'Rotina excluída.'});
  }
  return _resposta({'mensagem': 'Rota de teste não configurada: $metodo $path'}, status: 404);
}

Future<void> entrarComDadosValidos(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
  await tester.pumpAndSettle();

  final campos = find.byType(TextFormField);
  expect(campos, findsNWidgets(2));
  await tester.enterText(campos.at(0), emailTeste);
  await tester.enterText(campos.at(1), senhaTeste);

  final botao = find.widgetWithText(ElevatedButton, 'Entrar');
  await tester.ensureVisible(botao);
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _usuarioMock = <String, dynamic>{
      'id': 'user-1', 'nome': 'Usuário de Teste', 'email': emailTeste, 'fotoPerfil': null,
    };
    _senhaMock = senhaTeste;
    _contadorDispositivo = 0;
    _clienteMock = MockClient(_responder);
    ApiClient.usarCliente(_clienteMock);
    ApiClient.limparToken();
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

  testWidgets('Login via API abre a Home', (tester) async {
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
    await tester.tap(find.text('Testar conexão'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Etapa 4 de 4'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar aparelho'));
    await tester.pumpAndSettle();

    expect(AparelhosStore.porId('FH-SENSOR-TESTE-001'), isNotNull);
    expect(
      AparelhosStore.porId('FH-SENSOR-TESTE-001')!.status,
      'Offline',
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
    final removerFavorito = find.byTooltip('Remover dos favoritos');
    await tester.ensureVisible(removerFavorito);
    await tester.tap(removerFavorito);
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
    expect(find.text('Limite de energia').first, findsOneWidget);
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

  test('AuthStore cadastra, autentica e atualiza dados via API', () async {
    const email = 'novo@fhive.com';
    const senhaInicial = 'Fhive@123';
    const senhaNova = 'Fhive@456';

    expect(
      await AuthStore.iniciarCadastro(
        nome: 'Pessoa de Teste',
        email: email,
        senha: senhaInicial,
      ),
      isNull,
    );
    expect(await AuthStore.confirmarCadastro(email: email, codigo: '123456'), isNull);
    expect(await AuthStore.entrar(email: email, senha: senhaInicial), isNull);
    expect(AuthStore.usuarioAtual.value?.nome, 'Pessoa de Teste');

    expect(
      await AuthStore.atualizarPerfil(
        nome: 'Nome Atualizado',
        email: 'atualizado@fhive.com',
      ),
      isNull,
    );
    expect(AuthStore.usuarioAtual.value?.nome, 'Nome Atualizado');
    expect(AuthStore.usuarioAtual.value?.email, 'atualizado@fhive.com');

    expect(
      await AuthStore.atualizarSenha(
        senhaAtual: senhaInicial,
        novaSenha: senhaNova,
      ),
      isNull,
    );
    AuthStore.sair();
    expect(await AuthStore.entrar(email: 'atualizado@fhive.com', senha: senhaInicial), isNotNull);
    expect(await AuthStore.entrar(email: 'atualizado@fhive.com', senha: senhaNova), isNull);
  });

  test('Recuperação de senha percorre os endpoints do backend', () async {
    expect(await AuthStore.solicitarRecuperacao(email: emailTeste), isNull);
    expect(
      await AuthStore.verificarCodigoRecuperacao(email: emailTeste, codigo: '123456'),
      isNull,
    );
    expect(
      await AuthStore.redefinirSenha(
        email: emailTeste,
        codigo: '123456',
        novaSenha: 'NovaSenha@123',
      ),
      isNull,
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

  test('Locais vazios não aparecem entre os locais com aparelhos', () {
    expect(AparelhosStore.locaisComAparelhos, isEmpty);
    expect(AparelhosStore.locaisSugeridos, isNot(contains('Outro local')));

    expect(AparelhosStore.locaisDisponiveis, contains('Cozinha'));
    expect(AparelhosStore.locaisComAparelhos, isNot(contains('Cozinha')));

    AparelhosStore.adicionar(
      const AparelhoItem(
        nome: 'Lâmpada cozinha',
        id: 'FH-LAMP-COZ-001',
        tipo: 'Lâmpada',
        fabricante: 'Fhive',
        modelo: 'Smart Light',
        status: 'Offline',
        icone: Icons.lightbulb_outline,
        wifi: true,
        local: 'Cozinha',
        conexao: 'Wi-Fi',
      ),
    );
    expect(
      AparelhosStore.locaisComAparelhos,
      <String>['Cozinha'],
    );
  });

  test('Store de aparelhos cria, edita, favorita e remove por ID', () {
    AparelhosStore.adicionar(
      const AparelhoItem(
        nome: 'TV de teste',
        id: 'FH-TV-CRISTAL-001',
        backendId: 'mongo-device-tv-1',
        tipo: 'TV',
        fabricante: 'Fhive',
        modelo: 'Cristal',
        status: 'Online',
        icone: Icons.tv,
        wifi: true,
        local: 'Sala de Estar',
        conexao: 'Wi-Fi',
      ),
    );
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

  test('Store de rotinas carrega, alterna e remove dados do backend', () async {
    await RotinasStore.carregarDoBackend();
    expect(RotinasStore.rotinas.value.length, 1);
    final rotina = RotinasStore.porId('routine-1');
    expect(rotina?.nome, 'Acordar');
    expect(rotina?.ativa, isTrue);

    await RotinasStore.alternarNoBackend('routine-1');
    expect(RotinasStore.porId('routine-1')!.ativa, isFalse);
    expect(RotinasStore.executar('routine-1'), isFalse);

    await RotinasStore.removerDoBackend('routine-1');
    expect(RotinasStore.porId('routine-1'), isNull);
  });
}
