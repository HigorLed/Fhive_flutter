import 'package:flutter/foundation.dart';

class RotinaItem {
  final String id;
  final String nome;
  final String local;
  final String horario;
  final List<String> acoes;
  final bool ativa;
  final DateTime? ultimaExecucao;

  const RotinaItem({
    required this.id,
    required this.nome,
    required this.local,
    required this.horario,
    required this.acoes,
    this.ativa = true,
    this.ultimaExecucao,
  });

  RotinaItem copyWith({
    String? id,
    String? nome,
    String? local,
    String? horario,
    List<String>? acoes,
    bool? ativa,
    DateTime? ultimaExecucao,
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
    );
  }
}

/// Armazena rotinas do protótipo em memória e oferece operações de CRUD.
class RotinasStore {
  RotinasStore._();

  static int _proximoId = 5;

  static List<RotinaItem> _iniciais() => <RotinaItem>[
    const RotinaItem(
      id: 'rotina-1',
      nome: 'Acordar',
      local: 'Locais',
      horario: '07:00',
      acoes: <String>['Ligar TV'],
    ),
    const RotinaItem(
      id: 'rotina-2',
      nome: 'Ao sair de casa',
      local: 'Locais',
      horario: '08:00',
      acoes: <String>['Desligar aparelhos'],
    ),
    const RotinaItem(
      id: 'rotina-3',
      nome: 'Dormir',
      local: 'Locais',
      horario: '22:00',
      acoes: <String>['Desligar luzes'],
    ),
    const RotinaItem(
      id: 'rotina-4',
      nome: 'Economizar energia',
      local: 'Locais',
      horario: 'Sem horário',
      acoes: <String>['Ativar modo econômico'],
    ),
  ];

  static final ValueNotifier<List<RotinaItem>> rotinas =
      ValueNotifier<List<RotinaItem>>(_iniciais());

  static void reset() {
    _proximoId = 5;
    rotinas.value = _iniciais();
  }

  static RotinaItem? porId(String id) {
    for (final rotina in rotinas.value) {
      if (rotina.id == id) return rotina;
    }
    return null;
  }

  static RotinaItem? adicionar({
    required String nome,
    required String local,
    required String horario,
    required List<String> acoes,
  }) {
    final nomeLimpo = nome.trim();
    if (nomeLimpo.isEmpty) return null;

    final rotina = RotinaItem(
      id: 'rotina-${_proximoId++}',
      nome: nomeLimpo,
      local: local.trim().isEmpty ? 'Locais' : local.trim(),
      horario: horario.trim().isEmpty ? 'Sem horário' : horario.trim(),
      acoes: List<String>.unmodifiable(
        acoes.map((acao) => acao.trim()).where((acao) => acao.isNotEmpty),
      ),
    );
    rotinas.value = <RotinaItem>[...rotinas.value, rotina];
    return rotina;
  }

  static bool atualizar(RotinaItem rotina) {
    final indice = rotinas.value.indexWhere((item) => item.id == rotina.id);
    if (indice < 0 || rotina.nome.trim().isEmpty) return false;
    final novas = List<RotinaItem>.from(rotinas.value);
    novas[indice] = rotina.copyWith(nome: rotina.nome.trim());
    rotinas.value = novas;
    return true;
  }

  static bool alternar(String id) {
    final atual = porId(id);
    if (atual == null) return false;
    return atualizar(atual.copyWith(ativa: !atual.ativa));
  }

  static bool executar(String id) {
    final atual = porId(id);
    if (atual == null || !atual.ativa) return false;
    final dataAtual = DateTime.now();
    final novas = List<RotinaItem>.from(rotinas.value);
    final indice = novas.indexWhere((item) => item.id == id);
    novas[indice] = atual.copyWith(ultimaExecucao: dataAtual);
    rotinas.value = novas;
    // Este registro confirma a execução na interface. Executar comandos físicos
    // exige integração com o serviço/hardware IoT correspondente.
    return true;
  }

  static bool remover(String id) {
    final antes = rotinas.value.length;
    rotinas.value = rotinas.value.where((item) => item.id != id).toList();
    return rotinas.value.length < antes;
  }
}
