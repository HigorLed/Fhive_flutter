import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
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
      // O local recém-criado fica disponível no cadastro, mas só aparecerá
      // na lista da casa depois que receber um aparelho.
      _localFiltro = null;
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
                        CabecalhoPagina(
                          titulo: 'Minha casa',
                          acoes: [
                            AcaoCabecalho(
                              icone: Icons.add,
                              tooltip: 'Criar aparelho',
                              onPressed: () => _abrirCriar(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.section),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Todos aparelhos',
                                style: AppTextStyles.sectionTitle,
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
                          const SizedBox(height: AppSpacing.md),
                          ValueListenableBuilder<List<AparelhoItem>>(
                            valueListenable: AparelhosStore.aparelhos,
                            builder: (context, aparelhosAtuais, _) {
                              final locaisDisponiveis =
                                  AparelhosStore.locaisComAparelhos;
                              final filtroDisponivel = _localFiltro != null &&
                                  locaisDisponiveis.any(
                                    (local) => local.toLowerCase() ==
                                        _localFiltro!.toLowerCase(),
                                  );
                              return CartaoFhive(
                                cor: AppColors.surface,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Locais disponíveis',
                                        style: AppTextStyles.bodyBold,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Wrap(
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.sm,
                                        children: [
                                          ChoiceChip(
                                            label: const Text('Todos'),
                                            selected: !filtroDisponivel,
                                            onSelected: (_) => setState(
                                              () => _localFiltro = null,
                                            ),
                                          ),
                                          for (final local in locaisDisponiveis)
                                            ChoiceChip(
                                              label: Text(local),
                                              selected: filtroDisponivel &&
                                                  _localFiltro!.toLowerCase() ==
                                                      local.toLowerCase(),
                                              onSelected: (_) => setState(() {
                                                _localFiltro = local;
                                                _locaisAbertos[local] = true;
                                              }),
                                            ),
                                          ActionChip(
                                            avatar: const Icon(
                                              Icons.add_location_alt_outlined,
                                              size: 18,
                                            ),
                                            label: const Text('Criar local'),
                                            onPressed: _criarLocal,
                                            backgroundColor:
                                                AppColors.surfaceStrong,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: AppSpacing.section),
                        ValueListenableBuilder<List<AparelhoItem>>(
                          valueListenable: AparelhosStore.aparelhos,
                          builder: (context, aparelhos, _) {
                            final locais = AparelhosStore.locaisComAparelhos;
                            final filtroDisponivel = _localFiltro != null &&
                                locais.any(
                                  (local) => local.toLowerCase() ==
                                      _localFiltro!.toLowerCase(),
                                );
                            final locaisExibidos = filtroDisponivel
                                ? locais
                                      .where(
                                        (local) =>
                                            local.toLowerCase() ==
                                            _localFiltro!.toLowerCase(),
                                      )
                                      .toList()
                                : locais;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final local in locaisExibidos) ...[
                                  _cabecalhoLocal(
                                    local,
                                    aparelhos
                                        .where(
                                          (aparelho) =>
                                              aparelho.local.trim().toLowerCase() ==
                                              local.trim().toLowerCase(),
                                        )
                                        .length,
                                  ),
                                  if (_locaisAbertos[local] ?? true) ...[
                                    const SizedBox(height: AppSpacing.md),
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
                                  ],
                                  const SizedBox(height: AppSpacing.section),
                                ],
                                if (locaisExibidos.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      filtroDisponivel
                                          ? 'Nenhum aparelho cadastrado neste local.'
                                          : 'Nenhum aparelho cadastrado.',
                                      style: AppTextStyles.bodyBold,
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
                style: AppTextStyles.cardTitle,
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
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: aparelhos
          .map(
            (aparelho) => SizedBox(
              width: (MediaQuery.sizeOf(context).width -
                      2 * AppSpacing.pageHorizontal -
                      AppSpacing.md) /
                  2,
              child: _AparelhoCard(
                aparelho: aparelho,
                onTap: () => TelaDetalhesAparelho.abrir(context, aparelho),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
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
              style: AppTextStyles.cardTitle,
            ),
            Text(
              aparelho.status,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
