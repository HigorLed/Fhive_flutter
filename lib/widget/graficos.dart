import 'package:flutter/material.dart';
import 'package:tcc_mobile/widget/barra_navegacao.dart';

enum TipoAparelho {
  tv,
  arCondicionado,
}

class TelaGraficos extends StatefulWidget {
  const TelaGraficos({super.key});

  @override
  State<TelaGraficos> createState() => _TelaGraficosState();
}

class _TelaGraficosState extends State<TelaGraficos> {
  static const Color marrom = Color(0xFF9A4F00);
  static const Color fundoCard = Color(0xFFFFFABE);
  static const Color fundoCardExterno = Color(0xFFFFE675);

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
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    28,
                    20,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // CABEÇALHO
                      // ==================================================

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Minha casa',
                              style: TextStyle(
                                color: marrom,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Arvo',
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Adicionar gráfico'),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(),
                            icon: const Icon(
                              Icons.add,
                              color: marrom,
                              size: 36,
                            ),
                          ),

                          const SizedBox(width: 20),

                          IconButton(
                            onPressed: _abrirMenu,
                            padding: EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(),
                            icon: const Icon(
                              Icons.more_vert,
                              color: marrom,
                              size: 30,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

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
                                locaisAbertos =
                                    !locaisAbertos;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Locais',
                                  style: TextStyle(
                                    color: marrom,
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  locaisAbertos
                                      ? Icons
                                          .keyboard_arrow_up
                                      : Icons
                                          .keyboard_arrow_down,
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
                            borderRadius:
                                BorderRadius.circular(20),
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
                                          tipo: TipoAparelho
                                              .arCondicionado,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _cardAparelho(
                                    nome:
                                        'Ar condicionado',
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
                                  fontWeight:
                                      FontWeight.w800,
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
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons
                                      .keyboard_arrow_down,
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
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
                              color:
                                  const Color(0xFFFFF4B2),
                              borderRadius:
                                  BorderRadius.circular(21),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.devices_other,
                                  color: marrom,
                                  size: 34,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Outro aparelho',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    color: marrom,
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                const Text(
                                  'Indisponível',
                                  style: TextStyle(
                                    color: marrom,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w700,
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
        mainAxisAlignment:
            MainAxisAlignment.center,
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

  void _abrirMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.fromLTRB(20, 20, 20, 30),
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

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                          Text('Gráficos atualizados!'),
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
                            fontWeight:
                                FontWeight.bold,
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

class TelaGraficosDetalhes extends StatelessWidget {
  final TipoAparelho tipo;

  const TelaGraficosDetalhes({
    super.key,
    required this.tipo,
  });

  static const Color marrom = Color(0xFF9A4F00);
  static const Color vermelho = Color(0xFFE10D00);
  static const Color amareloCard = Color(0xFFFFE48A);

  bool get isTv => tipo == TipoAparelho.tv;

  String get nomeAparelho {
    return isTv
        ? 'TV - Cristal'
        : 'Ar condicionado';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE832),
              Color(0xFFFFCD1B),
              Color(0xFFF4A91A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    28,
                    20,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            iconeAparelho,
                            color: marrom,
                            size: 30,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              nomeAparelho,
                              style: const TextStyle(
                                color: marrom,
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.w800,
                                fontFamily: 'Arvo',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      const Text(
                        'Gráfico',
                        style: TextStyle(
                          color: marrom,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Arvo',
                        ),
                      ),

                      const SizedBox(height: 18),

                      _cardResumo(),

                      const SizedBox(height: 18),

                      const Text(
                        'graphics',
                        style: TextStyle(
                          color: marrom,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Arvo',
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: _cardGastoEnergia(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _cardHoras(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _cardInformacaoEspecifica(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _cardSla(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _cardRecomendacoes(),
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

  Widget _cardResumo() {
    return Container(
      width: double.infinity,
      height: 143,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE27A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 95,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(100, 90),
                  painter: PentagonoPainter(
                    color: marrom,
                  ),
                ),
                Text(
                  '$pontos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pontos de\ngestão',
                  style: TextStyle(
                    color: marrom,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    height: 1.0,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  isTv
                      ? 'baseado em seus gráficos de gasto de energia e horas de uso'
                      : 'baseado no consumo, horas de uso e eficiência do aparelho',
                  style: const TextStyle(
                    color: Color(0xFFE96D22),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardGastoEnergia() {
    return _cardBase(
      height: 138,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Gasto de energia',
            style: TextStyle(
              color: marrom,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Expanded(
            child: Center(
              child: SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 82,
                      height: 82,
                      child:
                          CircularProgressIndicator(
                        value: isTv ? 0.72 : 0.63,
                        strokeWidth: 13,
                        backgroundColor: marrom,
                        valueColor:
                            const AlwaysStoppedAnimation(
                          vermelho,
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration:
                          const BoxDecoration(
                        color: amareloCard,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Text(
            '${gastoEnergia.toStringAsFixed(1)}kWh',
            style: const TextStyle(
              color: Color(0xFFF3A51C),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            'último update',
            style: TextStyle(
              color: Color(0xFFB8A96C),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHoras() {
    return _cardBase(
      height: 138,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Horas usadas',
            style: TextStyle(
              color: marrom,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: CustomPaint(
              painter: GraficoLinhaPainter(),
              child: Container(),
            ),
          ),

          Text(
            '${horasUsadas}h',
            style: const TextStyle(
              color: Color(0xFFF3A51C),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            'último update',
            style: TextStyle(
              color: Color(0xFFB8A96C),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardInformacaoEspecifica() {
    return _cardBase(
      height: 138,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            isTv ? 'Recomendações' : 'Temperatura',
            style: const TextStyle(
              color: marrom,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (isTv) ...[
            const Text(
              '• reduzir brilho',
              style: TextStyle(
                color: Color(0xFFE56C1F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              '• desligar ao sair',
              style: TextStyle(
                color: Color(0xFFE56C1F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              '• evitar standby',
              style: TextStyle(
                color: Color(0xFFE56C1F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Text(
              terceiraValor,
              style: const TextStyle(
                color: Color(0xFFE56C1F),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'temperatura atual',
              style: TextStyle(
                color: Color(0xFFB8A96C),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• manter portas fechadas',
              style: TextStyle(
                color: Color(0xFFE56C1F),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              '• limpar filtros',
              style: TextStyle(
                color: Color(0xFFE56C1F),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardSla() {
    return _cardBase(
      height: 138,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'SLA',
            style: TextStyle(
              color: marrom,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAB1),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),

              FractionallySizedBox(
                widthFactor: isTv ? 0.82 : 0.72,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: marrom,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Text(
            isTv ? '132' : '145',
            style: const TextStyle(
              color: Color(0xFFF3A51C),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            'último update',
            style: TextStyle(
              color: Color(0xFFB8A96C),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRecomendacoes() {
    return _cardBase(
      height: 105,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Recomendações',
            style: TextStyle(
              color: marrom,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          if (isTv) ...[
            _linhaRecomendacao('reduzir brilho'),
            _linhaRecomendacao(
              'desligar quando não estiver usando',
            ),
            _linhaRecomendacao(
              'evitar deixar em standby',
            ),
          ] else ...[
            _linhaRecomendacao(
              'usar temperatura entre 23°C e 24°C',
            ),
            _linhaRecomendacao(
              'manter filtros limpos',
            ),
            _linhaRecomendacao(
              'evitar ligar e desligar repetidamente',
            ),
          ],
        ],
      ),
    );
  }

  Widget _linhaRecomendacao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 3,
      ),
      child: Text(
        '• $texto',
        style: const TextStyle(
          color: Color(0xFFE56C1F),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _cardBase({
    required double height,
    required Widget child,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(0, 3),
            blurRadius: 3,
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

    final path = Path();

    path.moveTo(
      size.width * 0.5,
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

    canvas.drawPath(path, paint);
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

class GraficoLinhaPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF9A4F00)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.65,
    );

    path.lineTo(
      size.width * 0.15,
      size.height * 0.52,
    );

    path.lineTo(
      size.width * 0.28,
      size.height * 0.62,
    );

    path.lineTo(
      size.width * 0.42,
      size.height * 0.45,
    );

    path.lineTo(
      size.width * 0.56,
      size.height * 0.65,
    );

    path.lineTo(
      size.width * 0.70,
      size.height * 0.44,
    );

    path.lineTo(
      size.width * 0.82,
      size.height * 0.52,
    );

    path.lineTo(
      size.width,
      size.height * 0.22,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}