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
      'Abra Rotinas, escolha Adicionar rotina, informe um nome e salve. Use o botão de reprodução para registrar a execução da rotina na demonstração.',
    ),
    (
      'Por que alguns dados são demonstrativos?',
      'O aplicativo ainda precisa de uma API, banco de dados e integração com os dispositivos físicos para obter telemetria e enviar comandos reais.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda'),
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.primary,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Como podemos ajudar?',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Arvo',
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
