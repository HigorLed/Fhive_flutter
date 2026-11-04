import 'package:tcc_mobile/core/network/api_client.dart';

/// A API de equipes já está disponível para uma futura tela de equipe/compartilhamento.
class EquipesApi {
  EquipesApi._();

  static Future<List<Map<String, dynamic>>> listar() async {
    final resposta = await ApiClient.get('/equipes');
    if (resposta is! List) {
      throw const ApiException('A resposta de equipes veio em formato inválido.');
    }
    return resposta.map(_map).toList(growable: false);
  }

  static Future<Map<String, dynamic>> criar({
    required String nome,
    required String setor,
    required int limiteIntegrantes,
    String? descricao,
    String? imagemFundo,
    String? logo,
    String? plano,
  }) async => _map(await ApiClient.post('/equipes', body: {
    'nome': nome.trim(),
    'setor': setor,
    'limiteIntegrantes': limiteIntegrantes,
    'descricao': ?descricao,
    'imagemFundo': ?imagemFundo,
    'logo': ?logo,
    'plano': ?plano,
  }));

  static Future<void> excluir(String id) async {
    await ApiClient.delete('/equipes/${Uri.encodeComponent(id)}');
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, item) => MapEntry('$key', item));
    throw const ApiException('A resposta do backend veio em formato inválido.');
  }
}
