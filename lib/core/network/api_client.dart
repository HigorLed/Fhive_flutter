import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Erro HTTP convertido em uma mensagem legível para a interface.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode == null
      ? message
      : 'HTTP $statusCode: $message';
}

/// Cliente HTTP único do Fhive.
///
/// Desenvolvimento local:
/// --dart-define=FHIVE_API_BASE_URL=http://IP_DO_BACKEND:3000
///
/// APK de produção com configuração remota:
/// --dart-define=FHIVE_CONFIG_URL=http://IP_PUBLICO/app-config.json
class ApiClient {
  ApiClient._();

  static const String _urlConfigurada = String.fromEnvironment(
    'FHIVE_API_BASE_URL',
  );
  static const String _urlConfiguracaoRemota = String.fromEnvironment(
    'FHIVE_CONFIG_URL',
  );

  static const Duration _timeoutConfiguracao = Duration(seconds: 8);

  static String? _baseUrlRemota;
  static Future<String>? _carregamentoBaseUrl;

  static String? _token;
  static http.Client _http = http.Client();

  /// Permite usar um cliente HTTP falso nos testes de widget.
  static void usarCliente(http.Client cliente) {
    _http = cliente;
    _baseUrlRemota = null;
    _carregamentoBaseUrl = null;
  }

  /// Endereço atualmente conhecido. Antes da primeira chamada remota,
  /// retorna a configuração local/padrão.
  static String get baseUrl {
    if (_urlConfigurada.trim().isNotEmpty) {
      return _normalizarBaseUrl(_urlConfigurada);
    }
    return _baseUrlRemota ?? _baseUrlLocal;
  }

