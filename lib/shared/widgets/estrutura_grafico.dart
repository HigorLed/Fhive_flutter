import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';

/// Estrutura padrão das telas de detalhe dos gráficos (energia, horas usadas,
/// visão geral etc.), seguindo o layout do Figma:
///
///  - gradiente amarelo no fundo;
///  - pílula marrom no topo com "Aparelho | Indicador";
///  - folha creme com cantos superiores arredondados, que traz o botão de
///    voltar, um título opcional e o conteúdo rolável.
class EstruturaTelaGrafico extends StatelessWidget {
  const EstruturaTelaGrafico({
    super.key,
    required this.titulo,
    required this.child,
    this.tituloFolha,
    this.acaoDireita,
    this.destaqueTopo,
    this.rodape,
  });

  /// Texto da pílula marrom, por exemplo "TV Cristal | Energia gasta".
  final String titulo;

  /// Título centralizado no topo da folha creme (ex.: "Gasto Diário").
  final String? tituloFolha;

  /// Widget no canto direito do topo da folha (ex.: selo Online/Offline).
  final Widget? acaoDireita;

  /// Destaque alinhado à direita, entre a pílula e a folha, sobre o
  /// gradiente (ex.: "Total do Dia: 12h").
  final Widget? destaqueTopo;

  /// Conteúdo rolável da folha.
  final Widget child;

  /// Fixo abaixo da folha, como a barra de navegação.
  final Widget? rodape;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                ),
                child: _pilula(),
              ),
              if (destaqueTopo != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    0,
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: destaqueTopo,
                  ),
                ),
              Expanded(child: _folha()),
              ?rodape,
            ],
          ),
        ),
      ),
    );
  }

  Widget _pilula() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        titulo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.cardTitle.copyWith(color: AppColors.white),
      ),
    );
  }

  Widget _folha() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.pageHorizontal,
              0,
            ),
            child: Row(
              children: [
                const BotaoVoltar(),
                Expanded(
                  child: Text(
                    tituloFolha ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle,
                  ),
                ),
                acaoDireita ?? const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.sm,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
