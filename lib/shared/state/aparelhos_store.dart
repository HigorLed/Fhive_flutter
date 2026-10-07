import 'package:flutter/material.dart';

class AparelhoItem {
  final String nome;
  final String id;
  final String tipo;
  final String fabricante;
  final String modelo;
  final String status;
  final IconData icone;
  final bool wifi;
  final String local;
  final String conexao;

  const AparelhoItem({
    required this.nome,
    required this.id,
    required this.tipo,
    required this.fabricante,
    required this.modelo,
    required this.status,
    required this.icone,
    required this.wifi,
    required this.local,
    required this.conexao,
  });
}

class AparelhosStore {
  AparelhosStore._();

  static final ValueNotifier<List<AparelhoItem>> aparelhos =
      ValueNotifier<List<AparelhoItem>>([
    const AparelhoItem(
      nome: 'TV - Cristal',
      id: 'FH-TV-CRISTAL-001',
      tipo: 'TV',
      fabricante: 'Fhive',
      modelo: 'Cristal',
      status: 'Online',
      icone: Icons.tv,
      wifi: true,
      local: 'Sala de Estar',
      conexao: 'Wi-Fi',
    ),
    const AparelhoItem(
      nome: 'Ar condicionado',
      id: 'FH-AC-SALA-001',
      tipo: 'Ar condicionado',
      fabricante: 'Fhive',
      modelo: 'Smart Air',
      status: 'Offline',
      icone: Icons.air,
      wifi: true,
      local: 'Sala de Estar',
      conexao: 'Wi-Fi',
    ),
  ]);

  static final ValueNotifier<Set<String>> favoritos =
      ValueNotifier<Set<String>>(<String>{});

  /// Restaura o estado inicial dos aparelhos e dos favoritos.
  /// Útil para manter testes independentes sem alterar o comportamento
  /// normal do aplicativo em produção.
  static void reset() {
    aparelhos.value = <AparelhoItem>[
      const AparelhoItem(
        nome: 'TV - Cristal',
        id: 'FH-TV-CRISTAL-001',
        tipo: 'TV',
        fabricante: 'Fhive',
        modelo: 'Cristal',
        status: 'Online',
        icone: Icons.tv,
        wifi: true,
        local: 'Sala de Estar',
        conexao: 'Wi-Fi',
      ),
      const AparelhoItem(
        nome: 'Ar condicionado',
        id: 'FH-AC-SALA-001',
        tipo: 'Ar condicionado',
        fabricante: 'Fhive',
        modelo: 'Smart Air',
        status: 'Offline',
        icone: Icons.air,
        wifi: true,
        local: 'Sala de Estar',
        conexao: 'Wi-Fi',
      ),
    ];
    favoritos.value = <String>{};
  }

  static bool idJaCadastrado(String id) {
    final idNormalizado = id.trim().toLowerCase();
    return aparelhos.value.any(
      (aparelho) => aparelho.id.trim().toLowerCase() == idNormalizado,
    );
  }

  static bool nomeJaCadastrado(String nome) {
    final nomeNormalizado = nome.trim().toLowerCase();
    return aparelhos.value.any(
      (aparelho) => aparelho.nome.trim().toLowerCase() == nomeNormalizado,
    );
  }

  static void adicionar(AparelhoItem aparelho) {
    aparelhos.value = [...aparelhos.value, aparelho];
  }

  static bool ehFavorito(String nome) => favoritos.value.contains(nome);

  static void alternarFavorito(String nome) {
    final atual = Set<String>.from(favoritos.value);

    if (atual.contains(nome)) {
      atual.remove(nome);
    } else {
      atual.add(nome);
    }

    favoritos.value = atual;
  }

  static AparelhoItem? porNome(String nome) {
    for (final aparelho in aparelhos.value) {
      if (aparelho.nome == nome) return aparelho;
    }
    return null;
  }
}
