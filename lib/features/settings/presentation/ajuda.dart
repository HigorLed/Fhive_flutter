import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

class TelaAjuda extends StatelessWidget {
  const TelaAjuda({super.key});

  static const _duvidas = <(String, String)>[
    (
      'Como adicionar um aparelho?',
      'Abra Aparelhos ou toque no botão +. Informe o nome e o ID, selecione o tipo e o local, configure os dados de conexão e revise antes de adicionar. O pareamento real depende da integração com o aparelho IoT.',
    ),
    (
      'Como favoritar um aparelho?',
      'Na tela Aparelhos, toque na estrela do cartão. Os favoritos também ficam disponíveis na tela Início e podem ser removidos diretamente por lá.',
    ),
    (
      'Como criar uma rotina?',
      'Abra Rotinas, escolha Adicionar rotina, selecione o aparelho e o horário e salve. A rotina é persistida no backend. A API atual ainda não executa comandos físicos; o botão informa essa limitação.',
    ),
    (
      'Por que alguns dados são demonstrativos?',
      'A autenticação, o perfil, os aparelhos e as rotinas usam o backend. As métricas sem telemetria MQTT real continuam demonstrativas, e os comandos físicos dos aparelhos ainda não estão conectados a uma API de controle.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Ajuda')),
=======
      appBar: AppBar(
        title: const Text('Ajuda'),
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.primary,
      ),
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: ListView(
<<<<<<< HEAD
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          children: [
            const Text(
              'Como podemos ajudar?',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Encontre orientações sobre as principais funções do Fhive.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.section),
            for (final duvida in _duvidas)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Material(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Text(duvida.$1, style: AppTextStyles.bodyBold),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          duvida.$2,
                          style: AppTextStyles.body.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
=======
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Como podemos ajudar?',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: AppFonts.title,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Encontre orientações sobre as principais funções do Fhive.',
              style: TextStyle(color: AppColors.primaryDark),
            ),
            const SizedBox(height: 18),
            for (final duvida in _duvidas)
              Card(
                color: AppColors.surfaceLight.withValues(alpha: 0.94),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.primary,
                  title: Text(
                    duvida.$1,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        duvida.$2,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
                ),
              ),
          ],
        ),
      ),
    );
  }
}
