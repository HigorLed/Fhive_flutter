import 'package:tcc_mobile/core/network/api_client.dart';

/// API de gráficos modelo. Cada gráfico é uma sessão da coleção Telemetrias
/// marcada com origem "modelo_artificial". As sessões MQTT reais continuam
/// na mesma coleção, mas são filtradas separadamente pelo backend.
class GraficosModeloApi {
  GraficosModeloApi._();

  static Future<List<Map<String, dynamic>>> listar() async {
    final resposta = await ApiClient.get('/graficos-modelo');
    if (resposta is! List) {
      throw const ApiException(
        'A resposta de gráficos modelo veio em formato inválido.',
      );
    }
    return resposta.map(_map).toList(growable: false);
  }

  static Future<Map<String, dynamic>> criar({
    required String dispositivoId,
    String? nome,
    int quantidadeLeituras = 30,
  }) async {
    final id = dispositivoId.trim();
    if (id.isEmpty) {
      throw const ApiException(
        'Selecione um aparelho cadastrado para criar o gráfico modelo.',
      );
    }

    return _map(
      await ApiClient.post(
        '/graficos-modelo',
        body: <String, dynamic>{
          'dispositivoId': id,
          if (nome != null && nome.trim().isNotEmpty) 'nome': nome.trim(),
          'quantidadeLeituras': quantidadeLeituras,
        },
      ),
    );
  }

  static Future<Map<String, dynamic>> buscar(String id) async =>
      _map(await ApiClient.get('/graficos-modelo/${Uri.encodeComponent(id)}'));

  static Future<void> excluir(String id) async {
    await ApiClient.delete('/graficos-modelo/${Uri.encodeComponent(id)}');
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry('$key', item));
    }
    throw const ApiException(
      'A resposta de gráficos modelo veio em formato inválido.',
    );
  }
}
