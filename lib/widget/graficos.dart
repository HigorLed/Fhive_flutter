import 'package:flutter/material.dart';
import 'barra_navegacao.dart';

class TelaGraficos extends StatefulWidget {
  const TelaGraficos({super.key});

  @override
  State<TelaGraficos> createState() => _TelaGraficosState();
}

class _TelaGraficosState extends State<TelaGraficos> {
  static const Color marrom = Color(0xFF964900);
  static const Color fundoCard = Color(0xFFFFFABE);
  static const Color fundoCardExterno = Color(0xFFFFE675);

  String aparelhoSelecionado = 'Ventilador';

  bool locaisAbertos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF9E51C),
              Color(0xFFFFC400),
              Color(0xFFE89A00),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // =================================================
                      // CABEÇALHO
                      // =================================================

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              'Minha casa',
                              style: TextStyle(
                                color: marrom,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Adicionar gráfico',
                                  ),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.add,
                              color: marrom,
                              size: 36,
                            ),
                          ),

                          const SizedBox(width: 20),

                          IconButton(
                            onPressed: () {
                              _abrirMenu();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.more_vert,
                              color: marrom,
                              size: 30,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // GRÁFICOS DISPONÍVEIS / LOCAIS
                      // =================================================

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Gráficos disponíveis',
                              style: TextStyle(
                                color: marrom,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                locaisAbertos = !locaisAbertos;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Locais',
                                  style: TextStyle(
                                    color: marrom,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  locaisAbertos
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: marrom,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      if (locaisAbertos) ...[
                        const Text(
                          'Sala de Estar',
                          style: TextStyle(
                            color: marrom,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // CARDS DISPONÍVEIS
                        // =================================================

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: fundoCardExterno,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _cardAparelho(
                                  nome: 'TV - Cristal',
                                  subtitulo: 'Disponível',
                                  icone: Icons.tv_outlined,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _cardAparelho(
                                  nome: 'Ventilador',
                                  subtitulo: 'Disponível',
                                  icone: Icons.air,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // =================================================
                      // GRÁFICOS INDISPONÍVEIS
                      // =================================================

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Gráficos indisponíveis',
                              style: TextStyle(
                                color: marrom,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              const Text(
                                'Locais',
                                style: TextStyle(
                                  color: marrom,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: marrom,
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // AR CONDICIONADO
                      // =================================================

                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'O gráfico do ar condicionado está indisponível.',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 166,
                          height: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4B2),
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.air,
                                color: marrom,
                                size: 34,
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'Ar condicionado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: marrom,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const Text(
                                'Indisponível',
                                style: TextStyle(
                                  color: marrom,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
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

              // =========================================================
              // BARRA DE NAVEGAÇÃO
              // =========================================================

              const BarraNavegacao(
                itemSelecionado: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // CARD DO APARELHO
  // ===============================================================

  Widget _cardAparelho({
    required String nome,
    required String subtitulo,
    required IconData icone,
  }) {
    final bool selecionado = aparelhoSelecionado == nome;

    return GestureDetector(
      onTap: () {
        setState(() {
          aparelhoSelecionado = nome;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 110,
        decoration: BoxDecoration(
          color: fundoCard,
          borderRadius: BorderRadius.circular(22),

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              color: marrom,
              size: 36,
            ),

            const SizedBox(height: 8),

            Text(
              nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: marrom,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            Text(
              subtitulo,
              style: const TextStyle(
                color: marrom,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // MENU
  // ===============================================================

  void _abrirMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4B2),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: marrom,
                ),
                title: const Text(
                  'Atualizar gráficos',
                  style: TextStyle(
                    color: marrom,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Gráficos atualizados!',
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: marrom,
                ),
                title: const Text(
                  'Informações',
                  style: TextStyle(
                    color: marrom,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Gráficos',
                          style: TextStyle(
                            color: marrom,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          'Nesta tela você poderá acompanhar '
                          'os dados dos aparelhos conectados.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Fechar',
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
            ],
          ),
        );
      },
    );
  }
}