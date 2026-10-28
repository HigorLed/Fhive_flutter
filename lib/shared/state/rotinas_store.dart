import 'package:flutter/foundation.dart';
import 'package:tcc_mobile/features/routines/data/rotinas_api.dart';

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
    return RotinaItem(
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
