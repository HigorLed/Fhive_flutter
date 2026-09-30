import 'package:flutter/material.dart';

import 'package:tcc_mobile/theme.dart';
import 'package:tcc_mobile/widget/barra_navegacao.dart';

enum TipoAparelho {
  tv,
  arCondicionado,
}

// ================================================================
// TELA PRINCIPAL DE GRÁFICOS
// ================================================================

class TelaGraficos extends StatefulWidget {
  const TelaGraficos({super.key});

  @override
  State<TelaGraficos> createState() => _TelaGraficosState();
}

class _TelaGraficosState extends State<TelaGraficos> {
  static const Color marrom = AppColors.primary;
  static const Color fundoCard = AppColors.input;
  static const Color fundoCardExterno = AppColors.surfaceStrong;

  bool locaisAbertos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: SafeArea(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // CABEÇALHO
                      // ==================================================

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Minha casa',
                              style: AppTextStyles.pageTitle,
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
                              size: 30,
                            ),
                          ),

                          const SizedBox(width: 12),

                          IconButton(
                            onPressed: _abrirMenu,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.more_vert,
                              color: marrom,
                              size: 26,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: AppSpacing.section,
                      ),

                      // ==================================================
                      // GRÁFICOS DISPONÍVEIS
                      // ==================================================

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Gráficos disponíveis',
                              style: TextStyle(
                                color: marrom,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Arvo',
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

                        // ==================================================
                        // APARELHOS
                        // ==================================================

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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TelaGraficosDetalhes(
                                          tipo: TipoAparelho.tv,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _cardAparelho(
                                    nome: 'TV - Cristal',
                                    subtitulo: 'Disponível',
                                    icone: Icons.tv_outlined,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TelaGraficosDetalhes(
                                          tipo:
                                              TipoAparelho.arCondicionado,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _cardAparelho(
                                    nome: 'Ar condicionado',
                                    subtitulo: 'Disponível',
                                    icone: Icons.air,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ==================================================
                        // GRÁFICOS INDISPONÍVEIS
                        // ==================================================

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
                              children: const [
                                Text(
                                  'Locais',
                                  style: TextStyle(
                                    color: marrom,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: marrom,
                                  size: 22,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'O gráfico deste aparelho está indisponível.',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 166,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFF4B2,
                              ).withOpacity(0.60),
                              borderRadius: BorderRadius.circular(21),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.devices_other,
                                  color: marrom,
                                  size: 34,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Outro aparelho',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: marrom,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
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
                    ],
                  ),
                ),
              ),

              const BarraNavegacao(
                itemSelecionado: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CARD DE APARELHO
  // ================================================================

  Widget _cardAparelho({
    required String nome,
    required String subtitulo,
    required IconData icone,
  }) {
    return AnimatedContainer(
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
    );
  }

  // ================================================================
  // MENU
  // ================================================================

  void _abrirMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
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

// ================================================================
// TELA DE DETALHES
// ================================================================

class TelaGraficosDetalhes extends StatefulWidget {
  final TipoAparelho tipo;

  const TelaGraficosDetalhes({
    super.key,
    required this.tipo,
  });

  @override
  State<TelaGraficosDetalhes> createState() =>
      _TelaGraficosDetalhesState();
}

class _TelaGraficosDetalhesState
    extends State<TelaGraficosDetalhes> {
  static const Color marrom = AppColors.primary;
  static const Color laranja = Color(0xFFE56C1F);
  static const Color amareloCard = Color(0xFFFFE48A);
  static const Color amareloClaro = Color(0xFFFFF4B2);
  static const Color textoSecundario = Color(0xFF8C743B);

  // ================================================================
  // PERÍODO DO GRÁFICO
  // ================================================================

  String periodoSelecionado = '7 dias';

  bool get isTv => widget.tipo == TipoAparelho.tv;

  String get nomeAparelho {
    return isTv ? 'TV - Cristal' : 'Ar condicionado';
  }

  IconData get iconeAparelho {
    return isTv ? Icons.tv_outlined : Icons.air;
  }

  int get pontos {
    return isTv ? 76 : 82;
  }

  double get gastoEnergia {
    return isTv ? 12.5 : 28.4;
  }

  int get horasUsadas {
    return isTv ? 12 : 18;
  }

  String get terceiraValor {
    return isTv ? '72%' : '23°C';
  }

  String get avaliacao {
    return pontos >= 80
        ? 'Bom controle'
        : pontos >= 60
            ? 'Controle moderado'
            : 'Precisa de atenção';
  }

  // ================================================================
  // DADOS DO GRÁFICO
  // ================================================================

  List<double> get valoresGrafico {
    if (periodoSelecionado == '7 dias') {
      return isTv
          ? [
              0.64,
              0.49,
              0.57,
              0.35,
              0.61,
              0.43,
              0.22,
            ]
          : [
              0.72,
              0.61,
              0.75,
              0.51,
              0.69,
              0.43,
              0.32,
            ];
    }

    if (periodoSelecionado == '4 semanas') {
      return isTv
          ? [
              0.67,
              0.48,
              0.58,
              0.36,
            ]
          : [
              0.80,
              0.62,
              0.73,
              0.49,
            ];
    }

    return isTv
        ? [
            0.70,
            0.58,
            0.46,
            0.61,
            0.41,
            0.32,
          ]
        : [
            0.82,
            0.72,
            0.77,
            0.63,
            0.58,
            0.47,
          ];
  }

  List<String> get etiquetasGrafico {
    if (periodoSelecionado == '7 dias') {
      return [
        'Seg',
        'Ter',
        'Qua',
        'Qui',
        'Sex',
        'Sáb',
        'Dom',
      ];
    }

    if (periodoSelecionado == '4 semanas') {
      return [
        'Sem. 1',
        'Sem. 2',
        'Sem. 3',
        'Sem. 4',
      ];
    }

    return [
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // CABEÇALHO
                      // ==================================================

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: amareloClaro.withOpacity(0.80),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: marrom,
                                size: 25,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      iconeAparelho,
                                      color: marrom,
                                      size: 23,
                                    ),

                                    const SizedBox(width: 6),

                                    Expanded(
                                      child: Text(
                                        nomeAparelho,
                                        style: const TextStyle(
                                          color: marrom,
                                          fontSize: 22,
                                          fontWeight:
                                              FontWeight.w800,
                                          fontFamily: 'Arvo',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 3),

                                const Text(
                                  'Visão geral do aparelho',
                                  style: TextStyle(
                                    color: textoSecundario,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ==================================================
                          // STATUS
                          // ==================================================

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(0.60),
                              borderRadius:
                                  BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration:
                                      const BoxDecoration(
                                    color: Color(0xFF63A33B),
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 6),

                                const Text(
                                  'Ativo',
                                  style: TextStyle(
                                    color: marrom,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // RESUMO PRINCIPAL
                      // ==================================================

                      _cardResumo(),

                      const SizedBox(height: 22),

                      // ==================================================
                      // CONSUMO
                      // ==================================================

                      const Text(
                        'Seu consumo',
                        style: TextStyle(
                          color: marrom,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Arvo',
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _cardConsumo(),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _cardHorasUso(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ==================================================
                      // GRÁFICO
                      // ==================================================

                      _cardGrafico(),

                      const SizedBox(height: 24),

                      // ==================================================
                      // INFORMAÇÕES EXTRAS
                      // ==================================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _cardInfoEspecifica(),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _cardEficiencia(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const BarraNavegacao(
                itemSelecionado: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CARD RESUMO COM PENTÁGONO
  // ================================================================

  Widget _cardResumo() {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE27A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            height: 105,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(
                    100,
                    95,
                  ),
                  painter: PentagonoPainter(
                    color: marrom,
                  ),
                ),

                Text(
                  '$pontos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pontos de gestão',
                  style: TextStyle(
                    color: marrom,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: marrom.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    avaliacao,
                    style: const TextStyle(
                      color: marrom,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  isTv
                      ? 'Resultado baseado no uso, gasto de energia e tempo de funcionamento.'
                      : 'Resultado baseado no consumo, horas de uso e eficiência do aparelho.',
                  style: const TextStyle(
                    color: laranja,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD ENERGIA
  // ================================================================

  Widget _cardConsumo() {
    return _cardBase(
      height: 155,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bolt,
                color: marrom,
                size: 21,
              ),
              SizedBox(width: 5),
              Text(
                'Energia',
                style: TextStyle(
                  color: marrom,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            '${gastoEnergia.toStringAsFixed(1)} kWh',
            style: const TextStyle(
              color: laranja,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'consumo de energia',
            style: TextStyle(
              color: textoSecundario,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF63A33B),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 5),

              const Text(
                'Dentro do esperado',
                style: TextStyle(
                  color: marrom,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD USO
  // ================================================================

  Widget _cardHorasUso() {
    return _cardBase(
      height: 155,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.schedule,
                color: marrom,
                size: 21,
              ),

              SizedBox(width: 5),

              Text(
                'Uso',
                style: TextStyle(
                  color: marrom,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            '${horasUsadas} h',
            style: const TextStyle(
              color: laranja,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'tempo de utilização',
            style: TextStyle(
              color: textoSecundario,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Icon(
                isTv
                    ? Icons.trending_flat
                    : Icons.trending_up,
                color: marrom,
                size: 20,
              ),

              const SizedBox(width: 4),

              Text(
                isTv
                    ? 'Uso estável'
                    : 'Uso elevado',
                style: const TextStyle(
                  color: marrom,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD GRÁFICO
  // ================================================================

  Widget _cardGrafico() {
    return Container(
      width: double.infinity,
      height: 225,
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        11,
      ),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // TÍTULO E SELETOR
          // ==========================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Uso ao longo do tempo',
                  style: TextStyle(
                    color: marrom,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              PopupMenuButton<String>(
                initialValue: periodoSelecionado,
                color: amareloClaro,
                onSelected: (valor) {
                  setState(() {
                    periodoSelecionado = valor;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: '7 dias',
                      child: Text(
                        '7 dias',
                        style: TextStyle(
                          color: marrom,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    PopupMenuItem(
                      value: '4 semanas',
                      child: Text(
                        '4 semanas',
                        style: TextStyle(
                          color: marrom,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    PopupMenuItem(
                      value: '6 meses',
                      child: Text(
                        '6 meses',
                        style: TextStyle(
                          color: marrom,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ];
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: amareloClaro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        periodoSelecionado,
                        style: const TextStyle(
                          color: marrom,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(width: 4),

                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: marrom,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ==========================================================
          // DESCRIÇÃO
          // ==========================================================

          Text(
            periodoSelecionado == '7 dias'
                ? 'Veja como o aparelho foi utilizado durante a semana.'
                : periodoSelecionado == '4 semanas'
                    ? 'Compare o tempo de uso entre as últimas semanas.'
                    : 'Acompanhe a evolução do uso nos últimos meses.',
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          // ==========================================================
          // GRÁFICO
          // ==========================================================

          Expanded(
            child: CustomPaint(
              painter: GraficoLinhaDetalhadoPainter(
                valores: valoresGrafico,
              ),
              child: Container(),
            ),
          ),

          const SizedBox(height: 3),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: etiquetasGrafico
                .map(
                  (texto) => Text(
                    texto,
                    style: const TextStyle(
                      color: textoSecundario,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD TEMPERATURA / RECOMENDAÇÕES
  // ================================================================

  Widget _cardInfoEspecifica() {
    return _cardBase(
      height: 240,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            isTv
                ? 'Recomendações'
                : 'Temperatura',
            style: const TextStyle(
              color: marrom,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          if (isTv) ...[
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _itemRecomendacaoGrande(
                    Icons.brightness_6_outlined,
                    'Reduzir brilho',
                  ),

                  _itemRecomendacaoGrande(
                    Icons.power_settings_new,
                    'Desligar ao sair',
                  ),

                  _itemRecomendacaoGrande(
                    Icons.battery_alert_outlined,
                    'Evitar standby',
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              terceiraValor,
              style: const TextStyle(
                color: laranja,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 2),

            const Text(
              'temperatura atual',
              style: TextStyle(
                color: textoSecundario,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _itemRecomendacaoGrande(
                    Icons.check_circle_outline,
                    'Faixa recomendada',
                  ),

                  _itemRecomendacaoGrande(
                    Icons.air,
                    'Boa condição de uso',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================================================================
  // ITEM DE RECOMENDAÇÃO GRANDE
  // ================================================================

  Widget _itemRecomendacaoGrande(
    IconData icone,
    String texto,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: marrom.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icone,
            color: laranja,
            size: 21,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            texto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: laranja,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // CARD EFICIÊNCIA
  // ================================================================

  Widget _cardEficiencia() {
    final double eficiencia = isTv ? 0.82 : 0.72;

    return _cardBase(
      height: 240,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.speed,
                color: marrom,
                size: 21,
              ),

              SizedBox(width: 6),

              Text(
                'Eficiência',
                style: TextStyle(
                  color: marrom,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ==========================================================
          // BARRA DE EFICIÊNCIA
          // ==========================================================

          Stack(
            children: [
              Container(
                height: 21,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: amareloClaro,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),

              FractionallySizedBox(
                widthFactor: eficiencia,
                child: Container(
                  height: 21,
                  decoration: BoxDecoration(
                    color: marrom,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            '${(eficiencia * 100).round()}%',
            style: const TextStyle(
              color: laranja,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'aproveitamento',
            style: TextStyle(
              color: textoSecundario,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            isTv
                ? 'Bom aproveitamento do aparelho.'
                : 'Há espaço para reduzir o consumo.',
            style: const TextStyle(
              color: marrom,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD BASE
  // ================================================================

  Widget _cardBase({
    required double height,
    required Widget child,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ================================================================
// PENTÁGONO
// ================================================================

class PentagonoPainter extends CustomPainter {
  final Color color;

  PentagonoPainter({
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();

    path.moveTo(
      size.width * 0.50,
      size.height * 0.05,
    );

    path.lineTo(
      size.width * 0.95,
      size.height * 0.35,
    );

    path.lineTo(
      size.width * 0.78,
      size.height * 0.90,
    );

    path.lineTo(
      size.width * 0.22,
      size.height * 0.90,
    );

    path.lineTo(
      size.width * 0.05,
      size.height * 0.35,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ================================================================
// GRÁFICO DE LINHA
// ================================================================

class GraficoLinhaDetalhadoPainter extends CustomPainter {
  final List<double> valores;

  GraficoLinhaDetalhadoPainter({
    required this.valores,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint linhaPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint pontoPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final Paint gradePaint = Paint()
      ..color = const Color(0x339A4F00)
      ..strokeWidth = 1;

    // ==============================================================
    // GRADE
    // ==============================================================

    for (int i = 1; i <= 3; i++) {
      final double y = size.height * (i / 4);

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gradePaint,
      );
    }

    if (valores.isEmpty) {
      return;
    }

    // ==============================================================
    // PONTOS
    // ==============================================================

    final List<Offset> pontos = [];

    for (int i = 0; i < valores.length; i++) {
      final double percentual =
          valores.length == 1
              ? 0.5
              : i / (valores.length - 1);

      final double x =
          size.width * percentual;

      final double y =
          size.height * valores[i];

      pontos.add(
        Offset(x, y),
      );
    }

    // ==============================================================
    // LINHA
    // ==============================================================

    final Path path = Path();

    path.moveTo(
      pontos.first.dx,
      pontos.first.dy,
    );

    for (int i = 1; i < pontos.length; i++) {
      path.lineTo(
        pontos[i].dx,
        pontos[i].dy,
      );
    }

    canvas.drawPath(
      path,
      linhaPaint,
    );

    // ==============================================================
    // MARCADORES
    // ==============================================================

    for (final ponto in pontos) {
      canvas.drawCircle(
        ponto,
        4,
        pontoPaint,
      );

      canvas.drawCircle(
        ponto,
        8,
        Paint()
          ..color =
              AppColors.primary.withOpacity(0.10)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant GraficoLinhaDetalhadoPainter oldDelegate,
  ) {
    return false;
  }
}