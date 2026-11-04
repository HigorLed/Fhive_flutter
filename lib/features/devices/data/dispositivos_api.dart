import 'package:tcc_mobile/core/network/api_client.dart';

class DispositivosApi {
  DispositivosApi._();

  static Future<List<Map<String, dynamic>>> listar() async {
    final resposta = await ApiClient.get('/dispositivos');
    if (resposta is! List) {
      throw const ApiException('A resposta de dispositivos veio em formato inválido.');
    }
    return resposta.map(_map).toList(growable: false);
  }

  static Future<Map<String, dynamic>> criar({
    required String nome,
    required String tipo,
    required String deviceId,
    required String local,
    String? fabricante,
    String? modelo,
    String? conexao,
  }) async => _map(await ApiClient.post('/dispositivos', body: {
    'nome': nome.trim(),
    'tipo': tipo.trim(),
    'deviceId': deviceId.trim(),
    'local': local.trim(),
    if (fabricante != null) 'fabricante': fabricante.trim(),
    if (modelo != null) 'modelo': modelo.trim(),
    if (conexao != null) 'conexao': conexao.trim(),
  }));

  static Future<Map<String, dynamic>> buscar(String id) async =>
      _map(await ApiClient.get('/dispositivos/${Uri.encodeComponent(id)}'));

  static Future<List<Map<String, dynamic>>> telemetrias(String id) async {
    final resposta = await ApiClient.get(
      '/dispositivos/${Uri.encodeComponent(id)}/telemetrias',
    );
    if (resposta is! List) {
      throw const ApiException('A resposta de telemetrias veio em formato inválido.');
    }
    return resposta.map(_map).toList(growable: false);
  }

  static Future<void> excluir(String id) async {
    await ApiClient.delete('/dispositivos/${Uri.encodeComponent(id)}');
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, item) => MapEntry('$key', item));
    throw const ApiException('A resposta do backend veio em formato inválido.');
  }
}
