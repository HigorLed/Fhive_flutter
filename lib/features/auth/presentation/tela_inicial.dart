import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/logo_fhive.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    const Center(child: LogoFhive()),
                    const Spacer(flex: 5),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/entrar'),
                        child: const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/cadastrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Criar Conta'),
                      ),
                    ),
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
