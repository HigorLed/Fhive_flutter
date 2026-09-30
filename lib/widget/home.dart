import 'package:flutter/material.dart';
import 'package:tcc_mobile/theme.dart';

import 'package:tcc_mobile/widget/confi.dart';
import 'package:tcc_mobile/widget/barra_navegacao.dart';
import 'package:tcc_mobile/widget/tela_tutorial.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  final Color marrom = AppColors.primary;
  final Color amarelo = AppColors.accent;
  final Color amareloClaro = AppColors.surface;

void mostrarMensagem(String mensagem) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensagem,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      behavior: SnackBarBehavior.floating,

      // Controla a distância das bordas
      margin: const EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: 69,
      ),

      backgroundColor: marrom,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),

      duration: const Duration(seconds: 2),
    ),
  );
}
  void abrirAdicionar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adicionar',
                style: TextStyle(
                  color: marrom,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _opcaoAdicionar(
                Icons.devices_other,
                'Adicionar aparelho',
              ),

              _opcaoAdicionar(
                Icons.star_border,
                'Adicionar aos favoritos',
              ),

              _opcaoAdicionar(
                Icons.person_add_alt_1,
                'Adicionar pessoa',
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _opcaoAdicionar(
    IconData icone,
    String texto,
  ) {
    return ListTile(
      leading: Icon(
        icone,
        color: marrom,
        size: 28,
      ),
      title: Text(
        texto,
        style: TextStyle(
          color: marrom,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onTap: () {
        Navigator.pop(context);
        mostrarMensagem('$texto selecionado');
      },
    );
  }

  void abrirMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  color: marrom,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: marrom,
                ),
                title: Text(
                  'Configurações',
                  style: TextStyle(
                    color: marrom,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushReplacementNamed(
                    context,
                    '/configuracoes',
                  );
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.person,
                  color: marrom,
                ),
                title: Text(
                  'Minha conta',
                  style: TextStyle(
                    color: marrom,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  mostrarMensagem('Minha conta');
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: marrom,
                ),
                title: Text(
                  'Ajuda',
                  style: TextStyle(
                    color: marrom,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  mostrarMensagem('Ajuda');
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: marrom,
                ),
                title: Text(
                  'Sair',
                  style: TextStyle(
                    color: marrom,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Sair'),

                        content: const Text(
                          'Deseja realmente sair da conta?',
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: marrom,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);

                              mostrarMensagem(
                                'Saindo...',
                              );
                            },
                            child: Text(
                              'Sair',
                              style: TextStyle(
                                color: marrom,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: amarelo,

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: AppGradients.main,
          ),

          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageTop,
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageBottom,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // CABEÇALHO
                      Row(
                        children: [
                          Text(
                            'Minha casa',
                            style: AppTextStyles.pageTitle,
                          ),

                          const Spacer(),

                          IconButton(
                            onPressed: abrirAdicionar,
                            icon: Icon(
                              Icons.add,
                              color: marrom,
                              size: 30,
                            ),
                            tooltip: 'Adicionar',
                          ),

                          IconButton(
                            onPressed: abrirMenu,
                            icon: Icon(
                              Icons.more_vert,
                              color: marrom,
                              size: 26,
                            ),
                            tooltip: 'Menu',
                          ),
                        ],
                      ),

                      const SizedBox(height: 19),

                      // PAINEL
                      Text(
                        'Painel',
                        style: TextStyle(
                          color: marrom,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Arvo',
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceStrong,
                          borderRadius:
                              BorderRadius.circular(21),
                        ),

                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _cartaoPainel(
                                    icone:
                                        Icons.cloud_outlined,
                                    titulo: 'Conexões',
                                    subtitulo:
                                        '0 aparelhos',
                                    onTap: () {
                                      mostrarMensagem(
                                        'Nenhum aparelho conectado.',
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: _cartaoPainel(
                                    icone:
                                        Icons.bolt_outlined,
                                    titulo: 'Energia',
                                    subtitulo: 'Gastos',
                                    onTap: () {
                                      mostrarMensagem(
                                        'Abrindo informações de energia.',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: _cartaoPainel(
                                    icone: Icons
                                        .volume_up_outlined,
                                    titulo:
                                        'Saída de som',
                                    subtitulo:
                                        'Configurar',
                                    onTap: () {
                                      mostrarMensagem(
                                        'Configurando saída de som.',
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: _cartaoPainel(
                                    icone: Icons
                                        .favorite_border,
                                    titulo: 'Vida+',
                                    subtitulo: 'Saiba mais',
                                    onTap: () {
                                      mostrarMensagem(
                                        'Abrindo Vida+.',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      _cartaoTutorial(),

                      const SizedBox(height: 17),

                      // FAVORITOS
                      Text(
                        'Favoritos',
                        style: TextStyle(
                          color: marrom,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Arvo',
                        ),
                      ),

                      const SizedBox(height: 9),

                      InkWell(
                        borderRadius:
                            BorderRadius.circular(16),

                        onTap: () {
                          mostrarMensagem(
                            'Você ainda não possui favoritos.',
                          );
                        },

                        child: Container(
                          width: double.infinity,
                          height: 98,

                          decoration: BoxDecoration(
                            color: amareloClaro,
                            borderRadius:
                                BorderRadius.circular(15),
                          ),

                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              Icon(
                                Icons.close,
                                color: marrom,
                                size: 37,
                              ),

                              const SizedBox(height: 7),

                              Text(
                                'Não possui favoritos',
                                style: TextStyle(
                                  color: marrom,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w700,
                                  fontFamily: 'Arvo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BARRA NOVA
              const BarraNavegacao(
                itemSelecionado: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartaoPainel({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),

      child: Container(
        height: 55,

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),

        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          children: [
            Icon(
              icone,
              color: marrom,
              size: 32,
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: TextStyle(
                      color: marrom,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    subtitulo,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: TextStyle(
                      color: marrom,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
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

  Widget _cartaoTutorial() {
  return InkWell(
    borderRadius: BorderRadius.circular(15),

    onTap: () {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (context) {
      return const TelaTutorial();
    },
  );
},

    child: Container(
      width: double.infinity,
      height: 98,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: amareloClaro,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          Container(
            width: 80,
            height: 75,

            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE8),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(
              Icons.play_circle_outline,
              color: marrom,
              size: 47,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tutorial',
                  style: TextStyle(
                    color: marrom,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Arvo',
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Aprenda rapidamente como utilizar o Fhive.',
                  style: TextStyle(
                    color: marrom,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
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