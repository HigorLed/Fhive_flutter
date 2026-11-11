import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/estrutura_grafico.dart';
import 'package:tcc_mobile/features/devices/data/dispositivos_api.dart';

enum TipoIndicadorGrafico {
  energia,
  horas,
  pontuacao,
  historico,
  recomendacoes,
  eficiencia,
}

/// Tela secundária de um indicador. Consumo pode vir da telemetria da API;
/// os demais valores continuam demonstrativos enquanto o hardware não os enviar.
class TelaIndicadorGraficoDetalhe extends StatefulWidget {
  final bool isTv;
  final String nomeAparelho;
  final String local;
  final TipoIndicadorGrafico indicador;
  final String? deviceBackendId;

  const TelaIndicadorGraficoDetalhe({
    super.key,
    required this.isTv,
    required this.nomeAparelho,
    this.local = 'Sala de Estar',
    required this.indicador,
    this.deviceBackendId,
  });

  @override
  State<TelaIndicadorGraficoDetalhe> createState() =>
      _TelaIndicadorGraficoDetalheState();
}

class _TelaIndicadorGraficoDetalheState
    extends State<TelaIndicadorGraficoDetalhe> {
  static const Color marrom = AppColors.primary;
  static const Color fundoCartao = AppColors.white;
  static const Color amarelo = AppColors.accent;
  static const Color amareloSuave = AppColors.white;
  static const Color laranja = AppColors.warning;
  static const Color textoSuave = AppColors.primaryDark;

  String periodoEnergia = 'Mensal';
  String periodoHistorico = 'Semanal';
  List<Map<String, dynamic>> _telemetrias = <Map<String, dynamic>>[];

  Map<String, dynamic>? get _ultimaTelemetria =>
      _telemetrias.isEmpty ? null : _telemetrias.first;

  double get energia {
    final consumoWh = _ultimaTelemetria?['consumoAcumulado'];
    if (consumoWh is num) return consumoWh.toDouble() / 1000;
    return widget.isTv ? 12.5 : 28.4;
  }

  double get limiteDiario => widget.isTv ? 15.0 : 35.0;
  int get horas => widget.isTv ? 12 : 18;
  int get horasManha => widget.isTv ? 5 : 7;
  int get horasTarde => widget.isTv ? 3 : 5;
  int get horasNoite => widget.isTv ? 4 : 6;
  int get totalHoras => horasManha + horasTarde + horasNoite;
  int get pontuacao => widget.isTv ? 76 : 82;
  int get eficiencia => widget.isTv ? 82 : 72;
  String get temperatura => widget.isTv ? '72%' : '23°C';

  String get nomeIndicador {
    switch (widget.indicador) {
      case TipoIndicadorGrafico.energia:
        return 'Gasto de energia';
      case TipoIndicadorGrafico.horas:
        return 'Horas usadas';
      case TipoIndicadorGrafico.pontuacao:
        return 'Pontos de gestão';
      case TipoIndicadorGrafico.historico:
        return 'Histórico de uso';
      case TipoIndicadorGrafico.recomendacoes:
        return widget.isTv ? 'Recomendações' : 'Temperatura';
      case TipoIndicadorGrafico.eficiencia:
        return 'Eficiência energética';
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarTelemetria();
  }

  /// Busca a telemetria em segundo plano. Se falhar, a tela segue com os
  /// valores demonstrativos, sem mostrar aviso.
  Future<void> _carregarTelemetria() async {
    final id = widget.deviceBackendId;
    if (id == null || id.isEmpty) return;
    try {
      final dados = await DispositivosApi.telemetrias(id);
      if (!mounted) return;
      setState(() => _telemetrias = dados);
    } catch (_) {
      // Mantém os valores demonstrativos.
    }
  }

  @override
  Widget build(BuildContext context) {
    final ehHoras = widget.indicador == TipoIndicadorGrafico.horas;
    return EstruturaTelaGrafico(
      titulo: '${widget.nomeAparelho} | $_rotuloPilula',
      tituloFolha: ehHoras ? null : _tituloPagina(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_conteudoIndicador()],
      ),
    );
  }

  String get _rotuloPilula => widget.indicador == TipoIndicadorGrafico.energia
      ? 'Energia gasta'
      : nomeIndicador;

  String _tituloPagina() {
    switch (widget.indicador) {
      case TipoIndicadorGrafico.energia:
        return 'Gasto Diário';
      case TipoIndicadorGrafico.horas:
        return 'Distribuição do uso';
      case TipoIndicadorGrafico.pontuacao:
        return 'Sua pontuação';
      case TipoIndicadorGrafico.historico:
        return 'Uso ao longo do tempo';
      case TipoIndicadorGrafico.recomendacoes:
        return widget.isTv ? 'Dicas para economizar' : 'Condição atual';
      case TipoIndicadorGrafico.eficiencia:
        return 'Índice de eficiência';
    }
  }

  Widget _conteudoIndicador() {
    switch (widget.indicador) {
      case TipoIndicadorGrafico.energia:
        return _paginaEnergia();
      case TipoIndicadorGrafico.horas:
        return _paginaHoras();
      case TipoIndicadorGrafico.pontuacao:
        return _paginaPontuacao();
      case TipoIndicadorGrafico.historico:
        return _paginaHistorico();
      case TipoIndicadorGrafico.recomendacoes:
        return _paginaRecomendacoes();
      case TipoIndicadorGrafico.eficiencia:
        return _paginaEficiencia();
    }
  }

  // Página de energia, seguindo o Figma: medidor em anel, selos, limite e gráfico.
  Widget _paginaEnergia() {
    final fracao = (energia / limiteDiario).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(flex: 5, child: Center(child: _medidor(fracao))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _seloInformacao(
                    emblema: r'R$',
                    texto: 'Energia\nEconomizada',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _seloInformacao(
                    icone: Icons.bolt_rounded,
                    texto: 'Limite de\nenergia',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          'Limite de energia',
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${_numero(energia)} kWh usados',
          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Stack(
            children: [
              Container(height: 18, color: AppColors.track),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fracao,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: _rosaEnergia,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 kWh', style: AppTextStyles.chartLabel),
            Text(
              '${_numero(limiteDiario)} kWh',
              style: AppTextStyles.chartLabel,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legenda(_rosaEnergia, 'Energia usada'),
            const SizedBox(width: AppSpacing.lg),
            _legenda(AppColors.track, 'Limite de energia'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _graficoEnergia(),
        const SizedBox(height: AppSpacing.md),
        _cartaoDica(
          icone: Icons.lightbulb_outline_rounded,
          titulo: 'Dica para economizar',
          texto: widget.isTv
              ? 'Desligue a TV completamente quando não estiver usando para reduzir o consumo em espera.'
              : 'Ajustar a temperatura em 1°C pode ajudar a reduzir o gasto do ar-condicionado.',
        ),
      ],
    );
  }

  static const Color _rosaEnergia = Color(0xFFFF9C9D);

  Widget _medidor(double fracao) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 150),
            painter: MedidorAnelPainter(progresso: fracao),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: laranja, size: 34),
              Text(
                '${_numero(energia)} kWh',
                style: AppTextStyles.cardTitle.copyWith(
                  color: laranja,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seloInformacao({
    IconData? icone,
    String? emblema,
    required String texto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          if (emblema != null)
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: amarelo,
                borderRadius: BorderRadius.circular(AppRadius.chip / 2),
              ),
              child: Text(
                emblema,
                style: AppTextStyles.chartLabel.copyWith(
                  color: marrom,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else
            Icon(icone, color: laranja, size: 24),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: AppTextStyles.chartLabel.copyWith(
                color: marrom,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _graficoEnergia() {
    final valores = periodoEnergia == 'Semanal'
        ? <double>[0.25, 0.42, 0.40, 0.64, 0.72, 0.53, 0.38]
        : periodoEnergia == 'Mensal'
        ? <double>[0.36, 0.55, 0.45, 0.71, 0.62, 0.79, 0.56]
        : <double>[0.52, 0.38, 0.66, 0.48, 0.77, 0.61, 0.84];
    final etiquetas = periodoEnergia == 'Semanal'
        ? <String>['S', 'T', 'Q', 'Q', 'S', 'S', 'D']
        : periodoEnergia == 'Mensal'
        ? <String>['1', '5', '10', '15', '20', '25', '30']
        : <String>['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul'];
    return _cartaoGraficoLinha(
      periodo: periodoEnergia,
      aoMudar: (opcao) => setState(() => periodoEnergia = opcao),
      valores: valores,
      etiquetas: etiquetas,
    );
  }

  /// Cartão marrom escuro com abas Semanal/Mensal/Geral e gráfico de linha,
  /// usado na energia e no histórico de uso.
  Widget _cartaoGraficoLinha({
    required String periodo,
    required ValueChanged<String> aoMudar,
    required List<double> valores,
    required List<String> etiquetas,
    double altura = 190,
  }) {
    const opcoes = ['Semanal', 'Mensal', 'Geral'];
    return Container(
      height: altura,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final opcao in opcoes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    onTap: () => aoMudar(opcao),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: periodo == opcao
                            ? AppColors.primaryCard
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        opcao,
                        style: AppTextStyles.caption.copyWith(
                          color: periodo == opcao
                              ? AppColors.white
                              : AppColors.surfaceWarm,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: CustomPaint(
              painter: LinhaHistoricoPainter(
                valores: valores,
                corLinha: AppColors.surfaceWarm,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final etiqueta in etiquetas)
                Expanded(
                  child: Text(
                    etiqueta,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.chartLabel.copyWith(
                      color: AppColors.surfaceWarm,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PÁGINA DE HORAS (redesign igual ao Figma)
  // ================================================================

  Widget _paginaHoras() {
    final maxHoras = math
        .max(horasManha, math.max(horasTarde, horasNoite))
        .toDouble();
    return _molduraOrnamental(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _barraPeriodo(
            titulo: 'Manhã',
            horasPeriodo: horasManha,
            total: maxHoras,
            corFundo: const Color(0xFFFFF59D),
            corPreenchimento: const Color(0xFFFFEE00),
            periodo: PeriodoDiaGrafico.manha,
          ),
          const SizedBox(height: AppSpacing.lg),
          _barraPeriodo(
            titulo: 'Tarde',
            horasPeriodo: horasTarde,
            total: maxHoras,
            corFundo: const Color(0xFFFFCC80),
            corPreenchimento: const Color(0xFFFF8F1F),
            periodo: PeriodoDiaGrafico.tarde,
          ),
          const SizedBox(height: AppSpacing.lg),
          _barraPeriodo(
            titulo: 'Noite',
            horasPeriodo: horasNoite,
            total: maxHoras,
            corFundo: const Color(0xFFC5A8FF),
            corPreenchimento: const Color(0xFF7B2FF7),
            periodo: PeriodoDiaGrafico.noite,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Total de Horas: ${totalHoras}h',
              style: AppTextStyles.cardTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: marrom,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.isTv
                          ? 'Mais 2 horas do que ontem'
                          : 'Uso elevado em relação a ontem',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
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

  /// Moldura dupla marrom ao redor do conteúdo, como no Figma.
  Widget _molduraOrnamental({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: marrom, width: 1.6),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          border: Border.all(color: marrom.withValues(alpha: 0.7), width: 1),
        ),
        child: child,
      ),
    );
  }

  Widget _barraPeriodo({
    required String titulo,
    required int horasPeriodo,
    required double total,
    required Color corFundo,
    required Color corPreenchimento,
    required PeriodoDiaGrafico periodo,
  }) {
    final fracao = (horasPeriodo / total).clamp(0.25, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: AppTextStyles.cardTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            const ladoBalao = 34.0;
            final larguraPreenchida = constraints.maxWidth * fracao;
            final esquerdaBalao = (larguraPreenchida - ladoBalao - 3)
                .clamp(0.0, constraints.maxWidth - ladoBalao)
                .toDouble();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    height: 30,
                    color: corFundo,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fracao,
                      child: Container(
                        decoration: BoxDecoration(
                          color: corPreenchimento,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: CustomPaint(
                          painter: DecoracaoPeriodoPainter(periodo: periodo),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 46,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: esquerdaBalao,
                        top: 5,
                        child: _balaoHoras('${horasPeriodo}h', ladoBalao),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Balão em formato de gota (ponta para cima), como no Figma.
  Widget _balaoHoras(String texto, double lado) {
    return SizedBox(
      width: lado,
      height: lado,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: marrom,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(3),
              topRight: Radius.circular(lado / 2),
              bottomLeft: Radius.circular(lado / 2),
              bottomRight: Radius.circular(lado / 2),
            ),
          ),
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Text(
              texto,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paginaPontuacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: amareloSuave,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: pontuacao / 100,
                        strokeWidth: 12,
                        backgroundColor: AppColors.track,
                        valueColor: const AlwaysStoppedAnimation<Color>(marrom),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$pontuacao',
                          style: const TextStyle(
                            color: marrom,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'de 100 pontos',
                          style: TextStyle(
                            color: textoSuave,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.isTv ? 'Muito bom!' : 'Excelente!',
                style: const TextStyle(
                  color: marrom,
                  fontFamily: AppFonts.title,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Uma visão combinada do consumo, tempo de uso e aproveitamento do aparelho.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textoSuave, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _cartaoComTitulo(
          titulo: 'O que compõe sua pontuação',
          child: Column(
            children: [
              _linhaIndicador(
                Icons.bolt_rounded,
                'Consumo de energia',
                widget.isTv ? 'Bom' : 'Atenção',
                widget.isTv ? 0.8 : 0.63,
              ),
              _linhaIndicador(
                Icons.schedule_rounded,
                'Tempo de uso',
                widget.isTv ? 'Estável' : 'Elevado',
                widget.isTv ? 0.76 : 0.56,
              ),
              _linhaIndicador(
                Icons.speed_rounded,
                'Eficiência energética',
                '$eficiencia%',
                eficiencia / 100,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _paginaHistorico() {
    final valores = periodoHistorico == 'Semanal'
        ? <double>[0.24, 0.55, 0.43, 0.65, 0.48, 0.82, 0.68]
        : periodoHistorico == 'Mensal'
        ? <double>[0.34, 0.42, 0.56, 0.51, 0.74, 0.64, 0.88]
        : <double>[0.58, 0.45, 0.72, 0.63, 0.79, 0.69, 0.91];
    final labels = periodoHistorico == 'Semanal'
        ? <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
        : periodoHistorico == 'Mensal'
        ? <String>['1', '5', '10', '15', '20', '25', '30']
        : <String>['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cartaoGraficoLinha(
          periodo: periodoHistorico,
          aoMudar: (opcao) => setState(() => periodoHistorico = opcao),
          valores: valores,
          etiquetas: labels,
          altura: 260,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _resumoMini(
                'Horas usadas',
                '${horas}h',
                Icons.schedule_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _resumoMini(
                'Energia',
                '${_numero(energia)} kWh',
                Icons.bolt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _cartaoDica(
          icone: Icons.insights_rounded,
          titulo: 'Sobre o histórico',
          texto:
              'As linhas representam tendências demonstrativas. O aplicativo poderá comparar dados reais por semana, mês e período completo após conectar a fonte IoT.',
        ),
      ],
    );
  }

  Widget _paginaRecomendacoes() {
    final itens = widget.isTv
        ? <(IconData, String, String)>[
            (
              Icons.brightness_6_rounded,
              'Reduza o brilho',
              'Uma intensidade moderada melhora o conforto e pode reduzir o consumo.',
            ),
            (
              Icons.power_settings_new_rounded,
              'Evite o modo de espera',
              'Desligue a TV completamente quando ficar muito tempo sem uso.',
            ),
            (
              Icons.schedule_rounded,
              'Defina um horário',
              'Uma rotina de desligamento evita que o aparelho permaneça ligado sem necessidade.',
            ),
          ]
        : <(IconData, String, String)>[
            (
              Icons.thermostat_rounded,
              'Mantenha uma faixa confortável',
              'A configuração atual é de 23°C, próxima de uma faixa eficiente para muitos ambientes.',
            ),
            (
              Icons.air_rounded,
              'Limpe os filtros',
              'Filtros limpos ajudam a manter o fluxo de ar e o desempenho do aparelho.',
            ),
            (
              Icons.home_rounded,
              'Feche portas e janelas',
              'Reduzir a troca de calor ajuda o ambiente a chegar à temperatura desejada.',
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: amareloSuave,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: amarelo,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Icon(
                  widget.isTv ? Icons.tv_rounded : Icons.thermostat_rounded,
                  color: marrom,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isTv
                          ? 'Seu aparelho está estável'
                          : 'Temperatura atual',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isTv
                          ? 'Pequenos hábitos podem melhorar a economia.'
                          : temperatura,
                      style: const TextStyle(
                        color: laranja,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Sugestões para você',
          style: TextStyle(
            color: marrom,
            fontFamily: AppFonts.title,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        ...itens.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: fundoCartao.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: amarelo.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.$1, color: marrom, size: 23),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$2, style: AppTextStyles.bodyBold),
                        const SizedBox(height: 4),
                        Text(
                          item.$3,
                          style: const TextStyle(
                            color: textoSuave,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _cartaoDica(
          icone: Icons.info_outline_rounded,
          titulo: 'Recomendações demonstrativas',
          texto:
              'As sugestões não controlam o dispositivo automaticamente. A execução de comandos requer integração com o fabricante ou backend IoT.',
        ),
      ],
    );
  }

  Widget _paginaEficiencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: amareloSuave,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 174,
                width: 174,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: eficiencia / 100,
                        strokeWidth: 15,
                        backgroundColor: AppColors.track,
                        valueColor: const AlwaysStoppedAnimation<Color>(marrom),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$eficiencia%',
                          style: const TextStyle(
                            color: marrom,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'eficiência',
                          style: TextStyle(
                            color: textoSuave,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.isTv ? 'Bom aproveitamento' : 'Pode melhorar',
                style: const TextStyle(
                  color: marrom,
                  fontFamily: AppFonts.title,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isTv
                    ? 'O aparelho tem um índice positivo no cenário demonstrativo.'
                    : 'Alguns ajustes de temperatura e tempo podem aumentar o aproveitamento.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textoSuave,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _cartaoComTitulo(
          titulo: 'Como melhorar',
          child: Column(
            children: [
              _linhaSemProgresso(
                Icons.schedule_rounded,
                'Evite uso sem necessidade',
                'Use horários e rotinas',
              ),
              const Divider(height: 20, color: AppColors.divider),
              _linhaSemProgresso(
                Icons.bolt_rounded,
                'Acompanhe o consumo',
                'Revise a evolução semanal',
              ),
              const Divider(height: 20, color: AppColors.divider),
              _linhaSemProgresso(
                Icons.settings_rounded,
                'Ajuste as configurações',
                'Prefira modos econômicos',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linhaIndicador(
    IconData icone,
    String titulo,
    String status,
    double progresso,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: marrom, size: 21),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: AppTextStyles.caption)),
              Text(
                status,
                style: const TextStyle(
                  color: laranja,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: LinearProgressIndicator(
              value: progresso.clamp(0.0, 1.0).toDouble(),
              minHeight: 9,
              backgroundColor: AppColors.track,
              valueColor: const AlwaysStoppedAnimation<Color>(marrom),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaSemProgresso(IconData icone, String titulo, String subtitulo) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: amarelo.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Icon(icone, color: marrom, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: AppTextStyles.caption),
              const SizedBox(height: 3),
              Text(
                subtitulo,
                style: const TextStyle(color: textoSuave, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cartaoComTitulo({required String titulo, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: fundoCartao.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppTextStyles.cardTitle),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _resumoMini(String titulo, String valor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: fundoCartao.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(icone, color: marrom, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: textoSuave,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(valor, style: AppTextStyles.cardTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoDica({
    required IconData icone,
    required String titulo,
    required String texto,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: fundoCartao.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: marrom.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: marrom, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: const TextStyle(
                    color: textoSuave,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legenda(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
            border: Border.all(color: marrom.withValues(alpha: 0.35)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(
            color: marrom,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _numero(double valor) => valor.toStringAsFixed(1).replaceAll('.', ',');
}

/// Medidor em anel (270°) usado na tela de energia.
class MedidorAnelPainter extends CustomPainter {
  final double progresso;

  const MedidorAnelPainter({required this.progresso});

  @override
  void paint(Canvas canvas, Size size) {
    const espessura = 12.0;
    const inicio = 3 * math.pi / 4;
    const varredura = 3 * math.pi / 2;
    final centro = size.center(Offset.zero);
    final raio = (math.min(size.width, size.height) - espessura) / 2;
    final area = Rect.fromCircle(center: centro, radius: raio);

    final fundo = Paint()
      ..color = AppColors.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(area, inicio, varredura, false, fundo);

    final valor = progresso.clamp(0.0, 1.0).toDouble();
    if (valor > 0) {
      final frente = Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(area, inicio, varredura * valor, false, frente);
    }

    // Pontilhado interno decorativo.
    final ponto = Paint()..color = AppColors.track;
    final raioInterno = raio - espessura - 6;
    for (var i = 0; i < 40; i++) {
      final angulo = inicio + varredura * i / 39;
      canvas.drawCircle(
        centro + Offset(math.cos(angulo), math.sin(angulo)) * raioInterno,
        1.2,
        ponto,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MedidorAnelPainter oldDelegate) =>
      oldDelegate.progresso != progresso;
}

/// Períodos do dia usados na tela de horas usadas.
enum PeriodoDiaGrafico { manha, tarde, noite }

/// Desenha, dentro da barra preenchida, os detalhes de cada período:
/// brilhos (manhã), prédios (tarde) e estrelas com lua (noite).
class DecoracaoPeriodoPainter extends CustomPainter {
  final PeriodoDiaGrafico periodo;

  const DecoracaoPeriodoPainter({required this.periodo});

  @override
  void paint(Canvas canvas, Size size) {
    switch (periodo) {
      case PeriodoDiaGrafico.manha:
        _pontos(canvas, size, const <(double, double, double)>[
          (0.08, 0.30, 2.0),
          (0.18, 0.68, 1.5),
          (0.30, 0.25, 1.8),
          (0.42, 0.70, 2.2),
          (0.55, 0.35, 1.5),
          (0.68, 0.64, 2.0),
          (0.80, 0.28, 1.6),
          (0.92, 0.60, 1.8),
        ], 0.9);
      case PeriodoDiaGrafico.tarde:
        final tinta = Paint()..color = AppColors.white.withValues(alpha: 0.6);
        const predios = <(double, double, double)>[
          (10, 8, 12),
          (20, 7, 18),
          (29, 9, 14),
          (40, 7, 22),
          (49, 9, 16),
          (60, 7, 12),
          (69, 9, 20),
        ];
        for (final (x, largura, altura) in predios) {
          if (x + largura > size.width - 8) continue;
          canvas.drawRect(
            Rect.fromLTWH(x, size.height - altura - 4, largura, altura),
            tinta,
          );
        }
      case PeriodoDiaGrafico.noite:
        _pontos(canvas, size, const <(double, double, double)>[
          (0.07, 0.35, 1.4),
          (0.15, 0.70, 1.8),
          (0.26, 0.28, 1.2),
          (0.38, 0.62, 1.6),
          (0.47, 0.30, 1.4),
          (0.60, 0.72, 1.2),
          (0.72, 0.34, 1.8),
          (0.85, 0.66, 1.4),
        ], 0.85);
        _lua(canvas, size);
    }
  }

  void _pontos(
    Canvas canvas,
    Size size,
    List<(double, double, double)> pontos,
    double opacidade,
  ) {
    final tinta = Paint()..color = AppColors.white.withValues(alpha: opacidade);
    for (final (fx, fy, raio) in pontos) {
      canvas.drawCircle(Offset(size.width * fx, size.height * fy), raio, tinta);
    }
  }

  void _lua(Canvas canvas, Size size) {
    final r = size.height * 0.30;
    final centro = Offset(size.width - r - 10, size.height / 2);
    final lua = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: centro, radius: r)),
      Path()
        ..addOval(
          Rect.fromCircle(
            center: centro.translate(r * 0.55, -r * 0.35),
            radius: r * 0.85,
          ),
        ),
    );
    canvas.drawPath(lua, Paint()..color = AppColors.white);
  }

  @override
  bool shouldRepaint(covariant DecoracaoPeriodoPainter oldDelegate) =>
      oldDelegate.periodo != periodo;
}

/// Seta do balão de horas (triângulo apontando para cima).
class SetaBalaoPainter extends CustomPainter {
  final Color color;

  const SetaBalaoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final caminho = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(caminho, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant SetaBalaoPainter oldDelegate) =>
      oldDelegate.color != color;
}

class LinhaHistoricoPainter extends CustomPainter {
  final List<double> valores;
  final Color corLinha;

  const LinhaHistoricoPainter({required this.valores, required this.corLinha});

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.isEmpty) return;
    final linhaGrade = Paint()
      ..color = corLinha.withValues(alpha: 0.18)
      ..strokeWidth = 0.7;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linhaGrade);
    }

    // Cada ponto fica no centro do seu "slot", o mesmo espaço usado pelos
    // rótulos do eixo X (Expanded), para os dois ficarem alinhados.
    final larguraSlot = size.width / valores.length;
    final caminho = Path();
    final pontos = <Offset>[];
    for (var i = 0; i < valores.length; i++) {
      final ponto = Offset(
        larguraSlot * (i + 0.5),
        size.height -
            (valores[i].clamp(0.0, 1.0).toDouble() * (size.height - 12)) -
            6,
      );
      pontos.add(ponto);
      if (i == 0) {
        caminho.moveTo(ponto.dx, ponto.dy);
      } else {
        caminho.lineTo(ponto.dx, ponto.dy);
      }
    }

    // Guias verticais sob cada ponto, como no Figma.
    final guia = Paint()
      ..color = corLinha.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    for (final ponto in pontos) {
      canvas.drawLine(Offset(ponto.dx, 0), Offset(ponto.dx, size.height), guia);
    }

    final preenchimento = Path.from(caminho)
      ..lineTo(pontos.last.dx, size.height)
      ..lineTo(pontos.first.dx, size.height)
      ..close();
    canvas.drawPath(
      preenchimento,
      Paint()
        ..color = corLinha.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      caminho,
      Paint()
        ..color = corLinha
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    final tintaPontos = Paint()..color = AppColors.surfaceLight;
    for (final ponto in pontos) {
      canvas.drawCircle(ponto, 3, tintaPontos);
    }
  }

  @override
  bool shouldRepaint(covariant LinhaHistoricoPainter oldDelegate) =>
      oldDelegate.valores != valores || oldDelegate.corLinha != corLinha;
}