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

  AparelhoItem copyWith({
    String? nome,
    String? id,
    String? tipo,
    String? fabricante,
    String? modelo,
    String? status,
    IconData? icone,
    bool? wifi,
    String? local,
    String? conexao,
  }) {
    return AparelhoItem(
      nome: nome ?? this.nome,
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      fabricante: fabricante ?? this.fabricante,
      modelo: modelo ?? this.modelo,
      status: status ?? this.status,
      icone: icone ?? this.icone,
      wifi: wifi ?? this.wifi,
      local: local ?? this.local,
      conexao: conexao ?? this.conexao,
    );
  }
}

/// Estado centralizado dos aparelhos e locais durante a sessão do protótipo.
/// Os valores ficam em memória; a persistência e sincronização IoT precisam de
/// um backend ou banco local integrado para sobreviverem ao encerramento do app.
class AparelhosStore {
  AparelhosStore._();

  static const List<String> locaisSugeridos = <String>[
    'Sala de Estar',
    'Cozinha',
    'Quarto',
    'Banheiro',
    'Escritório',
    'Área externa',
    'Outro local',
  ];

  static final ValueNotifier<List<String>> locais = ValueNotifier<List<String>>(
    List<String>.from(locaisSugeridos),
  );

  static List<String> get locaisDisponiveis {
    final resultado = <String>[];

    void incluir(String local) {
      final nome = local.trim();
      if (nome.isEmpty) return;
      if (!resultado.any((item) => item.toLowerCase() == nome.toLowerCase())) {
        resultado.add(nome);
      }
    }

    for (final local in locais.value) {
      incluir(local);
    }
    for (final aparelho in aparelhos.value) {
      incluir(aparelho.local);
    }
    return resultado;
  }

  static bool localExiste(String nome) {
    final normalizado = nome.trim().toLowerCase();
    if (normalizado.isEmpty) return false;
    return locaisDisponiveis.any(
      (local) => local.trim().toLowerCase() == normalizado,
    );
  }

  static bool adicionarLocal(String nome) {
    final normalizado = nome.trim();
    if (normalizado.isEmpty || localExiste(normalizado)) return false;
    locais.value = <String>[...locais.value, normalizado];
    return true;
  }

  static final ValueNotifier<List<AparelhoItem>> aparelhos =
      ValueNotifier<List<AparelhoItem>>(_aparelhosIniciais());

  /// Favoritos são guardados pelo ID, e não pelo nome, para continuarem válidos
  /// quando o usuário renomeia um aparelho.
  static final ValueNotifier<Set<String>> favoritos =
      ValueNotifier<Set<String>>(<String>{});

  static Set<String> get favoritosLista =>
      Set<String>.unmodifiable(favoritos.value);

  static List<AparelhoItem> _aparelhosIniciais() => <AparelhoItem>[
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

  static void reset() {
    locais.value = List<String>.from(locaisSugeridos);
    aparelhos.value = _aparelhosIniciais();
    favoritos.value = <String>{};
  }

  static bool idJaCadastrado(String id, {String? ignorarId}) {
    final normalizado = id.trim().toLowerCase();
    if (normalizado.isEmpty) return false;
    return aparelhos.value.any(
      (aparelho) =>
          aparelho.id.trim().toLowerCase() == normalizado &&
          aparelho.id != ignorarId,
    );
  }

  static bool nomeJaCadastrado(String nome, {String? ignorarId}) {
    final normalizado = nome.trim().toLowerCase();
    if (normalizado.isEmpty) return false;
    return aparelhos.value.any(
      (aparelho) =>
          aparelho.nome.trim().toLowerCase() == normalizado &&
          aparelho.id != ignorarId,
    );
  }

  static void adicionar(AparelhoItem aparelho) {
    final nome = aparelho.nome.trim();
    final id = aparelho.id.trim();
    if (nome.isEmpty || id.isEmpty) return;
    if (nomeJaCadastrado(nome) || idJaCadastrado(id)) return;

    final novo = aparelho.copyWith(
      nome: nome,
      id: id,
      local: aparelho.local.trim(),
    );
    adicionarLocal(novo.local);
    aparelhos.value = <AparelhoItem>[...aparelhos.value, novo];
  }

  static AparelhoItem? porId(String id) {
    final normalizado = id.trim().toLowerCase();
    for (final aparelho in aparelhos.value) {
      if (aparelho.id.trim().toLowerCase() == normalizado) return aparelho;
    }
    return null;
  }

  static AparelhoItem? porNome(String nome) {
    final normalizado = nome.trim().toLowerCase();
    for (final aparelho in aparelhos.value) {
      if (aparelho.nome.trim().toLowerCase() == normalizado) return aparelho;
    }
    return null;
  }

  static void atualizar(AparelhoItem aparelho, {required String idAnterior}) {
    final indice = aparelhos.value.indexWhere(
      (item) => item.id.toLowerCase() == idAnterior.trim().toLowerCase(),
    );
    if (indice < 0) return;

    final nome = aparelho.nome.trim();
    final id = aparelho.id.trim();
    if (nome.isEmpty || id.isEmpty) return;
    if (nomeJaCadastrado(nome, ignorarId: idAnterior) ||
        idJaCadastrado(id, ignorarId: idAnterior)) {
      return;
    }

    final atualizados = List<AparelhoItem>.from(aparelhos.value);
    atualizados[indice] = aparelho.copyWith(
      nome: nome,
      id: id,
      local: aparelho.local.trim(),
    );
    adicionarLocal(aparelho.local);
    aparelhos.value = atualizados;

    final favoritosAtuais = Set<String>.from(favoritos.value);
    final eraFavorito = favoritosAtuais.any(
      (favorito) => favorito.toLowerCase() == idAnterior.trim().toLowerCase(),
    );
    favoritosAtuais.removeWhere(
      (favorito) => favorito.toLowerCase() == idAnterior.trim().toLowerCase(),
    );
    if (eraFavorito) favoritosAtuais.add(id);
    favoritos.value = favoritosAtuais;
  }

  static bool removerPorId(String id) {
    final antes = aparelhos.value.length;
    final normalizado = id.trim().toLowerCase();
    aparelhos.value = aparelhos.value
        .where((item) => item.id.trim().toLowerCase() != normalizado)
        .toList();
    final removido = aparelhos.value.length != antes;
    if (removido) {
      final favoritosAtuais = Set<String>.from(favoritos.value)
        ..removeWhere(
          (favorito) => favorito.trim().toLowerCase() == normalizado,
        );
      favoritos.value = favoritosAtuais;
    }
    return removido;
  }

  static void atualizarStatus(String id, String status) {
    final aparelho = porId(id);
    if (aparelho == null) return;
    atualizar(aparelho.copyWith(status: status), idAnterior: aparelho.id);
  }

  static String? _resolverId(String idOuNome) {
    final porCodigo = porId(idOuNome);
    if (porCodigo != null) return porCodigo.id;
    final porNomeEncontrado = porNome(idOuNome);
    return porNomeEncontrado?.id;
  }

  static bool ehFavorito(String idOuNome) {
    final id = _resolverId(idOuNome);
    return id != null && favoritos.value.contains(id);
  }

  static void alternarFavorito(String idOuNome) {
    final id = _resolverId(idOuNome);
    // Detalhes podem ser abertos em testes/telas independentes. Não se cria um
    // favorito órfão quando o aparelho ainda não existe no cadastro.
    if (id == null) return;

    final atual = Set<String>.from(favoritos.value);
    if (!atual.add(id)) atual.remove(id);
    favoritos.value = atual;
  }
}
