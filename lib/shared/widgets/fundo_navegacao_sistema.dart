import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

/// Mantém o fundo atrás da barra de gestos do Android coerente com a barra
/// inferior do Fhive em todas as rotas, inclusive telas de detalhes.
///
/// Em versões Android que usam edge-to-edge, a barra do sistema é transparente
/// e deixa o app desenhar por trás dela. Em versões anteriores, o estilo do
/// sistema define diretamente a cor da barra.
class FundoNavegacaoSistema extends StatelessWidget {
  const FundoNavegacaoSistema({super.key, required this.child});

  final Widget child;

  static const SystemUiOverlayStyle _estiloSistema = SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.surfaceLight,
    systemNavigationBarDividerColor: AppColors.surfaceLight,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    final double alturaInferior = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _estiloSistema,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (alturaInferior > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: alturaInferior,
              child: const IgnorePointer(
                child: ColoredBox(color: AppColors.surfaceLight),
              ),
            ),
        ],
      ),
    );
  }
}
