import 'package:flutter/foundation.dart';
import 'package:tcc_mobile/features/routines/data/rotinas_api.dart';

/// Chaves de dia usadas pelo backend, na ordem de exibição (Seg–Dom).
const List<String> diasDaSemanaApi = <String>[
  'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo',
];

const Map<String, String> rotuloDiaSemana = <String, String>{
  'segunda': 'Seg', 'terca': 'Ter', 'quarta': 'Qua', 'quinta': 'Qui',
  'sexta': 'Sex', 'sabado': 'Sáb', 'domingo': 'Dom',
};

/// Tipos de ação aceitos pelo backend.
const Map<String, String> rotuloTipoAcao = <String, String>{
  'ligar': 'Ligar',
  'desligar': 'Desligar',
  'alterar_estado': 'Alterar estado',
};

/// Uma ação da rotina: `{ordem, horario, tipo, instrucoes:{nome, descricao}}`.
class AcaoRotina {
  final String horario;
  final String tipo;
  final String nome;
  final String descricao;

  const AcaoRotina({
    required this.horario,
    this.tipo = 'ligar',
    this.nome = '',
    this.descricao = '',
  });

  AcaoRotina copyWith({String? horario, String? tipo, String? nome, String? descricao}) =>
      AcaoRotina(
        horario: horario ?? this.horario,
        tipo: tipo ?? this.tipo,
        nome: nome ?? this.nome,
        descricao: descricao ?? this.descricao,
      );

  Map<String, dynamic> paraApi(int ordem) => <String, dynamic>{
        'ordem': ordem,
        'horario': horario,
        'tipo': tipo,
        'instrucoes': <String, dynamic>{
          'nome': nome.trim(),
          if (descricao.trim().isNotEmpty) 'descricao': descricao.trim(),
          if (tipo == 'ligar') 'estado': true,
          if (tipo == 'desligar') 'estado': false,
        },
      };
}

class RotinaItem {
  /// ID do registro no backend (MongoDB).
  final String id;
  final String nome;
  final String local;
  final String horario;
  final List<String> acoes;
  final bool ativa;
  final DateTime? ultimaExecucao;
  final String dispositivoId;
  final String nomeDispositivo;
  final String descricao;
  final String horarioInicial;
  final String horarioFinal;
  final List<String> dias;
  final List<AcaoRotina> acoesDetalhe;

  const RotinaItem({
    required this.id,
    required this.nome,
    required this.local,
    required this.horario,
    required this.acoes,
    this.ativa = true,
    this.ultimaExecucao,
    this.dispositivoId = '',
    this.nomeDispositivo = '',
    this.descricao = '',
    this.horarioInicial = '',
    this.horarioFinal = '',
    this.dias = const <String>[],
    this.acoesDetalhe = const <AcaoRotina>[],
  });

  RotinaItem copyWith({
    String? id,
    String? nome,
    String? local,
    String? horario,
    List<String>? acoes,
    bool? ativa,
    DateTime? ultimaExecucao,
    String? dispositivoId,
    String? nomeDispositivo,
    bool limparUltimaExecucao = false,
  }) {
    return RotinaItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      local: local ?? this.local,
      horario: horario ?? this.horario,
      acoes: acoes ?? this.acoes,
      ativa: ativa ?? this.ativa,
      ultimaExecucao: limparUltimaExecucao
          ? null
          : (ultimaExecucao ?? this.ultimaExecucao),
      dispositivoId: dispositivoId ?? this.dispositivoId,
      nomeDispositivo: nomeDispositivo ?? this.nomeDispositivo,
      descricao: descricao,
      horarioInicial: horarioInicial,
      horarioFinal: horarioFinal,
      dias: dias,
      acoesDetalhe: acoesDetalhe,
    );
  }
}

/// Cache de interface das rotinas que foram salvas no backend.
class RotinasStore {
  RotinasStore._();

  static final ValueNotifier<List<RotinaItem>> rotinas =
      ValueNotifier<List<RotinaItem>>(<RotinaItem>[]);

  static void reset() => rotinas.value = <RotinaItem>[];

  static RotinaItem? porId(String id) {
    for (final rotina in rotinas.value) {
      if (rotina.id == id) return rotina;
    }
    return null;
  }

  static Future<void> carregarDoBackend() async {
    final dados = await RotinasApi.listar();
    rotinas.value = dados.map(_doBackend).toList(growable: false);
  }

  static Future<RotinaItem> adicionarNoBackend({
    required String nome,
    required String dispositivoId,
    required String nomeDispositivo,
    required String local,
    required String horario,
  }) async {
    final resposta = await RotinasApi.criar(
      nome: nome,
      dispositivoId: dispositivoId,
      horarioInicial: horario,
      acoes: <Map<String, dynamic>>[
        <String, dynamic>{
          'ordem': 1,
          'horario': horario,
          'tipo': 'ligar',
          'instrucoes': <String, dynamic>{'estado': true},
        },
      ],
    );
    final dados = _map(resposta['rotina'] ?? resposta);
    final criada = _doBackend(<String, dynamic>{
      ...dados,
      'dispositivo': <String, dynamic>{
        'deviceId': dispositivoId,
        'nome': nomeDispositivo,
        'local': local,
      },
    });
    rotinas.value = <RotinaItem>[criada, ...rotinas.value];
    return criada;
  }

