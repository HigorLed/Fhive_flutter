import 'package:tcc_mobile/core/network/api_client.dart';

class AuthApi {
  AuthApi._();

  static Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async => _map(await ApiClient.post('/usuarios', body: {
    'nome': nome.trim(),
    'email': email.trim().toLowerCase(),
    'senha': senha,
  }));

  static Future<Map<String, dynamic>> confirmarCadastro({
    required String email,
    required String codigo,
  }) async => _map(await ApiClient.post('/usuarios/confirmarEmail', body: {
    'email': email.trim().toLowerCase(),
    'codigo': codigo.trim(),
  }));

  static Future<Map<String, dynamic>> entrar({
    required String email,
    required String senha,
  }) async => _map(await ApiClient.post('/usuarios/login', body: {
    'email': email.trim().toLowerCase(),
    'senha': senha,
  }));

  static Future<Map<String, dynamic>> perfil() async =>
      _map(await ApiClient.get('/usuarios/perfil'));

  static Future<Map<String, dynamic>> atualizarPerfil({
    required String nome,
    required String email,
    String? fotoPerfil,
    String? senhaAtual,
    String? novaSenha,
  }) async => _map(await ApiClient.patch('/usuarios/perfil', body: {
    'nome': nome.trim(),
    'email': email.trim().toLowerCase(),
    'fotoPerfil': ?fotoPerfil,
    'senhaAtual': ?senhaAtual,
    'novaSenha': ?novaSenha,
  }));

  static Future<List<dynamic>> listarUsuarios() async {
    final resposta = await ApiClient.get('/usuarios');
    if (resposta is List) return resposta;
    throw const ApiException('A resposta de usuários veio em formato inválido.');
  }

  static Future<Map<String, dynamic>> solicitarRecuperacao({
    required String email,
  }) async => _map(await ApiClient.post('/usuarios/esqueci-senha', body: {
    'email': email.trim().toLowerCase(),
  }));

  static Future<Map<String, dynamic>> verificarCodigoRecuperacao({
    required String email,
    required String codigo,
  }) async => _map(await ApiClient.post(
    '/usuarios/verificar-codigo-recuperacao',
    body: {'email': email.trim().toLowerCase(), 'codigo': codigo.trim()},
  ));

  static Future<Map<String, dynamic>> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async => _map(await ApiClient.post('/usuarios/redefinir-senha', body: {
    'email': email.trim().toLowerCase(),
    'codigo': codigo.trim(),
    'novaSenha': novaSenha,
  }));

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, item) => MapEntry('$key', item));
    throw const ApiException('A resposta do backend veio em formato inválido.');
  }
}
