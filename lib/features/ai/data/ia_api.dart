import 'package:tcc_mobile/core/network/api_client.dart';

/// Comunicação com os endpoints de inteligência artificial do backend FHIVE.
/// Todas as chamadas reaproveitam o JWT armazenado pelo ApiClient.
class IaApi {
  IaApi._();

  static const Duration _timeoutIA = Duration(seconds: 80);

  /// Envia uma pergunta e o histórico recente para o assistente Gemini.
  static Future<Map<String, dynamic>> perguntar({
    required String pergunta,
    List<Map<String, String>> historico = const <Map<String, String>>[],
    Map<String, dynamic>? aparelho,
  }) async {
    final corpo = <String, dynamic>{
      'pergunta': pergunta.trim(),
      'historico': historico,
      if (aparelho != null) 'aparelho': aparelho,
    };

    return _map(
      await ApiClient.post(
        '/ia/perguntar',
        body: corpo,
        timeout: _timeoutIA,
      ),
    );
  }

  /// Solicita uma estimativa de consumo para um eletrodoméstico.
  /// Potência e horas são opcionais: quando faltarem, o backend consulta o Gemini.
  static Future<Map<String, dynamic>> estimarConsumo({
    required Map<String, dynamic> dados,
  }) async {
    return _map(
      await ApiClient.post(
        '/ia/estimar-consumo',
        body: dados,
        timeout: _timeoutIA,
      ),
    );
  }

  /// Analisa as telemetrias de um dispositivo pertencente ao usuário autenticado.
  /// O identificador enviado é o ID interno do MongoDB (AparelhoItem.backendId).
  static Future<Map<String, dynamic>> analisarAnomalias({
    required String dispositivoId,
    Map<String, dynamic> especificacoes = const <String, dynamic>{},
    String? graficoModeloId,
  }) async {
    final id = dispositivoId.trim();
    if (id.isEmpty) {
      throw const ApiException(
        'O aparelho selecionado não possui um identificador do backend.',
      );
    }

    return _map(
      await ApiClient.post(
        '/ia/dispositivos/${Uri.encodeComponent(id)}/analisar-anomalias',
        body: <String, dynamic>{
          'especificacoes': especificacoes,
          if (graficoModeloId != null && graficoModeloId.trim().isNotEmpty)
            'graficoModeloId': graficoModeloId.trim(),
        },
        timeout: _timeoutIA,
      ),
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry('$key', item));
    }
    throw const ApiException(
      'A resposta da inteligência artificial veio em formato inválido.',
    );
  }
}
