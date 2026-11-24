import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Resultado da descoberta de uma TV Samsung na rede local.
class SamsungTvCandidate {
  final String ip;
  final String name;
  final String model;
  final String powerState;

  const SamsungTvCandidate({
    required this.ip,
    required this.name,
    required this.model,
    required this.powerState,
  });
}

/// Vínculo salvo no armazenamento seguro do celular.
class SamsungTvPairing {
  final String ip;
  final String name;
  final String model;
  final String accessToken;
  final String? certificateSha1;

  const SamsungTvPairing({
    required this.ip,
    required this.name,
    required this.model,
    required this.accessToken,
    required this.certificateSha1,
  });
}

/// Cliente local da Samsung IP Control (HTTPS + JSON-RPC, porta 1516).
/// A requisição HTTP/1.1 é escrita manualmente para garantir todos os cabeçalhos.
/// O token da TV permanece no armazenamento seguro do telefone e não é
/// enviado ao backend FHIVE.
class SamsungIpControlService {
  SamsungIpControlService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _prefixoChave = 'fhive_samsung_ip_control_';

  // A Samsung IP Control é sensível a várias conexões abertas em sequência.
  // As chamadas são enfileiradas por IP e aguardam este intervalo após o
  // fechamento completo da conexão anterior.
  static const Duration _intervaloEntreConexoes = Duration(milliseconds: 1500);
  static const Duration _timeoutFechamentoSocket = Duration(seconds: 2);
  static final Map<String, Future<void>> _filaConexoesPorIp =
      <String, Future<void>>{};
  static final Map<String, DateTime> _ultimaFinalizacaoPorIp =
      <String, DateTime>{};

  static String _chave(String dispositivoBackendId) =>
      '$_prefixoChave$dispositivoBackendId';