  /// Cria (id == null) ou atualiza (POST/PUT /rotinas) uma rotina completa,
  /// com o mesmo conteúdo do formulário da versão web.
  static Future<RotinaItem> salvarNoBackend({
    String? id,
    required String nome,
    required String descricao,
    required String dispositivoId,
    required String nomeDispositivo,
    required String local,
    required String horarioInicial,
    required String horarioFinal,
    required List<String> dias,
    required List<AcaoRotina> acoes,
  }) async {
    final corpo = <String, dynamic>{
      'nome': nome.trim(),
      'descricao': descricao.trim().isEmpty ? null : descricao.trim(),
      'dispositivoId': dispositivoId,
      'horarioInicial': horarioInicial,
      'horarioFinal': horarioFinal,
      'diasSemana': <String, bool>{
        for (final dia in diasDaSemanaApi) dia: dias.contains(dia),
      },
      'acoes': <Map<String, dynamic>>[
        for (var i = 0; i < acoes.length; i++) acoes[i].paraApi(i + 1),
      ],
    };
    final resposta = id == null
        ? await RotinasApi.criar(
            nome: corpo['nome'] as String,
            dispositivoId: dispositivoId,
            horarioInicial: horarioInicial,
            horarioFinal: horarioFinal,
            descricao: corpo['descricao'] as String?,
            diasSemana: corpo['diasSemana'] as Map<String, bool>,
            acoes: corpo['acoes'] as List<Map<String, dynamic>>,
          )
        : await RotinasApi.atualizar(id, corpo);
    final dados = _map(resposta['rotina'] ?? resposta);
    final salva = _doBackend(<String, dynamic>{
      ...corpo,
      ...dados,
      'dispositivo': <String, dynamic>{
        'deviceId': dispositivoId,
        'nome': nomeDispositivo,
        'local': local,
      },
    });
    if (id == null) {
      rotinas.value = <RotinaItem>[salva, ...rotinas.value];
    } else {
      _substituir(salva);
    }
    return salva;
  }

  static Future<void> alternarNoBackend(String id) async {
    final atual = porId(id);
    if (atual == null) return;
    final resposta = await RotinasApi.atualizar(id, <String, dynamic>{
      'ativo': !atual.ativa,
    });
    final dados = _map(resposta['rotina'] ?? resposta);
    final atualizada = atual.copyWith(
      ativa: dados['ativo'] is bool ? dados['ativo'] as bool : !atual.ativa,
    );
    _substituir(atualizada);
  }

  static Future<void> removerDoBackend(String id) async {
    await RotinasApi.excluir(id);
    rotinas.value = rotinas.value.where((item) => item.id != id).toList();
  }

  /// Execução de ações físicas ainda não existe como endpoint no backend.
  /// Este método não deve ser usado para afirmar que o aparelho foi acionado.
  static bool executar(String id) => false;

  static void _substituir(RotinaItem rotina) {
    final novas = List<RotinaItem>.from(rotinas.value);
    final indice = novas.indexWhere((item) => item.id == rotina.id);
    if (indice < 0) return;
    novas[indice] = rotina;
    rotinas.value = novas;
  }

  static RotinaItem _doBackend(Map<String, dynamic> dados) {
    final dispositivo = _map(dados['dispositivo']);
    final acoesApi = dados['acoes'] is List ? dados['acoes'] as List : const [];
    final acoes = acoesApi.map((acao) {
      if (acao is Map) {
        final tipo = acao['tipo'];
        return tipo is String ? tipo : 'Ação';
      }
      return 'Ação';
    }).toList(growable: false);
    final dias = _map(dados['diasSemana']);
    final diasAtivos = dias.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .join(', ');
    final horario = '${dados['horarioInicial'] ?? 'Sem horário'}';
    final detalhes = acoesApi.whereType<Map>().map((acao) {
      final instrucoes = _map(acao['instrucoes']);
      return AcaoRotina(
        horario: '${acao['horario'] ?? ''}',
        tipo: '${acao['tipo'] ?? 'ligar'}',
        nome: '${instrucoes['nome'] ?? ''}',
        descricao: '${instrucoes['descricao'] ?? ''}',
      );
    }).toList(growable: false);
    return RotinaItem(
      descricao: '${dados['descricao'] ?? ''}',
      horarioInicial: '${dados['horarioInicial'] ?? ''}',
      horarioFinal: '${dados['horarioFinal'] ?? ''}',
      dias: List<String>.unmodifiable(dias.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)),
      acoesDetalhe: List<AcaoRotina>.unmodifiable(detalhes),
      id: '${dados['id'] ?? ''}',
      nome: '${dados['nome'] ?? 'Rotina'}',
      local: '${dispositivo['local'] ?? 'Locais'}',
      horario: horario,
      acoes: List<String>.unmodifiable(acoes.isEmpty ? <String>[diasAtivos] : acoes),
      ativa: dados['ativo'] is bool ? dados['ativo'] as bool : true,
      dispositivoId: '${dispositivo['deviceId'] ?? dados['dispositivoId'] ?? ''}',
      nomeDispositivo: '${dispositivo['nome'] ?? ''}',
    );
  }

  static Map<String, dynamic> _map(dynamic valor) {
    if (valor is Map<String, dynamic>) return valor;
    if (valor is Map) return valor.map((key, value) => MapEntry('$key', value));
    return <String, dynamic>{};
  }
}
