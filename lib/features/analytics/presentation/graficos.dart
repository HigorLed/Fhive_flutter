import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/analytics/presentation/indicador_grafico_detalhe.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/widgets/seletor_locais.dart';

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
  static const Color fundoCard = AppColors.white;

  /// Áreas recolhidas/expandidas. Chave: '<seção>|<área em minúsculas>'.
  final Map<String, bool> _areasAbertas = <String, bool>{};

  bool _mostrarLocais = false;
  String? _localFiltro;

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
                        const CabecalhoPagina(titulo: 'Minha casa'),
                        const SizedBox(height: AppSpacing.section),
                        _conteudoGraficos(context),
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

  Widget _conteudoGraficos(BuildContext context) {
    return ValueListenableBuilder<List<AparelhoItem>>(
      valueListenable: AparelhosStore.aparelhos,
      builder: (context, aparelhos, _) {
        final filtro = _localFiltro?.trim().toLowerCase();
        final doLocal = filtro == null
            ? aparelhos
            : aparelhos
                  .where((a) => a.local.trim().toLowerCase() == filtro)
                  .toList();
        final disponiveis = doLocal.where(_temGraficoDisponivel).toList();
        final indisponiveis = doLocal
            .where((aparelho) => !_temGraficoDisponivel(aparelho))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TituloSecao(
              titulo: 'Gráficos disponíveis',
              trailing: AlternadorLocais(
                aberto: _mostrarLocais,
                aoTocar: () => setState(() => _mostrarLocais = !_mostrarLocais),
              ),
            ),
            if (_mostrarLocais) ...[
              const SizedBox(height: AppSpacing.md),
              PainelLocais(
                locais: AparelhosStore.locaisComAparelhos,
                selecionado: _localFiltro,
                aoSelecionar: (local) => setState(() => _localFiltro = local),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (disponiveis.isEmpty)
              const Text(
                'Nenhum aparelho com gráficos disponíveis.',
                style: AppTextStyles.bodyBold,
              )
            else
              _gruposPorArea(
                context,
                secao: 'disponiveis',
                aparelhos: disponiveis,
                construirCard: (aparelho) => GestureDetector(
                  onTap: () => _abrirGraficosDoAparelho(aparelho),
                  child: _cardAparelho(
                    nome: aparelho.nome,
                    subtitulo: 'Disponível',
                    icone: aparelho.icone,
                    metrica: aparelho.tipo.trim().toLowerCase() == 'tv'
                        ? '12,5 kWh'
                        : '28,4 kWh',
                    mostrarMiniGrafico: true,
                  ),
                ),
              ),
            if (indisponiveis.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.section),
              const TituloSecao(titulo: 'Gráficos indisponíveis'),
              const SizedBox(height: AppSpacing.md),
              _gruposPorArea(
                context,
                secao: 'indisponiveis',
                aparelhos: indisponiveis,
                construirCard: (aparelho) => GestureDetector(
                  onTap: () => _mensagemGraficoIndisponivel(
                    'Os gráficos de "${aparelho.nome}" serão liberados quando houver telemetria e suporte para esse tipo de aparelho.',
                  ),
                  child: _cardAparelho(
                    nome: aparelho.nome,
                    subtitulo: 'Aguardando dados',
                    icone: aparelho.icone,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Agrupa os aparelhos por área, no mesmo formato da tela de aparelhos:
  /// título da área com a quantidade e uma seta para recolher/expandir.
  Widget _gruposPorArea(
    BuildContext context, {
    required String secao,
    required List<AparelhoItem> aparelhos,
    required Widget Function(AparelhoItem aparelho) construirCard,
  }) {
    // Mantém a ordem de AparelhosStore.locaisComAparelhos, mas só com as
    // áreas que têm aparelhos desta seção.
    final areas = AparelhosStore.locaisComAparelhos.where((area) {
      return aparelhos.any(
        (aparelho) =>
            aparelho.local.trim().toLowerCase() == area.trim().toLowerCase(),
      );
    }).toList();

    final larguraCard =
        (MediaQuery.sizeOf(context).width -
            2 * AppSpacing.pageHorizontal -
            AppSpacing.md) /
        2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < areas.length; i++) ...[
          Builder(
            builder: (context) {
              final area = areas[i];
              final chave = '$secao|${area.trim().toLowerCase()}';
              final aberta = _areasAbertas[chave] ?? true;
              final daArea = aparelhos
                  .where(
                    (aparelho) =>
                        aparelho.local.trim().toLowerCase() ==
                        area.trim().toLowerCase(),
                  )
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cabecalhoArea(
                    area,
                    daArea.length,
                    aberta,
                    () => setState(() => _areasAbertas[chave] = !aberta),
                  ),
                  if (aberta) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: daArea
                          .map(
                            (aparelho) => SizedBox(
                              width: larguraCard,
                              child: construirCard(aparelho),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              );
            },
          ),
          if (i < areas.length - 1) const SizedBox(height: AppSpacing.section),
        ],
      ],
    );
  }

  Widget _cabecalhoArea(
    String area,
    int quantidade,
    bool aberta,
    VoidCallback aoTocar,
  ) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(area, style: AppTextStyles.cardTitle)),
            Text(
              '$quantidade',
              style: TextStyle(
                color: marrom.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              aberta ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: marrom,
              size: 22,
            ),
          ],
        ),
      ),
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
          local: aparelho.local,
          status: aparelho.status,
          deviceBackendId: aparelho.backendId,
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
    String? metrica,
    bool mostrarMiniGrafico = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: mostrarMiniGrafico ? 142 : 110,
      decoration: BoxDecoration(
        color: fundoCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
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
            style: AppTextStyles.cardTitle,
          ),

          Text(
            subtitulo,
            style: AppTextStyles.caption,
          ),
          if (mostrarMiniGrafico && metrica != null) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniGrafico(),
                const SizedBox(width: 7),
                Text(
                  metrica,
                  style: const TextStyle(
                    color: marrom,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }


  Widget _miniGrafico() {
    const alturas = <double>[7, 12, 9, 16, 11, 19, 14];
    return SizedBox(
      width: 48,
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: alturas
            .map(
              (altura) => Container(
                width: 4,
                height: altura,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ================================================================
// DETALHES DOS GRÁFICOS DE UM APARELHO
// ================================================================

class TelaGraficosDetalhes extends StatefulWidget {
  final TipoAparelho tipo;
  final String? nomePersonalizado;
  final String local;
  final String status;
  final String? deviceBackendId;

  const TelaGraficosDetalhes({
    super.key,
    required this.tipo,
    this.nomePersonalizado,
    this.local = 'Sala de Estar',
    this.status = 'Online',
    this.deviceBackendId,
  });

  @override
  State<TelaGraficosDetalhes> createState() => _TelaGraficosDetalhesState();
}

class _TelaGraficosDetalhesState extends State<TelaGraficosDetalhes> {
  static const Color marrom = AppColors.primary;
  static const Color laranja = AppColors.warning;
  static const Color textoSecundario = AppColors.primaryDark;
  static const Color amareloClaro = AppColors.surface;
  static const Color amareloCard = AppColors.white;

  String periodoSelecionado = '7 dias';

  bool get isTv => widget.tipo == TipoAparelho.tv;

  bool get estaOnline => widget.status.trim().toLowerCase() == 'online';

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

  @override
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
                          const BotaoVoltar(),

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
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: AppFonts.title,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  '${widget.local} • Visão geral do aparelho',
                                  style: const TextStyle(
                                    color: textoSecundario,
                                    fontSize: 14,
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
                              horizontal: 9,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: estaOnline
                                        ? AppColors.success
                                        : AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  estaOnline ? 'Online' : 'Offline',
                                  style: AppTextStyles.caption,
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
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          fontFamily: AppFonts.title,
                        ),
                      ),

                      const SizedBox(height: 10),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 380) {
                            return Column(
                              children: [
                                _cardConsumo(),
                                const SizedBox(height: 12),
                                _cardHorasUso(),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: _cardConsumo()),
                              const SizedBox(width: 10),
                              Expanded(child: _cardHorasUso()),
                            ],
                          );
                        },
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
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 410) {
                            return Column(
                              children: [
                                _cardInfoEspecifica(),
                                const SizedBox(height: 12),
                                _cardEficiencia(),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _cardInfoEspecifica()),
                              const SizedBox(width: 10),
                              Expanded(child: _cardEficiencia()),
                            ],
                          );
                        },
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
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
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
                    color: AppColors.white,
                    fontSize: 32,
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
                    fontSize: 19,
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
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Text(
                    avaliacao,
                    style: AppTextStyles.caption,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  isTv
                      ? 'Resultado baseado no uso, gasto de energia e tempo de funcionamento.'
                      : 'Resultado baseado no consumo, horas de uso e eficiência do aparelho.',
                  style: const TextStyle(
                    color: laranja,
                    fontSize: 12,
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
                style: AppTextStyles.cardTitle,
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
              fontSize: 12,
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
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 5),

              const Text(
                'Dentro do esperado',
                style: AppTextStyles.caption,
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
                style: AppTextStyles.cardTitle,
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
              fontSize: 12,
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
                style: AppTextStyles.caption,
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
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
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
                  style: AppTextStyles.cardTitle,
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
                  borderRadius: BorderRadius.circular(AppRadius.button),
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
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Row(
                    children: [
                      Text(
                        periodoSelecionado,
                        style: AppTextStyles.caption,
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
                        fontSize: 10,
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
              fontSize: 19,
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
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 2),

            const Text(
              'temperatura atual',
              style: TextStyle(
                color: textoSecundario,
                fontSize: 12,
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
              fontSize: 14,
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
                style: AppTextStyles.cardTitle,
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
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),

              FractionallySizedBox(
                widthFactor: eficiencia,
                child: Container(
                  height: 21,
                  decoration: BoxDecoration(
                    color: marrom,
                    borderRadius: BorderRadius.circular(AppRadius.card),
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
              fontSize: 12,
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
              fontSize: 12,
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
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: amareloCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
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
          local: widget.local,
          indicador: indicador,
          deviceBackendId: widget.deviceBackendId,
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