import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

/// Barra de navegação inferior usada em todas as telas principais.
class BarraNavegacao extends StatelessWidget {
  final int itemSelecionado;

  const BarraNavegacao({super.key, required this.itemSelecionado});

  static const Color marrom = AppColors.primary;

  /// Rotas na mesma ordem dos ícones da barra.
  static const List<String> _rotas = [
    '/home',
    '/aparelhos',
    '/graficos',
    '/rotinas',
    '/configuracoes',
  ];

  void _navegar(BuildContext context, int index) {
    final String rota = _rotas[index];

    // Evita recriar a tela quando o usuário toca na aba em que já está.
    if (ModalRoute.of(context)?.settings.name == rota) {
      return;
    }

    Navigator.pushReplacementNamed(context, rota);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.navigation),
          topRight: Radius.circular(AppRadius.navigation),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _itemBarra(context, index: 0, icone: Icons.home, rotulo: 'Início'),
          _itemBarra(
            context,
            index: 1,
            icone: Icons.devices,
            rotulo: 'Aparelhos',
          ),
          _itemBarra(
            context,
            index: 2,
            icone: Icons.pie_chart,
            rotulo: 'Gráficos',
          ),
          _itemBarra(
            context,
            index: 3,
            icone: Icons.light_mode_outlined,
            rotulo: 'Rotinas',
          ),
          _itemBarra(
            context,
            index: 4,
            icone: Icons.settings,
            rotulo: 'Configurações',
          ),
        ],
      ),
    );
  }

  Widget _itemBarra(
    BuildContext context, {
    required int index,
    required IconData icone,
    required String rotulo,
  }) {
    final bool selecionado = itemSelecionado == index;

    return Semantics(
      button: true,
      selected: selecionado,
      label: rotulo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _navegar(context, index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: selecionado ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: marrom, size: selecionado ? 31 : 28),
        ),
      ),
    );
  }
}