  static String get _baseUrlLocal {
    if (kIsWeb) return 'http://localhost:3000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 10.0.2.2 aponta para o computador host no emulador Android.
        return 'http://10.0.2.2:3000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000';
    }
  }

  static String _normalizarBaseUrl(String valor) =>
      valor.trim().replaceFirst(RegExp(r'/+$'), '');

  /// Resolve a URL de forma assíncrona. Quando FHIVE_CONFIG_URL foi definido
  /// no build, consulta o JSON remoto uma vez e reutiliza o resultado.
  /// A URL antiga FHIVE_API_BASE_URL continua tendo prioridade para testes
  /// locais e desenvolvimento.
  static Future<String> _obterBaseUrl() async {
    if (_urlConfigurada.trim().isNotEmpty) {
      return _normalizarBaseUrl(_urlConfigurada);
    }

    if (_urlConfiguracaoRemota.trim().isEmpty) {
      return _baseUrlLocal;
    }

    if (_baseUrlRemota != null) {
      return _baseUrlRemota!;
    }

    final carregamento = _carregamentoBaseUrl ??= _carregarBaseUrlRemota();

    try {
      final url = await carregamento;
      _baseUrlRemota = url;
      return url;
    } catch (_) {
      // Uma falha temporária não fica armazenada para sempre.
      // A próxima chamada à API poderá tentar carregar a configuração de novo.
      _carregamentoBaseUrl = null;
      rethrow;
    }
  }

  static Future<String> _carregarBaseUrlRemota() async {
    final configuracaoUri = Uri.tryParse(_urlConfiguracaoRemota.trim());
    if (configuracaoUri == null ||
        !const {'http', 'https'}.contains(configuracaoUri.scheme) ||
        configuracaoUri.host.isEmpty) {
      throw const ApiException(
        'A URL de configuração do aplicativo é inválida. '
        'Verifique FHIVE_CONFIG_URL no build do Flutter.',
      );
    }

    late http.Response resposta;
    try {
      resposta = await _http.get(
        configuracaoUri,
        headers: const {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(_timeoutConfiguracao);
    } on TimeoutException {
      throw const ApiException(
        'O servidor demorou para fornecer a configuração do aplicativo. '
        'Verifique sua conexão com a internet.',
      );
    } catch (_) {
      throw const ApiException(
        'Não foi possível acessar a configuração do aplicativo. '
        'Verifique sua conexão com a internet.',
      );
    }

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw ApiException(
        'O servidor não conseguiu fornecer a configuração do aplicativo '
        '(HTTP ${resposta.statusCode}).',
        statusCode: resposta.statusCode,
      );
    }

    dynamic dados;
    try {
      dados = jsonDecode(
        utf8.decode(resposta.bodyBytes, allowMalformed: true),
      );
    } on FormatException {
      throw const ApiException(
        'O arquivo de configuração do aplicativo não contém um JSON válido.',
      );
    }

    if (dados is! Map) {
      throw const ApiException(
        'O arquivo de configuração do aplicativo está em formato inválido.',
      );
    }

    final valorApi = dados['apiBaseUrl'];
    if (valorApi is! String || valorApi.trim().isEmpty) {
      throw const ApiException(
        'O arquivo de configuração não informa o endereço da API (apiBaseUrl).',
      );
    }

    final apiUri = Uri.tryParse(valorApi.trim());
    if (apiUri == null ||
        !const {'http', 'https'}.contains(apiUri.scheme) ||
        apiUri.host.isEmpty) {
      throw const ApiException(
        'O endereço da API informado na configuração é inválido.',
      );
    }

    return _normalizarBaseUrl(valorApi);
  }

  static bool get autenticado => _token != null && _token!.isNotEmpty;

  static void definirToken(String token) {
    _token = token.trim().isEmpty ? null : token.trim();
  }

  static void limparToken() => _token = null;

  static Future<dynamic> get(String path) => _request('GET', path);

  static Future<dynamic> post(
    String path, {
    Object? body,
    Duration timeout = const Duration(seconds: 20),
  }) =>
      _request('POST', path, body: body, timeout: timeout);

  static Future<dynamic> patch(String path, {Object? body}) =>
      _request('PATCH', path, body: body);

  static Future<dynamic> put(String path, {Object? body}) =>
      _request('PUT', path, body: body);

  static Future<dynamic> delete(String path) => _request('DELETE', path);

  static Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final baseUrlResolvida = await _obterBaseUrl();
    final uri = Uri.parse('$baseUrlResolvida$path');
    // Guarda se esta requisição realmente saiu com um JWT.
    // Isso é importante porque o login também pode retornar HTTP 401
    // quando o e-mail ou a senha estão incorretos.
    final tokenEnviado = _token;
    final requisicaoAutenticada =
        tokenEnviado != null && tokenEnviado.isNotEmpty;

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (requisicaoAutenticada) {
      headers['Authorization'] = 'Bearer $tokenEnviado';
    }

    late http.Response response;
    try {
      final requestBody = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          response = await _http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await _http.post(
            uri,
            headers: headers,
            body: requestBody,
          ).timeout(timeout);
          break;
        case 'PATCH':
          response = await _http.patch(
            uri,
            headers: headers,
            body: requestBody,
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await _http.put(
            uri,
            headers: headers,
            body: requestBody,
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await _http.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw ApiException('Método HTTP não suportado: $method.');
      }
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'O backend demorou para responder. Verifique a conexão e tente novamente.',
      );
    } catch (_) {
      throw ApiException(
        'Não foi possível conectar ao backend em $baseUrlResolvida. '
        'Confira se o servidor está ativo e se a URL da API está correta.',
      );
    }

    dynamic dados;
    if (response.bodyBytes.isNotEmpty) {
      final texto = utf8.decode(response.bodyBytes, allowMalformed: true);
      try {
        dados = jsonDecode(texto);
      } on FormatException {
        dados = texto;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String mensagem = 'Falha na requisição (${response.statusCode}).';
      if (dados is Map) {
        final doBackend = dados['mensagem'] ??
            dados['erro'] ??
            dados['message'] ??
            dados['error'];
        if (doBackend is String && doBackend.trim().isNotEmpty) {
          mensagem = doBackend.trim();
        } else if (doBackend is Map) {
          final detalhe = doBackend['message'] ?? doBackend['mensagem'];
          if (detalhe is String && detalhe.trim().isNotEmpty) {
            mensagem = detalhe.trim();
          }
        }
      }
      if (response.statusCode == 401 && requisicaoAutenticada) {
        // Só existe sessão expirada quando uma requisição protegida,
        // enviada com JWT, foi recusada pelo backend.
        mensagem = 'Sua sessão expirou. Entre novamente na sua conta.';

        // Evita limpar um token novo caso outra autenticação tenha ocorrido
        // enquanto esta requisição estava em andamento.
        if (_token == tokenEnviado) {
          _token = null;
        }
      } else if (response.statusCode == 401 && path == '/usuarios/login') {
        // No login, 401 significa falha na autenticação inicial,
        // e não expiração de uma sessão anterior. Preserva a mensagem
        // enviada pelo controller do backend.
        if (mensagem.startsWith('Falha na requisição')) {
          mensagem = 'E-mail ou senha inválidos. Confira os dados e tente novamente.';
        }
      }
      throw ApiException(mensagem, statusCode: response.statusCode);
    }
    return dados;
  }
}
