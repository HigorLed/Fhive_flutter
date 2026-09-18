import 'package:flutter/material.dart';
import 'package:tcc_mobile/widget/barra_navegacao.dart';
import 'package:tcc_mobile/widget/aparelho_detalhes.dart';

class TelaAparelhos extends StatelessWidget {
  const TelaAparelhos({super.key});

  static const Color marrom = Color(0xFF9A4F00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE51A),
              Color(0xFFF5A900),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TÍTULO
                      Row(
                        children: [
                          const Text(
                            'Minha casa',
                            style: TextStyle(
                              color: marrom,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.add,
                            color: marrom,
                            size: 35,
                          ),
                          const SizedBox(width: 15),
                          const Icon(
                            Icons.more_vert,
                            color: marrom,
                            size: 28,
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // PESQUISA + LOCAIS
                      Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: marrom,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Todos aparelhos',
                            style: TextStyle(
                              color: marrom,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Locais',
                            style: TextStyle(
                              color: marrom,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: marrom,
                            size: 22,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // SALA DE ESTAR
                      Row(
                        children: [
                          const Text(
                            'Sala de Estar',
                            style: TextStyle(
                              color: marrom,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_up,
                            color: marrom,
                            size: 22,
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // CARDS
                      Row(
                        children: [
                          Expanded(
                            child: _AparelhoCard(
                              titulo: 'TV - Cristal',
                              status: 'Online',
                              icone: Icons.tv,
                              wifi: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TelaDetalhesAparelho(
                                      nome: 'TV - Cristal',
                                      icone: Icons.tv,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _AparelhoCard(
                              titulo: 'Air condicionado',
                              status: 'Offline',
                              icone: Icons.air,
                              wifi: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TelaDetalhesAparelho(
                                      nome: 'Ar condicionado',
                                      icone: Icons.air,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 27),

                      // COZINHA
                      Row(
                        children: [
                          const Text(
                            'Cozinha',
                            style: TextStyle(
                              color: marrom,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: marrom,
                            size: 22,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // BARRA INFERIOR
              const BarraNavegacao(
                itemSelecionado: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// CARD DO APARELHO
// ==========================================================

class _AparelhoCard extends StatelessWidget {
  final String titulo;
  final String status;
  final IconData icone;
  final bool wifi;
  final VoidCallback onTap;

  const _AparelhoCard({
    required this.titulo,
    required this.status,
    required this.icone,
    required this.wifi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 94,
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C9),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 28),
                Icon(
                  icone,
                  color: TelaAparelhos.marrom,
                  size: 32,
                ),
                const Spacer(),
                Icon(
                  wifi ? Icons.wifi : Icons.wifi_off,
                  color: TelaAparelhos.marrom,
                  size: 18,
                ),
              ],
            ),

            const Spacer(),

            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TelaAparelhos.marrom,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              status,
              style: const TextStyle(
                color: TelaAparelhos.marrom,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}