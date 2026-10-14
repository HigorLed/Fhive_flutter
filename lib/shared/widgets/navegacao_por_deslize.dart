import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

/// Permite alternar entre as telas principais arrastando horizontalmente.
/// Arrastar para a esquerda avança na ordem da barra inferior; para a direita
/// retorna à tela anterior. Gestos verticais continuam com os scrollables.
class NavegacaoPorDeslize extends StatefulWidget {
  const NavegacaoPorDeslize({
    super.key,
    required this.itemSelecionado,
    required this.child,
  });

  final int itemSelecionado;
  final Widget child;

  @override
  State<NavegacaoPorDeslize> createState() => _NavegacaoPorDeslizeState();
}

class _NavegacaoPorDeslizeState extends State<NavegacaoPorDeslize> {
  double _deslocamentoHorizontal = 0;

  void _finalizarDeslize(DragEndDetails details) {
    const double distanciaMinima = 72;
    if (_deslocamentoHorizontal.abs() < distanciaMinima) return;

    final int proximoIndice =
        widget.itemSelecionado + (_deslocamentoHorizontal < 0 ? 1 : -1);
    final rotas = BarraNavegacao.rotasPrincipais;

    // Não faz wrap do último para o primeiro; a navegação respeita a ordem
    // visual da barra e termina nos seus extremos.
    if (proximoIndice < 0 || proximoIndice >= rotas.length) return;

    final String rotaDestino = rotas[proximoIndice];
    if (ModalRoute.of(context)?.settings.name == rotaDestino) return;

    Navigator.of(context).pushReplacementNamed(rotaDestino);
  }

  @override
  Widget build(BuildContext context) {
    // Em Android com edge-to-edge, a barra de gestos é transparente e mostra
    // o conteúdo desenhado por baixo dela. Estendemos o creme da barra do app
    // até o limite inferior do sistema sem cobrir nem deslocar os ícones.
    final double margemInferiorSistema =
        MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => _deslocamentoHorizontal = 0,
          onHorizontalDragUpdate: (details) {
            _deslocamentoHorizontal += details.delta.dx;
          },
          onHorizontalDragEnd: _finalizarDeslize,
          child: widget.child,
        ),
        if (margemInferiorSistema > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: margemInferiorSistema,
            child: const IgnorePointer(
              child: ColoredBox(color: AppColors.surfaceLight),
            ),
          ),
      ],
    );
  }
}
