import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';

class TelaAparelhos extends StatefulWidget {
  const TelaAparelhos({super.key});

  static const Color marrom = AppColors.primary;

  @override
  State<TelaAparelhos> createState() => _TelaAparelhosState();
}

class _TelaAparelhosState extends State<TelaAparelhos> {
  final Map<String, bool> _locaisAbertos = <String, bool>{};
  bool _mostrarLocaisDisponiveis = false;
  String? _localFiltro;

  void _abrirCriar(BuildContext context) {
    mostrarCriarAparelho(context);
  }

  void _alternarLocal(String local) {
    setState(() {
      _locaisAbertos[local] = !(_locaisAbertos[local] ?? true);
    });
  }

  Future<void> _criarLocal() async {
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Criar local'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nome do local',
            hintText: 'Ex.: Quarto de jogos',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          onSubmitted: (valor) => Navigator.of(dialogContext).pop(valor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Criar local'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted || nome == null) return;
    final nomeLimpo = nome.trim();
    if (nomeLimpo.isEmpty) {
      _mensagemLocal('Digite um nome para o local.');
      return;
    }
    if (!AparelhosStore.adicionarLocal(nomeLimpo)) {
      _mensagemLocal('Esse local já existe. Escolha outro nome.');
      return;
    }

    setState(() {
      _mostrarLocaisDisponiveis = true;
      _localFiltro = nomeLimpo;
      _locaisAbertos[nomeLimpo] = true;
    });
    _mensagemLocal('Local "$nomeLimpo" criado.');
  }

  void _mensagemLocal(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return NavegacaoPorDeslize(
      itemSelecionado: 1,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.main),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.pageTop,
                      AppSpacing.pageHorizontal,
                      AppSpacing.pageBottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Minha casa',
                                style: AppTextStyles.pageTitle,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _abrirCriar(context),
                              tooltip: 'Criar aparelho',
                              icon: const Icon(
                                Icons.add,
                                color: TelaAparelhos.marrom,
                                size: 30,
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Menu',
                              icon: const Icon(
                                Icons.more_vert,
                                color: TelaAparelhos.marrom,
                                size: 26,
                              ),
                              onSelected: (acao) {
                                switch (acao) {
                                  case 'atualizar':
                                    setState(() {});
                                    _mensagemLocal(
                                      'Lista de aparelhos atualizada.',
                                    );
                                    break;
                                  case 'local':
                                    _criarLocal();
                                    break;
                                  case 'ajuda':
                                    showDialog<void>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Aparelhos'),
                                        content: const Text(
                                          'Toque em um cartão para abrir os controles. Use a estrela para favoritar, os filtros de local para organizar os aparelhos e o botão + para cadastrar um novo dispositivo.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            child: const Text('Fechar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'atualizar',
                                  child: Text('Atualizar lista'),
                                ),
                                PopupMenuItem(
                                  value: 'local',
                                  child: Text('Criar local'),
                                ),
                                PopupMenuItem(
                                  value: 'ajuda',
                                  child: Text('Ajuda'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.section),
                        Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: TelaAparelhos.marrom,
                              size: 24,
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'Todos aparelhos',
                                style: TextStyle(
                                  color: TelaAparelhos.marrom,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() {
                                _mostrarLocaisDisponiveis =
                                    !_mostrarLocaisDisponiveis;
                              }),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Locais',
                                      style: TextStyle(
                                        color: TelaAparelhos.marrom,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      _mostrarLocaisDisponiveis
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: TelaAparelhos.marrom,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_mostrarLocaisDisponiveis) ...[
                          const SizedBox(height: 12),
                          ValueListenableBuilder<List<String>>(
                            valueListenable: AparelhosStore.locais,
                            builder: (context, locaisRegistrados, _) {
                              final locaisDisponiveis =
                                  AparelhosStore.locaisDisponiveis;
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(
                                    alpha: 0.88,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: TelaAparelhos.marrom.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Locais disponíveis',
                                      style: TextStyle(
                                        color: TelaAparelhos.marrom,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Wrap(
                                      spacing: 7,
                                      runSpacing: 7,
                                      children: [
                                        ChoiceChip(
                                          label: const Text('Todos'),
                                          selected: _localFiltro == null,
                                          onSelected: (_) => setState(
                                            () => _localFiltro = null,
                                          ),
                                          selectedColor: AppColors.accent,
                                          backgroundColor:
                                              AppColors.surfaceLight,
                                          labelStyle: const TextStyle(
                                            color: TelaAparelhos.marrom,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                          side: BorderSide(
                                            color: TelaAparelhos.marrom
                                                .withValues(alpha: 0.16),
                                          ),
                                        ),
                                        for (final local in locaisDisponiveis)
                                          ChoiceChip(
                                            label: Text(local),
                                            selected: _localFiltro == local,
                                            onSelected: (_) => setState(() {
                                              _localFiltro = local;
                                              _locaisAbertos[local] = true;
                                            }),
                                            selectedColor: AppColors.accent,
                                            backgroundColor:
                                                AppColors.surfaceLight,
                                            labelStyle: const TextStyle(
                                              color: TelaAparelhos.marrom,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                            side: BorderSide(
                                              color: TelaAparelhos.marrom
                                                  .withValues(alpha: 0.16),
                                            ),
                                          ),
                                        ActionChip(
                                          avatar: const Icon(
                                            Icons.add_location_alt_outlined,
                                            size: 17,
                                            color: TelaAparelhos.marrom,
                                          ),
                                          label: const Text('Criar local'),
                                          onPressed: _criarLocal,
                                          backgroundColor:
                                              AppColors.surfaceStrong,
                                          labelStyle: const TextStyle(
                                            color: TelaAparelhos.marrom,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                          side: BorderSide(
                                            color: TelaAparelhos.marrom
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 28),
                        ValueListenableBuilder<List<AparelhoItem>>(
                          valueListenable: AparelhosStore.aparelhos,
                          builder: (context, aparelhos, _) {
                            final locais = AparelhosStore.locaisDisponiveis;
                            final locaisExibidos = _localFiltro == null
                                ? locais
                                : <String>[_localFiltro!];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final local in locaisExibidos) ...[
                                  _cabecalhoLocal(
                                    local,
                                    aparelhos
                                        .where(
                                          (aparelho) => aparelho.local.trim().toLowerCase() == local.trim().toLowerCase(),
                                        )
                                        .length,
                                  ),
                                  if (_locaisAbertos[local] ?? true) ...[
                                    const SizedBox(height: 18),
                                    if (aparelhos.any(
                                      (aparelho) => aparelho.local.trim().toLowerCase() == local.trim().toLowerCase(),
                                    ))
                                      _gradeAparelhos(
                                        context,
                                        aparelhos
                                            .where(
                                              (aparelho) =>
                                                  aparelho.local.trim().toLowerCase() ==
                                                  local.trim().toLowerCase(),
                                            )
                                            .toList(),
                                      )
                                    else
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          'Nenhum aparelho neste local ainda. Use + para adicionar um dispositivo.',
                                          style: TextStyle(
                                            color: TelaAparelhos.marrom,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 27),
                                ],
                                if (locaisExibidos.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _localFiltro == null
                                          ? 'Nenhum aparelho cadastrado.'
                                          : 'Nenhum aparelho cadastrado neste local.',
                                      style: const TextStyle(
                                        color: TelaAparelhos.marrom,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const BarraNavegacao(itemSelecionado: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalhoLocal(String local, int quantidade) {
    final aberto = _locaisAbertos[local] ?? true;

    return InkWell(
      onTap: () => _alternarLocal(local),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                local,
                style: const TextStyle(
                  color: TelaAparelhos.marrom,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$quantidade',
              style: TextStyle(
                color: TelaAparelhos.marrom.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              aberto ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: TelaAparelhos.marrom,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeAparelhos(BuildContext context, List<AparelhoItem> aparelhos) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: aparelhos
          .map(
            (aparelho) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 50) / 2,
              child: _AparelhoCard(
                aparelho: aparelho,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaDetalhesAparelho(
                        nome: aparelho.nome,
                        id: aparelho.id,
                        tipo: aparelho.tipo,
                        fabricante: aparelho.fabricante,
                        modelo: aparelho.modelo,
                        local: aparelho.local,
                        conexao: aparelho.conexao,
                        status: aparelho.status,
                        icone: aparelho.icone,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AparelhoCard extends StatelessWidget {
  final AparelhoItem aparelho;
  final VoidCallback onTap;

  const _AparelhoCard({required this.aparelho, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 108,
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C9),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(aparelho.icone, color: TelaAparelhos.marrom, size: 31),
                const Spacer(),
                Icon(
                  aparelho.conexao == 'Bluetooth'
                      ? Icons.bluetooth
                      : aparelho.conexao == 'Ethernet'
                      ? Icons.lan_outlined
                      : aparelho.wifi
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: TelaAparelhos.marrom,
                  size: 18,
                ),
                ValueListenableBuilder<Set<String>>(
                  valueListenable: AparelhosStore.favoritos,
                  builder: (context, favoritos, _) {
                    final ativo = favoritos.contains(aparelho.id);
                    return IconButton(
                      onPressed: () {
                        AparelhosStore.alternarFavorito(aparelho.nome);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ativo
                                  ? 'Removido dos favoritos.'
                                  : 'Adicionado aos favoritos.',
                            ),
                          ),
                        );
                      },
                      tooltip: ativo
                          ? 'Remover dos favoritos'
                          : 'Adicionar aos favoritos',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        ativo ? Icons.star : Icons.star_border,
                        color: TelaAparelhos.marrom,
                        size: 22,
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Text(
              aparelho.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TelaAparelhos.marrom,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              aparelho.status,
              style: const TextStyle(
                color: TelaAparelhos.marrom,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
