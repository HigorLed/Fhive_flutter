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

  /// O backend recebido não possui DELETE /dispositivos/:id.
  /// Retorna uma mensagem clara em vez de enviar uma chamada que resultaria em 404.
  static Future<void> excluir(String id) async {
    throw const ApiException(
      'A API atual do backend ainda não disponibiliza a exclusão de dispositivos.',
    );
  }



  /// Consulta os metadados do controle local vinculado ao dispositivo.
  /// O token da TV não é retornado pelo backend; ele fica no armazenamento
  /// seguro do celular que realizou o pareamento.
  static Future<Map<String, dynamic>?> controleLocal(String id) async {
    final resposta = await ApiClient.get(
      '/dispositivos/${Uri.encodeComponent(id)}/controle',
    );
    if (resposta is! Map) {
      throw const ApiException('A resposta da configuração de controle veio em formato inválido.');
    }
    final controle = resposta['controle'];
    if (controle == null) return null;
    return _map(controle);
  }

  /// Registra no backend somente os dados não secretos do vínculo da TV.
  static Future<Map<String, dynamic>> vincularControleLocal({
    required String dispositivoId,
    required String provedor,
    required String ip,
    required String nome,
    required String modelo,
  }) async {
    final resposta = await ApiClient.put(
      '/dispositivos/${Uri.encodeComponent(dispositivoId)}/controle',
      body: {
        'provedor': provedor,
        'ip': ip,
        'nome': nome,
        'modelo': modelo,
      },
    );
    if (resposta is! Map) {
      throw const ApiException('O backend retornou uma resposta inválida ao vincular a TV.');
    }
    return _map(resposta);
  }

  static Future<void> desvincularControleLocal(String dispositivoId) async {
    await ApiClient.delete(
      '/dispositivos/${Uri.encodeComponent(dispositivoId)}/controle',
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, item) => MapEntry('$key', item));
    throw const ApiException('A resposta do backend veio em formato inválido.');
  }
}
