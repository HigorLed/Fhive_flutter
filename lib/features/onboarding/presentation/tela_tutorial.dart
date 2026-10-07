import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

class TelaTutorial extends StatefulWidget {
  const TelaTutorial({super.key});

  @override
  State<TelaTutorial> createState() => _TelaTutorialState();
}

class _TelaTutorialState extends State<TelaTutorial> {
  final PageController controller = PageController();

  int paginaAtual = 0;

  final List<_TutorialPagina> paginas = [
    const _TutorialPagina(
      titulo: 'Bem-vindo ao Fhive',
      descricao:
          'Conheça as principais funções do aplicativo e descubra como controlar seus dispositivos.',
      icone: Icons.home_outlined,
      secundarios: [Icons.devices_outlined, Icons.cloud_outlined],
    ),
    const _TutorialPagina(
      titulo: 'Seus dispositivos',
      descricao:
          'Acesse seus aparelhos rapidamente e tenha controle sobre os dispositivos conectados.',
      icone: Icons.devices_outlined,
      secundarios: [Icons.lightbulb_outline, Icons.power_settings_new],
    ),
    const _TutorialPagina(
      titulo: 'Automação',
      descricao: 'Crie automações e deixe tarefas do dia a dia mais práticas.',
      icone: Icons.auto_awesome,
      secundarios: [Icons.schedule, Icons.notifications_none],
    ),
    const _TutorialPagina(
      titulo: 'Dados e energia',
      descricao:
          'Visualize informações e acompanhe o consumo dos seus dispositivos.',
      icone: Icons.bar_chart,
      secundarios: [Icons.bolt_outlined, Icons.show_chart],
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void avancar() {
    if (paginaAtual < paginas.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void voltar() {
    if (paginaAtual > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),

      child: Container(
        width: tamanho.width,
        height: tamanho.height * 0.78,

        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: paginas.length,

                    onPageChanged: (index) {
                      setState(() {
                        paginaAtual = index;
                      });
                    },

                    itemBuilder: (context, index) {
                      return _conteudo(paginas[index]);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 20, 22),

                  child: Row(
                    children: [
                      _indicadores(),

                      const Spacer(),

                      if (paginaAtual > 0)
                        IconButton(
                          onPressed: voltar,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.accent,
                            size: 21,
                          ),
                        ),

                      TextButton(
                        onPressed: avancar,
                        child: Row(
                          children: [
                            Text(
                              paginaAtual == paginas.length - 1
                                  ? 'Finalizar'
                                  : 'Avançar',

                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 5),

                            Icon(
                              paginaAtual == paginas.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 10,
              right: 8,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(
                  Icons.close,
                  color: AppColors.accent,
                  size: 31,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conteudo(_TutorialPagina pagina) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 55, 28, 0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: Center(child: _ilustracao(pagina))),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pagina.titulo,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    pagina.descricao,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ilustracao(_TutorialPagina pagina) {
    return Stack(
      alignment: Alignment.center,

      children: [
        Container(
          width: 210,
          height: 210,

          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
        ),

        Container(
          width: 105,
          height: 105,

          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(25),
          ),

          child: Icon(pagina.icone, color: AppColors.primary, size: 55),
        ),

        Positioned(
          top: 20,
          left: 12,
          child: _iconeSecundario(pagina.secundarios[0]),
        ),

        Positioned(
          right: 12,
          bottom: 20,
          child: _iconeSecundario(pagina.secundarios[1]),
        ),
      ],
    );
  }

  Widget _iconeSecundario(IconData icone) {
    return Container(
      width: 58,
      height: 58,

      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(17),
      ),

      child: Icon(icone, color: AppColors.primary, size: 28),
    );
  }

  Widget _indicadores() {
    return Row(
      children: List.generate(paginas.length, (index) {
        final ativo = index == paginaAtual;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          margin: const EdgeInsets.only(right: 8),

          width: ativo ? 20 : 8,
          height: 8,

          decoration: BoxDecoration(
            color: ativo
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.30),

            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _TutorialPagina {
  final String titulo;
  final String descricao;
  final IconData icone;
  final List<IconData> secundarios;

  const _TutorialPagina({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.secundarios,
  });
}
