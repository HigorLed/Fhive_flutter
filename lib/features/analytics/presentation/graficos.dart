import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/features/analytics/presentation/indicador_grafico_detalhe.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';

enum TipoAparelho { tv, arCondicionado }

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
  String localSelecionado = 'Sala de Estar';

  @override
  Widget build(BuildContext context) {
    return NavegacaoPorDeslize(
      itemSelecionado: 2,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.main),
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
                                mostrarCriarAparelho(context);
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

                        const SizedBox(height: AppSpacing.section),

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
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _selecionarLocal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    localSelecionado,
                                    style: const TextStyle(
                                      color: marrom,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: marrom,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _cartoesGraficosDisponiveis(context),
                          const SizedBox(height: 32),
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
                              GestureDetector(
                                onTap: _selecionarLocal,
                                child: Row(
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _cartoesGraficosIndisponiveis(context),
                        ],
                      ],
                    ),
                  ),
                ),

                const BarraNavegacao(itemSelecionado: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _temGraficoDisponivel(AparelhoItem aparelho) {
    final tipo = aparelho.tipo.trim().toLowerCase();
    return tipo == 'tv' || tipo == 'ar condicionado';
  }

  Widget _cartoesGraficosDisponiveis(BuildContext context) {
    return ValueListenableBuilder<List<AparelhoItem>>(
      valueListenable: AparelhosStore.aparelhos,
      builder: (context, aparelhos, _) {
        final disponiveis = aparelhos
            .where(
              (aparelho) =>
                  aparelho.local.toLowerCase() ==
                      localSelecionado.toLowerCase() &&
                  _temGraficoDisponivel(aparelho),
            )
            .toList();

        if (disponiveis.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: fundoCardExterno,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Nenhum aparelho com gráficos disponíveis neste local.',
              textAlign: TextAlign.center,
              style: TextStyle(color: marrom, fontWeight: FontWeight.w700),
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: fundoCardExterno,
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largura = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: disponiveis.map((aparelho) {
                  return SizedBox(
                    width: largura,
                    child: GestureDetector(
                      onTap: () => _abrirGraficosDoAparelho(aparelho),
                      child: _cardAparelho(
                        nome: aparelho.nome,
                        subtitulo: 'Disponível',
                        icone: aparelho.icone,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _cartoesGraficosIndisponiveis(BuildContext context) {
    return ValueListenableBuilder<List<AparelhoItem>>(
      valueListenable: AparelhosStore.aparelhos,
      builder: (context, aparelhos, _) {
        final indisponiveis = aparelhos
            .where(
              (aparelho) =>
                  aparelho.local.toLowerCase() ==
                      localSelecionado.toLowerCase() &&
                  !_temGraficoDisponivel(aparelho),
            )
            .toList();

        if (indisponiveis.isEmpty) {
          return GestureDetector(
            onTap: () => _mensagemGraficoIndisponivel(
              'Ainda não há outros aparelhos compatíveis com gráficos neste local.',
            ),
            child: Container(
              width: 166,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4B2).withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.devices_other, color: marrom, size: 34),
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
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: indisponiveis.map((aparelho) {
            return SizedBox(
              width: (MediaQuery.sizeOf(context).width - 64) / 2,
              child: GestureDetector(
                onTap: () => _mensagemGraficoIndisponivel(
                  'Os gráficos de "${aparelho.nome}" serão liberados quando houver telemetria e suporte para esse tipo de aparelho.',
                ),
                child: _cardAparelho(
                  nome: aparelho.nome,
                  subtitulo: 'Aguardando dados',
                  icone: aparelho.icone,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _mensagemGraficoIndisponivel(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _abrirGraficosDoAparelho(AparelhoItem aparelho) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaGraficosDetalhes(
          tipo: aparelho.tipo.trim().toLowerCase() == 'tv'
              ? TipoAparelho.tv
              : TipoAparelho.arCondicionado,
          nomePersonalizado: aparelho.nome,
        ),
      ),
    );
  }

  void _selecionarLocal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF4B2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecionar local',
                style: TextStyle(
                  color: marrom,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              for (final local in AparelhosStore.locaisDisponiveis)
                ListTile(
                  dense: true,
                  title: Text(local, style: const TextStyle(color: marrom)),
                  trailing: local == localSelecionado
                      ? const Icon(Icons.check, color: marrom)
                      : null,
                  onTap: () {
                    setState(() => localSelecionado = local);
                    Navigator.pop(sheetContext);
                  },
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
          Icon(icone, color: marrom, size: 36),

          const SizedBox(height: 8),

          Text(
            nome,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4B2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.refresh, color: marrom),
                  title: const Text(
                    'Atualizar gráficos',
                    style: TextStyle(
                      color: marrom,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Os gráficos usam dados demonstrativos. A atualização em tempo real depende da integração IoT.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: marrom),
                  title: const Text(
                    'Informações',
                    style: TextStyle(
                      color: marrom,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showDialog(
                      context: this.context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text(
                            'Gráficos',
                            style: TextStyle(
                              color: marrom,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const Text(
                            'Nesta tela você poderá acompanhar os dados dos aparelhos conectados.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: const Text(
                                'Fechar',
                                style: TextStyle(color: marrom),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================================================================
// DETALHES DOS GRÁFICOS DE UM APARELHO
// ================================================================

class TelaGraficosDetalhes extends StatefulWidget {
  final TipoAparelho tipo;
  final String? nomePersonalizado;

  const TelaGraficosDetalhes({
    super.key,
    required this.tipo,
    this.nomePersonalizado,
  });

  @override
  State<TelaGraficosDetalhes> createState() => _TelaGraficosDetalhesState();
}

class _TelaGraficosDetalhesState extends State<TelaGraficosDetalhes> {
  static const Color marrom = AppColors.primary;
  static const Color laranja = Color(0xFFC46B00);
  static const Color textoSecundario = Color(0xFF81500F);
  static const Color amareloClaro = Color(0xFFFFF1A3);
  static const Color amareloCard = Color(0xFFFFE48A);

  String periodoSelecionado = '7 dias';

  bool get isTv => widget.tipo == TipoAparelho.tv;

  String get nomeAparelho =>
      widget.nomePersonalizado ?? (isTv ? 'TV - Cristal' : 'Ar condicionado');

  IconData get iconeAparelho => isTv ? Icons.tv_outlined : Icons.air;

  int get pontos => isTv ? 76 : 82;

  String get avaliacao => isTv ? 'Muito bom' : 'Excelente';

  double get gastoEnergia => isTv ? 12.5 : 28.4;

  int get horasUsadas => isTv ? 12 : 18;

  String get terceiraValor => isTv ? '72%' : '23°C';

  List<double> get valoresGrafico {
    if (periodoSelecionado == '4 semanas') {
      return isTv
          ? <double>[0.38, 0.52, 0.44, 0.61, 0.55, 0.72, 0.66]
          : <double>[0.48, 0.61, 0.58, 0.76, 0.69, 0.82, 0.73];
    }

    if (periodoSelecionado == '6 meses') {
      return isTv
          ? <double>[0.44, 0.50, 0.47, 0.59, 0.53, 0.68]
          : <double>[0.55, 0.63, 0.60, 0.74, 0.71, 0.82];
    }

    return isTv
        ? <double>[0.32, 0.46, 0.58, 0.42, 0.70, 0.61, 0.76]
        : <double>[0.50, 0.64, 0.58, 0.78, 0.69, 0.84, 0.73];
  }

  List<String> get etiquetasGrafico {
    if (periodoSelecionado == '6 meses') {
      return <String>['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
    }

    if (periodoSelecionado == '4 semanas') {
      return <String>['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'];
    }

    return <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
                                color: amareloClaro.withValues(alpha: 0.80),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          fontWeight: FontWeight.w800,
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
                              color: Colors.white.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            _abrirIndicador(TipoIndicadorGrafico.pontuacao),
                        child: _cardResumo(),
                      ),

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
                          Expanded(child: _cardConsumo()),

                          const SizedBox(width: 10),

                          Expanded(child: _cardHorasUso()),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ==================================================
                      // GRÁFICO
                      // ==================================================
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            _abrirIndicador(TipoIndicadorGrafico.historico),
                        child: _cardGrafico(),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // INFORMAÇÕES EXTRAS
                      // ==================================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _cardInfoEspecifica()),

                          const SizedBox(width: 10),

                          Expanded(child: _cardEficiencia()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const BarraNavegacao(itemSelecionado: 2),
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
                  size: const Size(100, 95),
                  painter: PentagonoPainter(color: marrom),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: marrom.withValues(alpha: 0.12),
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
      onTap: () => _abrirIndicador(TipoIndicadorGrafico.energia),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: marrom, size: 21),
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
      onTap: () => _abrirIndicador(TipoIndicadorGrafico.horas),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: marrom, size: 21),

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
            '$horasUsadas h',
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
                isTv ? Icons.trending_flat : Icons.trending_up,
                color: marrom,
                size: 20,
              ),

              const SizedBox(width: 4),

              Text(
                isTv ? 'Uso estável' : 'Uso elevado',
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 11),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              painter: GraficoLinhaDetalhadoPainter(valores: valoresGrafico),
              child: Container(),
            ),
          ),

          const SizedBox(height: 3),

          Row(
            children: etiquetasGrafico
                .map(
                  (texto) => Expanded(
                    child: Text(
                      texto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textoSecundario,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
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
      onTap: () => _abrirIndicador(TipoIndicadorGrafico.recomendacoes),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTv ? 'Recomendações' : 'Temperatura',
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _itemRecomendacaoGrande(
                    Icons.check_circle_outline,
                    'Faixa recomendada',
                  ),

                  _itemRecomendacaoGrande(Icons.air, 'Boa condição de uso'),
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

  Widget _itemRecomendacaoGrande(IconData icone, String texto) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: marrom.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: laranja, size: 21),
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
      onTap: () => _abrirIndicador(TipoIndicadorGrafico.eficiencia),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed, color: marrom, size: 21),

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
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              FractionallySizedBox(
                widthFactor: eficiencia,
                child: Container(
                  height: 21,
                  decoration: BoxDecoration(
                    color: marrom,
                    borderRadius: BorderRadius.circular(20),
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
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
        ),
      ),
    );
  }

  void _abrirIndicador(TipoIndicadorGrafico indicador) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaIndicadorGraficoDetalhe(
          isTv: isTv,
          nomeAparelho: nomeAparelho,
          indicador: indicador,
        ),
      ),
    );
  }
}

// ================================================================
// PENTÁGONO
// ================================================================

class PentagonoPainter extends CustomPainter {
  final Color color;

  PentagonoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();

    path.moveTo(size.width * 0.50, size.height * 0.05);

    path.lineTo(size.width * 0.95, size.height * 0.35);

    path.lineTo(size.width * 0.78, size.height * 0.90);

    path.lineTo(size.width * 0.22, size.height * 0.90);

    path.lineTo(size.width * 0.05, size.height * 0.35);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PentagonoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// ================================================================
// GRÁFICO DE LINHA
// ================================================================

class GraficoLinhaDetalhadoPainter extends CustomPainter {
  final List<double> valores;

  GraficoLinhaDetalhadoPainter({required this.valores});

  @override
  void paint(Canvas canvas, Size size) {
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

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gradePaint);
    }

    if (valores.isEmpty) {
      return;
    }

    // ==============================================================
    // PONTOS
    // ==============================================================

    final List<Offset> pontos = [];

    // Margem para os marcadores (raio 8) não serem cortados nas bordas.
    const double margemVertical = 10;

    final double alturaUtil = size.height - (margemVertical * 2);
    final double larguraSlot = size.width / valores.length;

    for (int i = 0; i < valores.length; i++) {
      // Cada ponto fica no centro do seu "slot", o mesmo espaço usado
      // pelos rótulos do eixo X (Expanded) - assim os dois alinham.
      final double x = larguraSlot * (i + 0.5);

      // No canvas o Y cresce para BAIXO, então é preciso inverter:
      // valor maior = ponto mais alto no gráfico.
      final double valor = valores[i].clamp(0.0, 1.0).toDouble();
      final double y = margemVertical + (alturaUtil * (1 - valor));

      pontos.add(Offset(x, y));
    }

    // ==============================================================
    // LINHA
    // ==============================================================

    final Path path = Path();

    path.moveTo(pontos.first.dx, pontos.first.dy);

    for (int i = 1; i < pontos.length; i++) {
      path.lineTo(pontos[i].dx, pontos[i].dy);
    }

    canvas.drawPath(path, linhaPaint);

    // ==============================================================
    // MARCADORES
    // ==============================================================

    for (final ponto in pontos) {
      canvas.drawCircle(ponto, 4, pontoPaint);

      canvas.drawCircle(
        ponto,
        8,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GraficoLinhaDetalhadoPainter oldDelegate) {
    // Os valores mudam quando o usuário troca o período (7 dias,
    // 4 semanas, 6 meses). Com `return false` o gráfico não era
    // redesenhado e ficava com os dados antigos.
    if (oldDelegate.valores.length != valores.length) {
      return true;
    }

    for (int i = 0; i < valores.length; i++) {
      if (oldDelegate.valores[i] != valores[i]) {
        return true;
      }
    }

    return false;
  }
}
