import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    const _LogoFhive(),
                    const Spacer(flex: 5),
                    _BotaoPrincipal(
                      texto: 'Entrar',
                      fundo: AppColors.primary,
                      textoCor: Colors.white,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/entrar'),
                    ),
                    const SizedBox(height: 14),
                    _BotaoPrincipal(
                      texto: 'Criar Conta',
                      fundo: const Color(0xFFFFF6A1),
                      textoCor: AppColors.primary,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/cadastrar'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoFhive extends StatelessWidget {
  const _LogoFhive();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/logo.svg',
          width: 60,
          height: 52,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Fhive',
          style: TextStyle(
            color: AppColors.primary,
            fontFamily: 'Arvo',
            fontSize: 42,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _BotaoPrincipal extends StatelessWidget {
  const _BotaoPrincipal({
    required this.texto,
    required this.fundo,
    required this.textoCor,
    required this.onPressed,
  });

  final String texto;
  final Color fundo;
  final Color textoCor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: fundo,
          foregroundColor: textoCor,
          elevation: 3,
          shadowColor: Colors.black26,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
