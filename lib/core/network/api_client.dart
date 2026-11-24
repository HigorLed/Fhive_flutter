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

/// Cliente HTTP único do Fhive. Configure a URL com
/// --dart-define=FHIVE_API_BASE_URL=http://IP_DO_SERVIDOR:3000.
class ApiClient {
  ApiClient._();

  static const String _urlConfigurada = String.fromEnvironment(
    'FHIVE_API_BASE_URL',
  );
  static String? _token;
  static http.Client _http = http.Client();

  /// Permite usar um cliente HTTP falso nos testes de widget.
  static void usarCliente(http.Client cliente) {
    _http = cliente;
  }

  static String get baseUrl {
    if (_urlConfigurada.trim().isNotEmpty) {
      return _urlConfigurada.trim().replaceFirst(RegExp(r'/+$'), '');
    }

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
    final uri = Uri.parse('$baseUrl$path');
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
    } catch (error) {
      throw ApiException(
        'Não foi possível conectar ao backend em $baseUrl. '
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
