import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/features/onboarding/presentation/tela_tutorial.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirControleDeSom() {
    final aparelhosTv = AparelhosStore.aparelhos.value
        .where((aparelho) => aparelho.tipo.toLowerCase() == 'tv')
        .toList();
    if (aparelhosTv.isEmpty) {
      _mensagem('Cadastre uma TV para configurar o controle de som.');
      return;
    }
    TelaDetalhesAparelho.abrir(context, aparelhosTv.first);
  }

  void _abrirTutorial() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => const TelaTutorial(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavegacaoPorDeslize(
      itemSelecionado: 0,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
                              onPressed: () => mostrarCriarAparelho(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.section),
                        const TituloSecao(titulo: 'Painel'),
                        const SizedBox(height: AppSpacing.sm),
                        _painel(),
                        const SizedBox(height: AppSpacing.section),
                        _cartaoTutorial(),
                        const SizedBox(height: AppSpacing.section),
                        const TituloSecao(titulo: 'Favoritos'),
                        const SizedBox(height: AppSpacing.sm),
                        _favoritos(),
                      ],
                    ),
                  ),
                ),
                const BarraNavegacao(itemSelecionado: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _painel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardGap),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<AparelhoItem>>(
                  valueListenable: AparelhosStore.aparelhos,
                  builder: (context, aparelhos, _) => _atalhoPainel(
                    icone: Icons.cloud_outlined,
                    titulo: 'Conexões',
                    subtitulo: '${aparelhos.length} aparelhos',
                    onTap: () => Navigator.pushNamed(context, '/aparelhos'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(
                child: _atalhoPainel(
                  icone: Icons.bolt_outlined,
                  titulo: 'Energia',
                  subtitulo: 'Gastos',
                  onTap: () => Navigator.pushNamed(context, '/graficos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.cardGap),
          _atalhoPainel(
            icone: Icons.volume_up_outlined,
            titulo: 'Saída de som',
            subtitulo: 'Configurar',
            onTap: _abrirControleDeSom,
          ),
        ],
      ),
    );
  }

  Widget _atalhoPainel({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(AppRadius.button),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icone, size: 30),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 12),
                    ),
                    Text(
                      subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartaoTutorial() {
    return CartaoFhive(
      cor: AppColors.surface,
      onTap: _abrirTutorial,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: const Icon(Icons.play_circle_outline_rounded, size: 36),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tutorial', style: AppTextStyles.cardTitle),
                SizedBox(height: 2),
                Text(
                  'Aprenda rapidamente como utilizar o Fhive.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  Widget _favoritos() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: AparelhosStore.favoritos,
      builder: (context, favoritos, _) {
        if (favoritos.isEmpty) {
          return CartaoFhive(
            cor: AppColors.surface,
            onTap: () =>
                _mensagem('Toque na estrela de um aparelho para favoritar.'),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.star_border, size: 36),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ainda não há favoritos.',
                    style: AppTextStyles.cardTitle,
                  ),
                ],
              ),
            ),
          );
        }

        final favoritosDados = AparelhosStore.aparelhos.value
            .where((aparelho) => favoritos.contains(aparelho.id))
            .toList();

        return Column(
          children: [
            for (final aparelho in favoritosDados)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AparelhoFavoritoCard(
                  aparelho: aparelho,
                  onTap: () => TelaDetalhesAparelho.abrir(context, aparelho),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AparelhoFavoritoCard extends StatelessWidget {
  final AparelhoItem aparelho;
  final VoidCallback onTap;

  const _AparelhoFavoritoCard({required this.aparelho, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CartaoFhive(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(aparelho.icone, size: 30),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aparelho.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
                Text(aparelho.status, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover dos favoritos',
            onPressed: () => AparelhosStore.alternarFavorito(aparelho.id),
            icon: const Icon(Icons.star_rounded, size: 24),
          ),
        ],
      ),
    );
  }
}
