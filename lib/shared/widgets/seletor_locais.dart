import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';

/// Botão "Locais ⌄" que abre/fecha o [PainelLocais]. Mesmo visual da tela
/// de aparelhos; vai no `trailing` de um `TituloSecao`.
class AlternadorLocais extends StatelessWidget {
  const AlternadorLocais({
    super.key,
    required this.aberto,
    required this.aoTocar,
  });

  final bool aberto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Locais',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              aberto ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão "Locais disponíveis" com chips de filtro (Todos + cada local).
/// [selecionado] é `null` quando o filtro é "Todos".
class PainelLocais extends StatelessWidget {
  const PainelLocais({
    super.key,
    required this.locais,
    required this.selecionado,
    required this.aoSelecionar,
  });

  final List<String> locais;
  final String? selecionado;
  final ValueChanged<String?> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final atual = selecionado?.trim().toLowerCase();
    final filtroValido =
        atual != null && locais.any((l) => l.trim().toLowerCase() == atual);

    return CartaoFhive(
      cor: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Locais disponíveis', style: AppTextStyles.bodyBold),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: !filtroValido,
                  onSelected: (_) => aoSelecionar(null),
                ),
                for (final local in locais)
                  ChoiceChip(
                    label: Text(local),
                    selected:
                        filtroValido && local.trim().toLowerCase() == atual,
                    onSelected: (_) => aoSelecionar(local),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
