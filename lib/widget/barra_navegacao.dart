import 'package:flutter/material.dart';
import 'package:tcc_mobile/theme.dart';

class BarraNavegacao extends StatelessWidget {

  final int itemSelecionado;

  const BarraNavegacao({

    super.key,

    required this.itemSelecionado,

  });

  static const Color marrom = AppColors.primary;

  void _navegar(BuildContext context, int index) {

    switch (index) {

      case 0:

        Navigator.pushReplacementNamed(context, '/home');

        break;

      case 1:

        Navigator.pushReplacementNamed(context, '/aparelhos');

        break;

      case 2:

        Navigator.pushReplacementNamed(context, '/graficos');

        break;

      case 3:
        Navigator.pushReplacementNamed(context, '/rotinas');

        break;

      case 4:

        Navigator.pushReplacementNamed(context, '/configuracoes');

        break;

    }

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

          _itemBarra(

            context,

            index: 0,

            icone: Icons.home,

          ),

          _itemBarra(

            context,

            index: 1,

            icone: Icons.devices,

          ),

          _itemBarra(

            context,

            index: 2,

            icone: Icons.pie_chart,

          ),

          _itemBarra(

            context,

            index: 3,

            icone: Icons.light_mode_outlined,

          ),

          _itemBarra(

            context,

            index: 4,

            icone: Icons.settings,

          ),

        ],

      ),

    );

  }

  Widget _itemBarra(

    BuildContext context, {

    required int index,

    required IconData icone,

  }) {

    final bool selecionado = itemSelecionado == index;

    return GestureDetector(

      onTap: () {

        _navegar(context, index);

      },

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 200),

        width: 52,

        height: 52,

        decoration: BoxDecoration(

          color: selecionado

              ? Colors.white

              : Colors.transparent,

          shape: BoxShape.circle,

        ),

        child: Icon(

          icone,

          color: marrom,

          size: selecionado ? 31 : 28,

        ),

      ),

    );

  }

}