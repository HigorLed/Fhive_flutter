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
  final bool isGenerico;
  final String nomeAparelho;
  final String local;
  final TipoIndicadorGrafico indicador;
  final String? deviceBackendId;
  final Map<String, dynamic>? graficoModelo;

  const TelaIndicadorGraficoDetalhe({
    super.key,
    required this.isTv,
    this.isGenerico = false,
    required this.nomeAparelho,
    this.local = 'Sala de Estar',
    required this.indicador,
    this.deviceBackendId,
    this.graficoModelo,
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
  bool _mostrarEnergiaEconomizada = false;
  List<Map<String, dynamic>> _telemetrias = <Map<String, dynamic>>[];

  Map<String, dynamic>? get _ultimaTelemetria =>
      _telemetrias.isEmpty ? null : _telemetrias.first;

  double get energia {
    final consumoWh = _ultimaTelemetria?['consumoAcumulado'];
    if (consumoWh is num) return consumoWh.toDouble() / 1000;
    return widget.isTv ? 12.5 : widget.isGenerico ? 18.0 : 28.4;
  }

  double get limiteDiario => widget.isTv ? 15.0 : widget.isGenerico ? 20.0 : 35.0;

  // Indicadores de economia ainda demonstrativos: o backend não fornece
  // uma linha de base para calcular energia realmente economizada.
  double get energiaEconomizadaDemonstrativa => widget.isTv ? 2.8 : widget.isGenerico ? 2.0 : 4.6;
  double get metaEconomiaDiaria => widget.isTv ? 5.0 : widget.isGenerico ? 3.0 : 8.0;

  int get horas => widget.isTv ? 12 : widget.isGenerico ? 8 : 18;
  int get horasManha => widget.isTv ? 5 : widget.isGenerico ? 3 : 7;
  int get horasTarde => widget.isTv ? 3 : widget.isGenerico ? 2 : 5;
  int get horasNoite => widget.isTv ? 4 : widget.isGenerico ? 3 : 6;
  int get totalHoras => horasManha + horasTarde + horasNoite;
  // Comparativo demonstrativo até existir uma série diária no backend.
  int get horasAmaisOntem => widget.isTv ? 2 : widget.isGenerico ? 1 : 3;
  int get pontuacao => widget.isTv ? 76 : widget.isGenerico ? 80 : 82;
  int get eficiencia => widget.isTv ? 82 : widget.isGenerico ? 75 : 72;
  String get temperatura => widget.isGenerico ? '—' : widget.isTv ? '72%' : '23°C';

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
        return widget.isTv ? 'Recomendações' : widget.isGenerico ? 'Dados do aparelho' : 'Temperatura';
      case TipoIndicadorGrafico.eficiencia:
        return 'Eficiência energética';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.graficoModelo != null) {
      _telemetrias = <Map<String, dynamic>>[widget.graficoModelo!];
      periodoEnergia = 'Por minuto';
      periodoHistorico = 'Por minuto';
    } else {
      _carregarTelemetria();
    }
  }

  List<Map<String, dynamic>> get _leiturasModelo {
    final lista = widget.graficoModelo?['leituras'];
    if (lista is! List) return <Map<String, dynamic>>[];
    return lista.whereType<Map>().map((item) => item.map(
      (key, value) => MapEntry('$key', value),
    )).toList(growable: false);
  }

  List<double> get _serieModeloKwh => _leiturasModelo
      .map((item) => item['energy_wh'])
      .whereType<num>()
      .map((item) => item.toDouble() / 1000)
      .toList(growable: false);

  List<double> _amostrarModelo(List<double> origem, {int limite = 7}) {
    if (origem.length <= limite) return origem;
    return List<double>.generate(limite, (indice) {
      final posicao = (indice * (origem.length - 1) / (limite - 1)).round();
      return origem[posicao];
    }, growable: false);
  }

  List<double> _normalizarModelo(List<double> origem) {
    if (origem.isEmpty) return <double>[];
    final maximo = origem.reduce((a, b) => a > b ? a : b);
    if (maximo <= 0) return List<double>.filled(origem.length, 0.0);
    return origem.map((valor) => (valor / maximo).clamp(0.0, 1.0).toDouble()).toList(growable: false);
  }

  List<String> _etiquetasModelo(int quantidade) {
    if (quantidade <= 0) return <String>[];
    if (quantidade == 1) return <String>['1m'];
    final intervalo = (widget.graficoModelo?['intervaloLeituraMinutos'] as num?)?.toInt() ?? 1;
    return List<String>.generate(quantidade, (indice) {
      final amostra = (indice * (_leiturasModelo.length - 1) / (quantidade - 1)).round() + 1;
      return '${amostra * intervalo}m';
    }, growable: false);
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
        return widget.isTv ? 'Dicas para economizar' : widget.isGenerico ? 'Leituras do aparelho' : 'Condição atual';
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

  // Página de energia com dois indicadores selecionáveis:
  // limite de consumo (rosa) e energia economizada (verde).
  Widget _paginaEnergia() {
    final valorExibido = _mostrarEnergiaEconomizada
        ? energiaEconomizadaDemonstrativa
        : energia;
    final limiteExibido = _mostrarEnergiaEconomizada
        ? metaEconomiaDiaria
        : limiteDiario;
    final corIndicador = _mostrarEnergiaEconomizada
        ? AppColors.success
        : _rosaEnergia;
    final corMedidor = _mostrarEnergiaEconomizada
        ? AppColors.success
        : AppColors.accent;
    final tituloIndicador = _mostrarEnergiaEconomizada
        ? 'Energia economizada'
        : 'Limite de energia';
    final textoValor = _mostrarEnergiaEconomizada
        ? '${_numero(valorExibido)} kWh economizados'
        : '${_numero(valorExibido)} kWh usados';
    final textoLegenda = _mostrarEnergiaEconomizada
        ? 'Energia economizada'
        : 'Energia usada';
    final textoReferencia = _mostrarEnergiaEconomizada
        ? 'Meta de economia'
        : 'Limite de energia';

    final fracao = (valorExibido / limiteExibido)
        .clamp(0.0, 1.0)
        .toDouble();
    // Mantém uma pequena parte visível quando o valor é muito baixo.
    final fracaoVisivel = valorExibido > 0
        ? math.max(fracao, 0.018).toDouble()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: _medidor(
                  fracao,
                  valor: valorExibido,
                  corProgresso: corMedidor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _botaoOpcaoEnergia(
                    emblema: r'R$',
                    texto: 'Energia\nEconomizada',
                    selecionado: _mostrarEnergiaEconomizada,
                    aoTocar: () => setState(
                      () => _mostrarEnergiaEconomizada = true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _botaoOpcaoEnergia(
                    icone: Icons.bolt_rounded,
                    texto: 'Limite de\nenergia',
                    selecionado: !_mostrarEnergiaEconomizada,
                    aoTocar: () => setState(
                      () => _mostrarEnergiaEconomizada = false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          tituloIndicador,
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          textoValor,
          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Stack(
            children: [
              Container(height: 22, color: AppColors.track),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fracaoVisivel,
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: corIndicador,
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
              '${_numero(limiteExibido)} kWh',
              style: AppTextStyles.chartLabel,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legenda(corIndicador, textoLegenda),
            const SizedBox(width: AppSpacing.lg),
            _legenda(AppColors.track, textoReferencia),
          ],
        ),
        if (_mostrarEnergiaEconomizada) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Valor demonstrativo: a economia real depende da comparação com uma referência de consumo.',
            textAlign: TextAlign.center,
            style: AppTextStyles.chartLabel.copyWith(
              color: AppColors.primaryDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _graficoEnergia(),
        const SizedBox(height: AppSpacing.md),
        _cartaoDica(
          icone: Icons.lightbulb_outline_rounded,
          titulo: _mostrarEnergiaEconomizada
              ? 'Sobre a energia economizada'
              : 'Dica para economizar',
          texto: _mostrarEnergiaEconomizada
              ? 'Este valor é demonstrativo. Para calcular a economia real, o FHIVE precisará comparar o consumo medido com uma referência do mesmo aparelho e período.'
              : widget.isTv
                  ? 'Desligue a TV completamente quando não estiver usando para reduzir o consumo em espera.'
                  : widget.isGenerico
                      ? 'Observe a variação das leituras simuladas e compare a potência e a energia ao longo da sessão.'
                      : 'Ajustar a temperatura em 1°C pode ajudar a reduzir o gasto do ar-condicionado.',
        ),
      ],
    );
  }

  static const Color _rosaEnergia = Color(0xFFFF9C9D);

  Widget _medidor(
    double fracao, {
    required double valor,
    required Color corProgresso,
  }) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 150),
            painter: MedidorAnelPainter(
              progresso: fracao,
              corProgresso: corProgresso,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: laranja, size: 34),
              Text(
                '${_numero(valor)} kWh',
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

  Widget _botaoOpcaoEnergia({
    IconData? icone,
    String? emblema,
    required String texto,
    required bool selecionado,
    required VoidCallback aoTocar,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: aoTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: selecionado ? AppColors.surfaceStrong : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: selecionado ? AppColors.surfaceStrong : AppColors.track,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (emblema != null)
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selecionado ? AppColors.accent : AppColors.surface,
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
                Icon(icone, color: marrom, size: 24),
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
        ),
      ),
    );
  }

  Widget _graficoEnergia() {
    if (widget.graficoModelo != null && !_mostrarEnergiaEconomizada) {
      final serie = _serieModeloKwh;
      final amostrada = _amostrarModelo(serie);
      final maximo = amostrada.isEmpty
          ? 0.001
          : amostrada.reduce((a, b) => a > b ? a : b) * 1.15;
      return _cartaoGraficoLinha(
        periodo: 'Por minuto',
        opcoes: const <String>['Por minuto'],
        aoMudar: (_) {},
        valores: _normalizarModelo(amostrada),
        etiquetas: _etiquetasModelo(amostrada.length),
        corLinha: AppColors.surfaceWarm,
        maximoEixoY: maximo,
      );
    }

    final valores = _mostrarEnergiaEconomizada
        ? periodoEnergia == 'Semanal'
            ? <double>[0.30, 0.46, 0.38, 0.58, 0.63, 0.52, 0.68]
            : periodoEnergia == 'Mensal'
                ? <double>[0.36, 0.48, 0.43, 0.64, 0.58, 0.73, 0.66]
                : <double>[0.48, 0.39, 0.57, 0.53, 0.69, 0.64, 0.78]
        : periodoEnergia == 'Semanal'
            ? <double>[0.25, 0.42, 0.40, 0.64, 0.72, 0.53, 0.38]
            : periodoEnergia == 'Mensal'
                ? <double>[0.36, 0.55, 0.45, 0.71, 0.62, 0.79, 0.56]
                : <double>[0.52, 0.38, 0.66, 0.48, 0.77, 0.61, 0.84];
    final etiquetas = periodoEnergia == 'Semanal'
        ? <String>['S', 'T', 'Q', 'Q', 'S', 'S', 'D']
        : periodoEnergia == 'Mensal'
            ? <String>['1', '5', '10', '15', '20', '25', '30']
            : <String>['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul'];
    final maximo = _mostrarEnergiaEconomizada
        ? metaEconomiaDiaria
        : limiteDiario;

    return _cartaoGraficoLinha(
      periodo: periodoEnergia,
      aoMudar: (opcao) => setState(() => periodoEnergia = opcao),
      valores: valores,
      etiquetas: etiquetas,
      // O gráfico histórico permanece branco/creme nos dois modos.
      // O verde é reservado apenas ao indicador de energia economizada.
      corLinha: AppColors.surfaceWarm,
      // Semanal e Mensal mostram valores diários; Geral apresenta o mês.
      maximoEixoY: periodoEnergia == 'Geral' ? maximo * 30 : maximo,
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
    double? maximoEixoY,
    Color corLinha = AppColors.surfaceWarm,
    List<String> opcoes = const <String>['Semanal', 'Mensal', 'Geral'],
  }) {
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
          if (maximoEixoY != null)
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 2, bottom: 2),
                child: Text(
                  'kWh',
                  style: TextStyle(
                    color: AppColors.surfaceWarm,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                if (maximoEixoY != null)
                  SizedBox(
                    width: 39,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List<Widget>.generate(5, (indice) {
                        final fator = 1 - (indice / 4);
                        final valor = maximoEixoY * fator;
                        return Text(
                          _numero(valor),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppColors.surfaceWarm,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                    ),
                  ),
                if (maximoEixoY != null) const SizedBox(width: 5),
                Expanded(
                  child: CustomPaint(
                    painter: LinhaHistoricoPainter(
                      valores: valores,
                      corLinha: corLinha,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              if (maximoEixoY != null) const SizedBox(width: 44),
              Expanded(
                child: Row(
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
    // Cada faixa representa até 8 horas, totalizando 24h no dia.
    const limiteHorasPeriodo = 8;

    // O conteúdo usa sua altura natural. A folha externa já possui
    // SingleChildScrollView, então telas menores rolam sem overflow interno.
    return _molduraOrnamental(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _barraPeriodo(
            titulo: 'Manhã',
            horasPeriodo: horasManha,
            total: limiteHorasPeriodo.toDouble(),
            // Amarelo-ouro de manhã, com contraste maior que o amarelo neon.
            corFundo: const Color(0xFFFFE7A1),
            corPreenchimento: const Color(0xFFFFB52E),
            periodo: PeriodoDiaGrafico.manha,
          ),
          const SizedBox(height: 10),
          _barraPeriodo(
            titulo: 'Tarde',
            horasPeriodo: horasTarde,
            total: limiteHorasPeriodo.toDouble(),
            corFundo: const Color(0xFFFFCC80),
            corPreenchimento: const Color(0xFFFF8F1F),
            periodo: PeriodoDiaGrafico.tarde,
          ),
          const SizedBox(height: 10),
          _barraPeriodo(
            titulo: 'Noite',
            horasPeriodo: horasNoite,
            total: limiteHorasPeriodo.toDouble(),
            corFundo: const Color(0xFFC5A8FF),
            corPreenchimento: const Color(0xFF7B2FF7),
            periodo: PeriodoDiaGrafico.noite,
          ),
          const SizedBox(height: 14),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Total de Horas: ${totalHoras}h',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              const SizedBox(height: 7),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
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
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${horasAmaisOntem}h a mais que ontem',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Moldura dupla marrom ao redor do conteúdo, como no Figma.
  Widget _molduraOrnamental({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: marrom, width: 1.6),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
    final fracao = (horasPeriodo / total).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 1),
        Text(
          '$horasPeriodo h usadas • Limite: ${total.toInt()} h',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            const ladoBalao = 30.0;
            final larguraPreenchida = constraints.maxWidth * fracao;
            final esquerdaBalao = (larguraPreenchida - ladoBalao - 2)
                .clamp(0.0, constraints.maxWidth - ladoBalao)
                .toDouble();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: SizedBox(
                    height: 36,
                    child: Stack(
                      children: [
                        Positioned.fill(child: ColoredBox(color: corFundo)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: fracao,
                            heightFactor: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              child: ColoredBox(
                                color: corPreenchimento,
                                // A pintura recebe somente a largura preenchida,
                                // nunca a parte vazia da trilha.
                                child: CustomPaint(
                                  painter: DecoracaoPeriodoPainter(
                                    periodo: periodo,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: esquerdaBalao,
                        top: 0,
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
                widget.isTv ? 'Muito bom!' : widget.isGenerico ? 'Cenário simulado' : 'Excelente!',
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
                widget.isTv ? 'Bom' : widget.isGenerico ? 'Simulado' : 'Atenção',
                widget.isTv ? 0.8 : widget.isGenerico ? 0.75 : 0.63,
              ),
              _linhaIndicador(
                Icons.schedule_rounded,
                'Tempo de uso',
                widget.isTv ? 'Estável' : widget.isGenerico ? 'Simulado' : 'Elevado',
                widget.isTv ? 0.76 : widget.isGenerico ? 0.75 : 0.56,
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
    if (widget.graficoModelo != null) {
      final serie = _serieModeloKwh;
      final amostrada = _amostrarModelo(serie);
      final maximo = amostrada.isEmpty
          ? 0.001
          : amostrada.reduce((a, b) => a > b ? a : b) * 1.15;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cartaoGraficoLinha(
            periodo: 'Por minuto',
            opcoes: const <String>['Por minuto'],
            aoMudar: (_) {},
            valores: _normalizarModelo(amostrada),
            etiquetas: _etiquetasModelo(amostrada.length),
            altura: 260,
            maximoEixoY: maximo,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _resumoMini('Leituras', '${_leiturasModelo.length}', Icons.timeline_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resumoMini('Energia', '${_numero(energia)} kWh', Icons.bolt_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _cartaoDica(
            icone: Icons.science_outlined,
            titulo: 'Gráfico modelo',
            texto: 'Cada ponto representa energia simulada consumida em um minuto. Os valores não são medições reais do aparelho.',
          ),
        ],
      );
    }

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
        : widget.isGenerico
            ? <(IconData, String, String)>[
                (
                  Icons.bolt_rounded,
                  'Observe a potência',
                  'Compare as variações de potência entre as leituras simuladas.',
                ),
                (
                  Icons.electric_meter_rounded,
                  'Acompanhe a energia',
                  'O consumo acumulado é calculado pela soma da energia de cada minuto.',
                ),
                (
                  Icons.science_outlined,
                  'Lembre-se da simulação',
                  'Os valores foram gerados para testes e não são medições do aparelho físico.',
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
                  widget.isTv ? Icons.tv_rounded : widget.isGenerico ? Icons.devices_other_rounded : Icons.thermostat_rounded,
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
                          : widget.isGenerico
                              ? 'Sessão de dados simulados'
                              : 'Temperatura atual',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isTv
                          ? 'Pequenos hábitos podem melhorar a economia.'
                          : widget.isGenerico
                              ? 'Leituras artificiais geradas a cada minuto.'
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
                widget.isTv ? 'Bom aproveitamento' : widget.isGenerico ? 'Dados de teste' : 'Pode melhorar',
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
                    : widget.isGenerico
                        ? 'Este índice é demonstrativo e não representa uma avaliação técnica do equipamento.'
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

  String _numero(double valor) =>
      (valor.abs() < 0.1 ? valor.toStringAsFixed(4) : valor.toStringAsFixed(1)).replaceAll('.', ',');
}

/// Medidor em anel (270°) usado na tela de energia.
class MedidorAnelPainter extends CustomPainter {
  final double progresso;
  final Color corProgresso;

  const MedidorAnelPainter({
    required this.progresso,
    this.corProgresso = AppColors.accent,
  });

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
        ..color = corProgresso
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
      oldDelegate.progresso != progresso ||
      oldDelegate.corProgresso != corProgresso;
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
          (0.05, 0.30, 2.0),
          (0.17, 0.68, 1.5),
          (0.29, 0.25, 1.8),
          (0.41, 0.70, 2.2),
          (0.53, 0.35, 1.5),
          (0.65, 0.64, 2.0),
          (0.77, 0.28, 1.6),
          (0.96, 0.60, 1.8),
        ], 0.9);
      case PeriodoDiaGrafico.tarde:
        final tinta = Paint()..color = AppColors.white.withValues(alpha: 0.62);
        const predios = <(double, double, double)>[
          (0.04, 0.045, 0.42),
          (0.15, 0.045, 0.68),
          (0.26, 0.045, 0.50),
          (0.37, 0.045, 0.82),
          (0.48, 0.045, 0.62),
          (0.59, 0.045, 0.46),
          (0.70, 0.045, 0.72),
          (0.81, 0.045, 0.56),
          (0.92, 0.045, 0.76),
        ];
        for (final (fx, larguraRelativa, alturaRelativa) in predios) {
          final x = size.width * fx;
          final largura = math.max(3.0, size.width * larguraRelativa).toDouble();
          final altura = size.height * alturaRelativa;
          if (x + largura > size.width - 3) continue;
          canvas.drawRect(
            Rect.fromLTWH(x, size.height - altura - 3, largura, altura),
            tinta,
          );
        }
      case PeriodoDiaGrafico.noite:
        _pontos(canvas, size, const <(double, double, double)>[
          (0.05, 0.35, 1.4),
          (0.17, 0.70, 1.8),
          (0.29, 0.28, 1.2),
          (0.41, 0.62, 1.6),
          (0.53, 0.30, 1.4),
          (0.65, 0.72, 1.2),
          (0.77, 0.34, 1.8),
          (0.94, 0.66, 1.4),
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
    for (var i = 0; i <= 4; i++) {
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