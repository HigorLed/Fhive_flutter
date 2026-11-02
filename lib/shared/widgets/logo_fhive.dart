import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

/// Logo + nome do app, usada nas telas de entrada (início, login e cadastro).
class LogoFhive extends StatelessWidget {
  const LogoFhive({super.key});

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
        const SizedBox(width: AppSpacing.xs),
        const Text(
          'Fhive',
          style: AppTextStyles.display,
        ),
      ],
    );
  }
}
