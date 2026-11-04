import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

/// Cabeçalho padrão das telas principais: título à esquerda e ações à direita.
class CabecalhoPagina extends StatelessWidget {
  const CabecalhoPagina({
    super.key,
    required this.titulo,
    this.acoes = const <Widget>[],
  });

  final String titulo;
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.pageTitle,
          ),
        ),
        ...acoes,
      ],
    );
  }
}

/// Botão de ícone padrão do cabeçalho (mesmo tamanho em todas as telas).
class AcaoCabecalho extends StatelessWidget {
  const AcaoCabecalho({
    super.key,
    required this.icone,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icone;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icone, size: 28),
    );
  }
}

/// Título de seção com ação opcional à direita (ex.: filtro "Locais").
class TituloSecao extends StatelessWidget {
  const TituloSecao({super.key, required this.titulo, this.trailing});

  final String titulo;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(titulo, style: AppTextStyles.sectionTitle)),
        ?trailing,
      ],
    );
  }
}

/// Cartão padrão: fundo creme, raio [AppRadius.card].
class CartaoFhive extends StatelessWidget {
  const CartaoFhive({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.cor = AppColors.surfaceLight,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color cor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borda = BorderRadius.circular(AppRadius.card);
    return Material(
      color: cor,
      borderRadius: borda,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Botão "voltar" padrão das telas secundárias.
class BotaoVoltar extends StatelessWidget {
  const BotaoVoltar({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Voltar',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded, size: 26),
    );
  }
}
