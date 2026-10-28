import 'package:tcc_mobile/core/network/api_client.dart';

class RotinasApi {
  RotinasApi._();

  static Future<List<Map<String, dynamic>>> listar() async {
    final resposta = await ApiClient.get('/rotinas');
    if (resposta is! List) {
      throw const ApiException('A resposta de rotinas veio em formato inválido.');
    }
    return resposta.map(_map).toList(growable: false);
  }

  static Future<Map<String, dynamic>> criar({
    required String nome,
    required String dispositivoId,
    required String horarioInicial,
    String? descricao,
    String? horarioFinal,
    Map<String, bool>? diasSemana,
    List<Map<String, dynamic>>? acoes,
  }) async => _map(await ApiClient.post('/rotinas', body: {
    'nome': nome.trim(),
    'dispositivoId': dispositivoId,
    'horarioInicial': horarioInicial,
    'horarioFinal': horarioFinal,
    'descricao': descricao,
    'diasSemana': diasSemana ?? const {
      'segunda': true,
      'terca': true,
      'quarta': true,
      'quinta': true,
      'sexta': true,
      'sabado': true,
      'domingo': true,
    },
    'acoes': acoes ?? [
      {
        'ordem': 1,
        'horario': horarioInicial,
        'tipo': 'ligar',
        'instrucoes': <String, dynamic>{'estado': true},
      },
    ],
  }));

  static Future<Map<String, dynamic>> buscar(String id) async =>
      _map(await ApiClient.get('/rotinas/${Uri.encodeComponent(id)}'));

  static Future<Map<String, dynamic>> atualizar(
    String id,
    Map<String, dynamic> dados,
  ) async => _map(await ApiClient.put(
    '/rotinas/${Uri.encodeComponent(id)}',
    body: dados,
  ));

  static Future<void> excluir(String id) async {
    await ApiClient.delete('/rotinas/${Uri.encodeComponent(id)}');
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, item) => MapEntry('$key', item));
    throw const ApiException('A resposta do backend veio em formato inválido.');
  }
}
