import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tcc_mobile/core/models/usuario.dart';

import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const _tokenKey = 'fhive_token';
  static const _usuarioKey = 'fhive_usuario';

  final http.Client _client;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Uri _url(String path) {
    return Uri.parse('${ApiConfig.baseUrl}$path');
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final response = await _client
        .post(
          _url('/usuarios'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nome': nome.trim(),
            'email': email.trim(),
            'senha': senha,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw _tratarErro(response);
    }
  }

  Future<Usuario> login({required String email, required String senha}) async {
    final response = await _client
        .post(
          _url('/usuarios/login'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email.trim(), 'senha': senha}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw _tratarErro(response);
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final token = body['token']?.toString();
      final dadosUsuario = body['usuario'];

      if (token == null || token.isEmpty || dadosUsuario is! Map) {
        throw const ApiException('Resposta de login inválida.');
      }

      final usuario = Usuario.fromJson(Map<String, dynamic>.from(dadosUsuario));

      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(
        key: _usuarioKey,
        value: jsonEncode(usuario.toJson()),
      );

      return usuario;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Resposta de login inválida.');
    }
  }

  Future<String?> obterToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<Usuario?> obterUsuario() async {
    final dados = await _storage.read(key: _usuarioKey);

    if (dados == null || dados.isEmpty) {
      return null;
    }

    try {
      return Usuario.fromJson(Map<String, dynamic>.from(jsonDecode(dados)));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> cabecalhoAutenticado() async {
    final token = await obterToken();

    if (token == null || token.isEmpty) {
      throw const ApiException('Usuário não autenticado.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usuarioKey);
  }

  ApiException _tratarErro(http.Response response) {
    String mensagem = 'Não foi possível conectar ao servidor.';

    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final valor = body['mensagem'] ?? body['erro'];
        if (valor is String && valor.trim().isNotEmpty) {
          mensagem = valor;
        }
      }
    } catch (_) {}

    return ApiException(mensagem, statusCode: response.statusCode);
  }
}
