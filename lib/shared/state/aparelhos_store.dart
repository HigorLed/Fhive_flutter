import 'package:flutter/material.dart';
import 'package:tcc_mobile/features/devices/data/dispositivos_api.dart';

class AparelhoItem {
  final String nome;
  final String id;
  /// ID do registro no MongoDB, usado para consultar/excluir o recurso na API.
  final String backendId;
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
    this.backendId = '',
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
    String? backendId,
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
      backendId: backendId ?? this.backendId,
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


class AtalhoAparelho {
  final String id;
  final String aparelhoId;
  final String nome;
  final String comando;
  final IconData icone;

  const AtalhoAparelho({
    required this.id,
    required this.aparelhoId,
    required this.nome,
    required this.comando,
    required this.icone,
  });
}

/// Estado centralizado dos aparelhos, locais, favoritos e atalhos durante a sessão.
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

  /// Locais que já possuem ao menos um aparelho cadastrado.
  /// Usado na tela de aparelhos para não exibir cômodos vazios.
  static List<String> get locaisComAparelhos {
    final resultado = <String>[];

    for (final aparelho in aparelhos.value) {
      final nome = aparelho.local.trim();
      if (nome.isEmpty) continue;
      if (!resultado.any(
        (local) => local.toLowerCase() == nome.toLowerCase(),
      )) {
        resultado.add(nome);
      }
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

  static int _proximoAtalho = 1;
  static final ValueNotifier<List<AtalhoAparelho>> atalhos =
      ValueNotifier<List<AtalhoAparelho>>(<AtalhoAparelho>[]);

  static List<AtalhoAparelho> atalhosDoAparelho(String aparelhoId) =>
      atalhos.value
          .where((atalho) => atalho.aparelhoId == aparelhoId)
          .toList(growable: false);

  static bool adicionarAtalho({
    required String aparelhoId,
    required String nome,
    required String comando,
    required IconData icone,
  }) {
    final nomeLimpo = nome.trim();
    if (nomeLimpo.isEmpty || porId(aparelhoId) == null) return false;
    final duplicado = atalhos.value.any(
      (atalho) =>
          atalho.aparelhoId == aparelhoId &&
          atalho.nome.toLowerCase() == nomeLimpo.toLowerCase(),
    );
    if (duplicado) return false;
    final novo = AtalhoAparelho(
      id: 'atalho-${_proximoAtalho++}',
      aparelhoId: aparelhoId,
      nome: nomeLimpo,
      comando: comando,
      icone: icone,
    );
    atalhos.value = <AtalhoAparelho>[...atalhos.value, novo];
    return true;
  }

  static bool removerAtalho(String id) {
    final antes = atalhos.value.length;
    atalhos.value = atalhos.value.where((item) => item.id != id).toList();
    return antes != atalhos.value.length;
  }

  static Set<String> get favoritosLista =>
      Set<String>.unmodifiable(favoritos.value);

  // Os aparelhos vêm do backend após o login; não usamos aparelhos fictícios.
  static List<AparelhoItem> _aparelhosIniciais() => <AparelhoItem>[];

  static IconData _iconeParaTipo(String tipo) => switch (tipo.trim().toLowerCase()) {
    'tv' || 'televisão' || 'televisao' => Icons.tv,
    'ar condicionado' || 'ar-condicionado' => Icons.air,
    'lâmpada' || 'lampada' => Icons.lightbulb_outline,
    'câmera' || 'camera' => Icons.videocam_outlined,
    'tomada inteligente' => Icons.power,
    'sensor' => Icons.sensors_outlined,
    _ => Icons.devices_other,
  };

  static AparelhoItem _doBackend(Map<String, dynamic> dados) {
    final tipo = '${dados['tipo'] ?? 'Outro'}';
    final statusApi = '${dados['status'] ?? 'offline'}';
    final status = switch (statusApi.toLowerCase()) {
      'online' => 'Online',
      'offline' => 'Offline',
      _ => statusApi,
    };
    return AparelhoItem(
      nome: '${dados['nome'] ?? 'Aparelho'}',
      id: '${dados['deviceId'] ?? dados['id'] ?? ''}',
      backendId: '${dados['id'] ?? ''}',
      tipo: tipo,
      fabricante: '${dados['fabricante'] ?? 'Não informado'}',
      modelo: '${dados['modelo'] ?? 'Não informado'}',
      status: status,
      icone: _iconeParaTipo(tipo),
      wifi: '${dados['conexao'] ?? 'Wi-Fi'}' == 'Wi-Fi',
      local: '${dados['local'] ?? 'Locais'}',
      conexao: '${dados['conexao'] ?? 'Wi-Fi'}',
    );
  }

  /// Atualiza a lista usando GET /dispositivos.
  static Future<void> carregarDoBackend() async {
    final dados = await DispositivosApi.listar();
    final carregados = dados.map(_doBackend).where((item) => item.id.isNotEmpty).toList();
    aparelhos.value = carregados;
    final locaisNovos = List<String>.from(locais.value);
    for (final aparelho in carregados) {
      if (!locaisNovos.any((local) => local.toLowerCase() == aparelho.local.toLowerCase())) {
        locaisNovos.add(aparelho.local);
      }
    }
    locais.value = locaisNovos;
    final idsValidos = carregados.map((item) => item.id).toSet();
    favoritos.value = favoritos.value.where(idsValidos.contains).toSet();
    atalhos.value = atalhos.value.where((atalho) => idsValidos.contains(atalho.aparelhoId)).toList();
  }

  /// Cria o aparelho no servidor e só o inclui na interface após resposta 2xx.
  static Future<AparelhoItem> criarNoBackend(AparelhoItem aparelho) async {
    final resposta = await DispositivosApi.criar(
      nome: aparelho.nome,
      tipo: aparelho.tipo,
      deviceId: aparelho.id,
      local: aparelho.local,
      fabricante: aparelho.fabricante,
      modelo: aparelho.modelo,
      conexao: aparelho.conexao,
    );
    final dados = resposta['dispositivo'] is Map
        ? (resposta['dispositivo'] as Map).map((key, value) => MapEntry('$key', value))
        : resposta;
    final criado = _doBackend(Map<String, dynamic>.from(dados));
    adicionar(criado);
    return criado;
  }

  /// Exclui no backend antes de retirar o item da lista local.
  static Future<void> removerDoBackend(String id) async {
    final aparelho = porId(id);
    if (aparelho == null) return;
    if (aparelho.backendId.isNotEmpty) {
      await DispositivosApi.excluir(aparelho.backendId);
    }
    removerPorId(id);
  }


  static void reset() {
    locais.value = List<String>.from(locaisSugeridos);
    aparelhos.value = _aparelhosIniciais();
    favoritos.value = <String>{};
    atalhos.value = <AtalhoAparelho>[];
    _proximoAtalho = 1;
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
      atalhos.value = atalhos.value
          .where((atalho) => atalho.aparelhoId != id)
          .toList();
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