  static bool _ipv4Privado(String ip) {
    final partes = ip.split('.');
    if (partes.length != 4) return false;
    final octetos = partes.map(int.tryParse).toList();
    if (octetos.any((item) => item == null || item < 0 || item > 255)) {
      return false;
    }
    final a = octetos[0]!;
    final b = octetos[1]!;
    return a == 10 ||
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 192 && b == 168);
  }

  static String _sha1Hex(Uint8List bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();


  /// Verifica se o endereço informado aceita conexão TCP na porta 1516.
  /// A autenticação é realizada posteriormente por HTTPS/JSON-RPC.
  static Future<SamsungTvCandidate> verificarIp(
    String ipInformado, {
    bool exibirLog = true,
  }) async {
    final ip = ipInformado.trim();

    if (!_ipv4Privado(ip)) {
      if (exibirLog) {
        print('[FHIVE Samsung] FALHA: endereço IP inválido ($ip).');
      }
      throw const FormatException(
        'Informe um IPv4 privado válido, como 192.168.15.168.',
      );
    }

    if (exibirLog) {
      print('[FHIVE Samsung] Verificando conexão com $ip na porta 1516...');
    }

    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        1516,
        timeout: const Duration(seconds: 4),
      );

      if (exibirLog) {
        print(
          '[FHIVE Samsung] SUCESSO: conexão estabelecida com $ip na porta 1516!',
        );
      }

      return SamsungTvCandidate(
        ip: ip,
        name: 'Samsung Smart TV',
        model: 'Samsung IP Control',
        powerState: 'unknown',
      );
    } on TimeoutException {
      if (exibirLog) {
        print(
          '[FHIVE Samsung] FALHA: tempo esgotado ao conectar com $ip na porta 1516.',
        );
      }
      throw const FormatException(
        'A televisão não respondeu na porta 1516. Verifique a conexão com a rede.',
      );
    } on SocketException catch (error) {
      if (exibirLog) {
        print(
          '[FHIVE Samsung] FALHA: não foi possível conectar com $ip na porta 1516. '
          'Detalhes: ${error.message}',
        );
      }
      throw const FormatException(
        'Não foi possível estabelecer conexão com a porta 1516 da televisão.',
      );
    } finally {
      socket?.destroy();
    }
  }

  /// Busca TVs Samsung no /24 das interfaces IPv4 privadas disponíveis.
  /// Também existe entrada manual de IP na interface, caso a rede use outra máscara.
  static Future<List<SamsungTvCandidate>> descobrirNaRede() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    final prefixos = <String>{};
    for (final interface in interfaces) {
      for (final endereco in interface.addresses) {
        final ip = endereco.address;
        if (!_ipv4Privado(ip)) continue;
        final partes = ip.split('.');
        prefixos.add('${partes[0]}.${partes[1]}.${partes[2]}');
      }
    }

    if (prefixos.isEmpty) {
      throw const FormatException(
        'Não foi possível identificar uma rede Wi-Fi privada. Conecte o celular ao Wi-Fi e tente novamente.',
      );
    }

    final enderecos = <String>[];
    for (final prefixo in prefixos.take(3)) {
      for (var host = 1; host <= 254; host++) {
        enderecos.add('$prefixo.$host');
      }
    }

    final encontradas = <SamsungTvCandidate>[];
    const tamanhoLote = 24;

    for (var inicio = 0; inicio < enderecos.length; inicio += tamanhoLote) {
      final fim = (inicio + tamanhoLote < enderecos.length)
          ? inicio + tamanhoLote
          : enderecos.length;
      final lote = enderecos.sublist(inicio, fim);
      final resultados = await Future.wait(
        lote.map((ip) async {
          try {
            return await verificarIp(ip, exibirLog: false);
          } catch (_) {
            return null;
          }
        }),
      );
      encontradas.addAll(resultados.whereType<SamsungTvCandidate>());
    }

    final porIp = <String, SamsungTvCandidate>{};
    for (final tv in encontradas) {
      porIp[tv.ip] = tv;
    }
    return porIp.values.toList(growable: false);
  }

  /// Lê a resposta HTTP recebida pelo SecureSocket.
  /// O IP Control responde HTTP/1.x e não aceita POST com Transfer-Encoding: chunked.
  static Map<String, dynamic> _interpretarRespostaHttp(List<int> bytes) {
    final textoLatin1 = latin1.decode(bytes);
    final separador = textoLatin1.indexOf('\r\n\r\n');

    if (separador < 0) {
      throw const FormatException(
        'A televisão encerrou a conexão sem enviar cabeçalhos HTTP completos.',
      );
    }

    final cabecalhosTexto = textoLatin1.substring(0, separador);
    final linhas = cabecalhosTexto.split('\r\n');

    if (linhas.isEmpty) {
      throw const FormatException('A televisão retornou uma resposta HTTP vazia.');
    }

    final partesStatus = linhas.first.trim().split(RegExp(r'\s+'));
    if (partesStatus.length < 2) {
      throw FormatException('Linha de status HTTP inválida: ${linhas.first}');
    }

    final statusCode = int.tryParse(partesStatus[1]);
    if (statusCode == null) {
      throw FormatException('Código HTTP inválido: ${linhas.first}');
    }

    final cabecalhos = <String, String>{};
    for (final linha in linhas.skip(1)) {
      final doisPontos = linha.indexOf(':');
      if (doisPontos <= 0) continue;

      final nome = linha.substring(0, doisPontos).trim().toLowerCase();
      final valor = linha.substring(doisPontos + 1).trim();
      cabecalhos[nome] = cabecalhos.containsKey(nome)
          ? '${cabecalhos[nome]}, $valor'
          : valor;
    }

    var corpoBytes = bytes.sublist(separador + 4);

    final transferEncoding = cabecalhos['transfer-encoding']?.toLowerCase() ?? '';
    if (transferEncoding.contains('chunked')) {
      corpoBytes = _decodificarCorpoChunked(corpoBytes);
    } else {
      final tamanhoDeclarado = int.tryParse(cabecalhos['content-length'] ?? '');
      if (tamanhoDeclarado != null) {
        if (corpoBytes.length < tamanhoDeclarado) {
          throw const FormatException(
            'A resposta HTTP da televisão foi recebida incompleta.',
          );
        }
        corpoBytes = corpoBytes.sublist(0, tamanhoDeclarado);
      }
    }

    return <String, dynamic>{
      'statusCode': statusCode,
      'headers': cabecalhos,
      'body': utf8.decode(corpoBytes, allowMalformed: true),
    };
  }

  /// Decodifica uma resposta HTTP chunked, caso a televisão use esse formato
  /// na resposta. A requisição enviada pelo FHIVE nunca é chunked.
  static List<int> _decodificarCorpoChunked(List<int> bytes) {
    final resultado = <int>[];
    var cursor = 0;

    while (cursor < bytes.length) {
      var fimLinha = -1;
      for (var i = cursor; i + 1 < bytes.length; i++) {
        if (bytes[i] == 13 && bytes[i + 1] == 10) {
          fimLinha = i;
          break;
        }
      }

      if (fimLinha < 0) {
        throw const FormatException('Resposta HTTP chunked inválida.');
      }

      final linhaTamanho = latin1
          .decode(bytes.sublist(cursor, fimLinha))
          .split(';')
          .first
          .trim();
      final tamanho = int.tryParse(linhaTamanho, radix: 16);
      if (tamanho == null || tamanho < 0) {
        throw const FormatException('Tamanho de bloco HTTP inválido.');
      }

      cursor = fimLinha + 2;
      if (tamanho == 0) {
        return resultado;
      }

      if (cursor + tamanho + 2 > bytes.length) {
        throw const FormatException('Bloco HTTP recebido incompleto.');
      }

      resultado.addAll(bytes.sublist(cursor, cursor + tamanho));
      cursor += tamanho;

      if (bytes[cursor] != 13 || bytes[cursor + 1] != 10) {
        throw const FormatException('Separador de bloco HTTP inválido.');
      }
      cursor += 2;
    }

    throw const FormatException('Resposta HTTP chunked incompleta.');
  }

  /// Serializa toda comunicação com a mesma TV e impõe um intervalo mínimo
  /// entre conexões. Isso impede comandos simultâneos e evita sobrecarregar a
  /// API da televisão com handshakes TLS repetidos.
  static Future<Map<String, dynamic>> _chamarRpc({
    required String ip,
    required String metodo,
    Map<String, dynamic>? parametros,
    String? fingerprintEsperado,
    bool aceitarCertificadoInicial = false,
    void Function(String fingerprint)? aoCapturarFingerprint,
  }) async {
    if (!_ipv4Privado(ip)) {
      throw const FormatException(
        'O endereço da TV não é um IPv4 privado válido.',
      );
    }

    final chamadaAnterior = _filaConexoesPorIp[ip];
    final liberacaoDaFila = Completer<void>();
    _filaConexoesPorIp[ip] = liberacaoDaFila.future;

    try {
      // Aguarda qualquer comando que já esteja usando a mesma TV.
      if (chamadaAnterior != null) {
        await chamadaAnterior;
      }

      // O intervalo é contado depois do encerramento anterior, não apenas
      // entre os instantes de abertura dos sockets.
      final ultimaFinalizacao = _ultimaFinalizacaoPorIp[ip];
      if (ultimaFinalizacao != null) {
        final decorrido = DateTime.now().difference(ultimaFinalizacao);
        final restante = _intervaloEntreConexoes - decorrido;
        if (restante > Duration.zero) {
          await Future<void>.delayed(restante);
        }
      }

      return await _chamarRpcDireto(
        ip: ip,
        metodo: metodo,
        parametros: parametros,
        fingerprintEsperado: fingerprintEsperado,
        aceitarCertificadoInicial: aceitarCertificadoInicial,
        aoCapturarFingerprint: aoCapturarFingerprint,
      );
    } finally {
      // _chamarRpcDireto só retorna/lança depois do finally que fecha o socket.
      _ultimaFinalizacaoPorIp[ip] = DateTime.now();
      liberacaoDaFila.complete();

      // Não apaga a fila de uma chamada mais nova que já esteja aguardando.
      if (identical(_filaConexoesPorIp[ip], liberacaoDaFila.future)) {
        _filaConexoesPorIp.remove(ip);
      }
    }
  }

  /// Executa uma única chamada mantendo exatamente o protocolo Samsung já
  /// validado: TLS, certificado, fingerprint, HTTP/1.1 e JSON-RPC.
  static Future<Map<String, dynamic>> _chamarRpcDireto({
    required String ip,
    required String metodo,
    Map<String, dynamic>? parametros,
    String? fingerprintEsperado,
    bool aceitarCertificadoInicial = false,
    void Function(String fingerprint)? aoCapturarFingerprint,
  }) async {
    if (!_ipv4Privado(ip)) {
      throw const FormatException(
        'O endereço da TV não é um IPv4 privado válido.',
      );
    }

    SecureSocket? socket;

    try {
      // O servidor Samsung IP Control aceita HTTP/1.0 ou HTTP/1.1.
      // Forçamos HTTP/1.1 e não usamos HttpClient para escrever manualmente
      // os cabeçalhos HTTP exigidos pelo servidor.
      socket = await SecureSocket.connect(
        ip,
        1516,
        timeout: const Duration(seconds: 15),
        supportedProtocols: const <String>['http/1.1'],
        onBadCertificate: (certificado) {
          final fingerprint = _sha1Hex(certificado.sha1).toLowerCase();

          if (fingerprintEsperado != null && fingerprintEsperado.isNotEmpty) {
            return fingerprint == fingerprintEsperado.toLowerCase();
          }

          return aceitarCertificadoInicial;
        },
      ).timeout(const Duration(seconds: 18));

      // Também valida/captura a impressão digital quando o certificado
      // é confiável para o sistema e, por isso, o callback não foi chamado.
      final certificado = socket.peerCertificate;
      if (certificado != null) {
        final fingerprint = _sha1Hex(certificado.sha1).toLowerCase();

        if (fingerprintEsperado != null &&
            fingerprintEsperado.isNotEmpty &&
            fingerprint != fingerprintEsperado.toLowerCase()) {
          throw const SamsungTvCommandException(
            mensagem: 'O certificado da televisão mudou. O pareamento foi bloqueado.',
          );
        }

        if (fingerprintEsperado == null && aceitarCertificadoInicial) {
          aoCapturarFingerprint?.call(fingerprint);
        }
      }

      final payload = <String, dynamic>{
        'jsonrpc': '2.0',
        // O parser da Samsung exige que o ID seja uma string.
        'id': '1',
        'method': metodo,
        if (parametros != null) 'params': parametros,
      };

      final corpoJson = jsonEncode(payload);
      final corpoBytes = utf8.encode(corpoJson);

      // Estes são os cabeçalhos enviados explicitamente pelo Node.js:
      // Host, Accept, Content-Type e Content-Length.
      // O corpo usa UTF-8 e o comprimento é calculado em bytes, não caracteres.
      final cabecalhosHttp = <String>[
        'POST / HTTP/1.1',
        'Host: $ip:1516',
        'Accept: application/json',
        'Content-Type: application/json',
        'Content-Length: ${corpoBytes.length}',
        'Connection: close',
        '',
        '',
      ].join('\r\n');

      final requisicaoBytes = <int>[
        ...ascii.encode(cabecalhosHttp),
        ...corpoBytes,
      ];

      print('[FHIVE Samsung] TLS conectado em $ip:1516.');
      print(
        '[FHIVE Samsung] Protocolo negociado: '
        '${socket.selectedProtocol ?? 'HTTP/1.1 (ALPN não informado)'}.',
      );
      print('[FHIVE Samsung] Enviando POST / para $ip:1516.');
      print('[FHIVE Samsung] Método JSON-RPC: $metodo.');
      print('[FHIVE Samsung] Host: $ip:1516');
      print('[FHIVE Samsung] Accept: application/json');
      print('[FHIVE Samsung] Content-Type: application/json');
      print('[FHIVE Samsung] Content-Length: ${corpoBytes.length}');
      print('[FHIVE Samsung] Transfer-Encoding: ausente (não chunked).');

      // Só registramos o corpo do bootstrap; comandos autenticados contêm token.
      if (metodo == 'createAccessToken') {
        print('[FHIVE Samsung] JSON enviado: $corpoJson');
      }

      socket.add(requisicaoBytes);
      await socket.flush();

      // Connection: close pede ao servidor que encerre após a resposta.
      // Assim recebemos a resposta HTTP integral sem deixar a conexão aberta.
      final respostaBytes = await socket
          .timeout(const Duration(seconds: 20))
          .fold<List<int>>(<int>[], (acumulado, bloco) {
        acumulado.addAll(bloco);
        return acumulado;
      });

      if (respostaBytes.isEmpty) {
        throw const SamsungTvCommandException(
          mensagem: 'A televisão encerrou a conexão sem enviar uma resposta HTTP.',
        );
      }

      final respostaHttp = _interpretarRespostaHttp(respostaBytes);
      final statusCode = respostaHttp['statusCode'] as int;
      final headers = respostaHttp['headers'] as Map<String, String>;
      final body = respostaHttp['body'] as String;

      print('[FHIVE Samsung] HTTP recebido: $statusCode');
      print(
        '[FHIVE Samsung] Servidor: '
        '${headers['server'] ?? 'Não informado'}',
      );
      print(
        '[FHIVE Samsung] Content-Type da resposta: '
        '${headers['content-type'] ?? 'Não informado'}',
      );

      if (statusCode < 200 || statusCode >= 300) {
        print('[FHIVE Samsung] Corpo da resposta: $body');

        final detalhe = body.trim().isEmpty
            ? 'A televisão não enviou detalhes adicionais.'
            : body.trim().length > 500
                ? '${body.trim().substring(0, 500)}…'
                : body.trim();

        throw SamsungTvCommandException(
          httpStatus: statusCode,
          mensagem:
              'A Samsung IP Control respondeu HTTP $statusCode: $detalhe',
        );
      }

      if (body.trim().isEmpty) {
        throw const SamsungTvCommandException(
          mensagem: 'A televisão respondeu sem conteúdo JSON.',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException(
          'A TV retornou uma resposta JSON inválida.',
        );
      }

      final erro = decoded['error'];
      if (erro is Map || decoded.containsKey('code')) {
        final codigo = erro is Map ? erro['code'] : decoded['code'];
        final mensagem = erro is Map ? erro['message'] : decoded['message'];
        throw SamsungTvCommandException(
          codigo: codigo?.toString(),
          mensagem: mensagem?.toString() ?? 'A TV recusou o comando.',
        );
      }

      final resultado = decoded['result'];
      if (resultado is Map) {
        print('[FHIVE Samsung] Resposta JSON recebida com sucesso.');
        return Map<String, dynamic>.from(resultado);
      }

      return Map<String, dynamic>.from(decoded);
    } on TimeoutException {
      print('[FHIVE Samsung] FALHA: tempo esgotado durante a comunicação HTTPS.');
      throw const SamsungTvCommandException(
        mensagem: 'A televisão não respondeu dentro do tempo limite.',
      );
    } on SocketException catch (error) {
      print('[FHIVE Samsung] FALHA DE REDE: ${error.message}');
      throw const SamsungTvCommandException(
        mensagem: 'Não foi possível alcançar a televisão na porta 1516.',
      );
    } finally {
      final socketParaFechar = socket;
      if (socketParaFechar != null) {
        try {
          // Connection: close já solicita o encerramento ao servidor. Aqui
          // aguardamos também o fechamento local/TLS antes de liberar a fila.
          await socketParaFechar
              .close()
              .timeout(_timeoutFechamentoSocket);
        } catch (error) {
          // Se o fechamento organizado não terminar, força a liberação para
          // não deixar uma conexão presa bloqueando os próximos comandos.
          print('[FHIVE Samsung] Fechamento TLS forçado: $error');
          socketParaFechar.destroy();
        }
      }
    }
  }

  /// Realiza o pareamento diretamente pelo celular, recebe e guarda o token
  /// e o fingerprint do certificado no armazenamento seguro do sistema.
  static Future<SamsungTvPairing> parear({
    required String dispositivoBackendId,
    required SamsungTvCandidate tv,
  }) async {
    String? fingerprint;
    final resposta = await _chamarRpc(
      ip: tv.ip,
      metodo: 'createAccessToken',
      aceitarCertificadoInicial: true,
      aoCapturarFingerprint: (valor) => fingerprint = valor,
    );

    final token = resposta['AccessToken'] ?? resposta['accessToken'];
    if (token is! String || token.trim().isEmpty) {
      throw const SamsungTvCommandException(
        mensagem: 'A TV não retornou um token de autorização válido.',
      );
    }

    final certificado = fingerprint;
    final pairing = SamsungTvPairing(
      ip: tv.ip,
      name: tv.name,
      model: tv.model,
      accessToken: token,
      certificateSha1: certificado,
    );

    await _storage.write(
      key: _chave(dispositivoBackendId),
      value: jsonEncode({
        'ip': pairing.ip,
        'name': pairing.name,
        'model': pairing.model,
        'accessToken': pairing.accessToken,
        'certificateSha1': pairing.certificateSha1,
      }),
    );

    return pairing;
  }

  static Future<SamsungTvPairing?> carregarPareamento(
    String dispositivoBackendId,
  ) async {
    final conteudo = await _storage.read(key: _chave(dispositivoBackendId));
    if (conteudo == null || conteudo.isEmpty) return null;

    try {
      final dados = jsonDecode(conteudo) as Map<String, dynamic>;
      final token = dados['accessToken'];
      final ip = dados['ip'];
      if (token is! String || ip is! String || !_ipv4Privado(ip)) return null;

      return SamsungTvPairing(
        ip: ip,
        name: '${dados['name'] ?? 'Samsung Smart TV'}',
        model: '${dados['model'] ?? 'Modelo Samsung'}',
        accessToken: token,
        certificateSha1: dados['certificateSha1'] as String?,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static Future<void> removerPareamento(String dispositivoBackendId) =>
      _storage.delete(key: _chave(dispositivoBackendId));

  static Future<Map<String, dynamic>> consultarEstado(
    String dispositivoBackendId,
  ) async {
    final pairing = await _exigirPareamento(dispositivoBackendId);
    final params = <String, dynamic>{'AccessToken': pairing.accessToken};
    final estados = await _chamarRpc(
      ip: pairing.ip,
      metodo: 'getTVStates',
      parametros: params,
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
    final energia = await _chamarRpc(
      ip: pairing.ip,
      metodo: 'powerControl',
      parametros: params,
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
    return <String, dynamic>{
      'tv': estados,
      'energia': energia,
    };
  }

  static Future<void> definirEnergia(
    String dispositivoBackendId, {
    required bool ligado,
  }) async {
    final pairing = await _exigirPareamento(dispositivoBackendId);
    await _chamarRpc(
      ip: pairing.ip,
      metodo: 'powerControl',
      parametros: {
        'AccessToken': pairing.accessToken,
        'power': ligado ? 'powerOn' : 'powerOff',
      },
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
  }

  static Future<void> definirVolume(
    String dispositivoBackendId, {
    required int volume,
  }) async {
    final pairing = await _exigirPareamento(dispositivoBackendId);
    if (volume < 0 || volume > 100) {
      throw const SamsungTvCommandException(mensagem: 'O volume deve ficar entre 0 e 100.');
    }
    await _chamarRpc(
      ip: pairing.ip,
      metodo: 'directVolumeControl',
      parametros: {
        'AccessToken': pairing.accessToken,
        'volume': volume,
      },
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
  }

  static Future<void> alterarVolumeRelativo(
    String dispositivoBackendId, {
    required bool aumentar,
  }) async {
    final pairing = await _exigirPareamento(dispositivoBackendId);
    await _chamarRpc(
      ip: pairing.ip,
      metodo: 'volumeUpDnControl',
      parametros: {
        'AccessToken': pairing.accessToken,
        'control': aumentar ? 'volumeUp' : 'volumeDn',
      },
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
  }

  static Future<void> definirSilencio(
    String dispositivoBackendId, {
    required bool silenciado,
  }) async {
    final pairing = await _exigirPareamento(dispositivoBackendId);
    await _chamarRpc(
      ip: pairing.ip,
      metodo: 'muteControl',
      parametros: {
        'AccessToken': pairing.accessToken,
        'mute': silenciado ? 'muteOn' : 'muteOff',
      },
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
  }

  static Future<void> trocarCanal(
    String dispositivoBackendId, {
    required bool avancar,
  }) async {
    final pairing = await _exigirPareamento(dispositivoBackendId);
    await _chamarRpc(
      ip: pairing.ip,
      metodo: 'channelUpDnControl',
      parametros: {
        'AccessToken': pairing.accessToken,
        'control': avancar ? 'channelUp' : 'channelDn',
      },
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
  }

  static Future<void> abrirAplicativo(
    String dispositivoBackendId, {
    required String applicationName,
  }) async {
    const permitidos = <String>{'youTube', 'netflix', 'amazon', 'webBrowser'};
    if (!permitidos.contains(applicationName)) {
      throw const SamsungTvCommandException(
        mensagem: 'Este aplicativo não está na lista de comandos validados para a TV.',
      );
    }

    final pairing = await _exigirPareamento(dispositivoBackendId);
    await _chamarRpc(
      ip: pairing.ip,
      metodo: 'directAccessControl',
      parametros: {
        'AccessToken': pairing.accessToken,
        'applicationName': applicationName,
      },
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
  }

  static Future<void> definirModoImagem(
    String dispositivoBackendId, {
    required String modo,
  }) async {
    const modos = <String, String>{
      'Padrão': 'Standard',
      'Cinema': 'Movie',
      'Jogo': 'Game',
    };
    final valor = modos[modo];
    if (valor == null) {
      throw const SamsungTvCommandException(mensagem: 'Modo de imagem não reconhecido.');
    }

    final pairing = await _exigirPareamento(dispositivoBackendId);
    await _chamarRpc(
      ip: pairing.ip,
      metodo: 'pictureModeControl',
      parametros: {
        'AccessToken': pairing.accessToken,
        'pictureMode': valor,
      },
      fingerprintEsperado: pairing.certificateSha1,
      aceitarCertificadoInicial: pairing.certificateSha1 == null,
    );
  }

  static Future<SamsungTvPairing> _exigirPareamento(String dispositivoBackendId) async {
    final pairing = await carregarPareamento(dispositivoBackendId);
    if (pairing == null) {
      throw const SamsungTvCommandException(
        mensagem: 'Esta TV ainda não foi pareada neste celular. Conecte-a novamente.',
      );
    }
    return pairing;
  }
}

class SamsungTvCommandException implements Exception {
  final String? codigo;
  final int? httpStatus;
  final String mensagem;

  const SamsungTvCommandException({
    this.codigo,
    this.httpStatus,
    required this.mensagem,
  });

  @override
  String toString() => httpStatus == null
      ? mensagem
      : 'HTTP $httpStatus: $mensagem';
}