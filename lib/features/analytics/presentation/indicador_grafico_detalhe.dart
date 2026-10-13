import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

enum TipoIndicadorGrafico {
  energia,
  horas,
  pontuacao,
  historico,
  recomendacoes,
  eficiencia,
}

/// Tela secundária de um indicador. Os valores desta versão são demonstrativos;
/// os dados reais virão da integração com a API/hardware IoT.
class TelaIndicadorGraficoDetalhe extends StatefulWidget {
  final bool isTv;
  final String nomeAparelho;
  final TipoIndicadorGrafico indicador;

  const TelaIndicadorGraficoDetalhe({
    super.key,
    required this.isTv,
    required this.nomeAparelho,
    required this.indicador,
  });

  @override
  State<TelaIndicadorGraficoDetalhe> createState() =>
      _TelaIndicadorGraficoDetalheState();
}

class _TelaIndicadorGraficoDetalheState
    extends State<TelaIndicadorGraficoDetalhe> {
  static const Color marrom = AppColors.primary;
  static const Color marromEscuro = AppColors.primaryDark;
  static const Color creme = AppColors.surfaceLight;
  static const Color amarelo = AppColors.accent;
  static const Color amareloSuave = AppColors.surface;
  static const Color laranja = Color(0xFFC46B00);
  static const Color textoSuave = Color(0xFF81500F);

  String periodoEnergia = 'Mensal';
  String periodoHistorico = 'Semanal';

  double get energia => widget.isTv ? 12.5 : 28.4;
  double get limiteDiario => widget.isTv ? 15.0 : 35.0;
  int get horas => widget.isTv ? 12 : 18;
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Column(
            children: [
              _cabecalhoSuperior(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 22),
                  child: _conteudoIndicador(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalhoSuperior() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: marrom,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              '${widget.nomeAparelho} | $nomeIndicador',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: marrom,
                  size: 29,
                ),
              ),
              Expanded(
                child: Text(
                  _tituloPagina(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: marrom,
                    fontFamily: 'Arvo',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
        ],
      ),
    );
  }

  String _tituloPagina() {
    switch (widget.indicador) {
      case TipoIndicadorGrafico.energia:
        return 'Gasto diário';
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

  // Página de energia inspirada na referência enviada: medidor, limite e gráfico.
  Widget _paginaEnergia() {
    final fracao = (energia / limiteDiario).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: creme.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    SizedBox(
                      height: 82,
                      width: 132,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(132, 82),
                            painter: MedidorSemicircularPainter(
                              progresso: fracao,
                            ),
                          ),
                          Positioned(
                            bottom: 9,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: laranja,
                                  size: 25,
                                ),
                                Text(
                                  '${_numero(energia)} kWh',
                                  style: const TextStyle(
                                    color: laranja,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Consumo de hoje',
                      style: TextStyle(
                        color: textoSuave,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _seloInformacao(
                      icone: Icons.eco_rounded,
                      titulo: 'Energia',
                      valor: widget.isTv ? 'Economizada' : 'Consumo',
                      cor: const Color(0xFF4E8129),
                    ),
                    const SizedBox(height: 8),
                    _seloInformacao(
                      icone: Icons.bolt_rounded,
                      titulo: 'Limite',
                      valor: '${_numero(limiteDiario)} kWh/dia',
                      cor: laranja,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'Limite de energia',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: marrom,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${_numero(energia)} kWh usados',
          style: const TextStyle(
            color: laranja,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(height: 18, color: const Color(0xFFE8DDB8)),
              FractionallySizedBox(
                widthFactor: fracao,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9C9D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '0 kWh',
              style: TextStyle(
                color: textoSuave,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${_numero(limiteDiario)} kWh',
              style: const TextStyle(
                color: textoSuave,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legenda(const Color(0xFFFF9C9D), 'Energia usada'),
            const SizedBox(width: 13),
            _legenda(const Color(0xFFE8DDB8), 'Limite de energia'),
          ],
        ),
        const SizedBox(height: 20),
        _graficoEnergia(),
        const SizedBox(height: 12),
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

  Widget _seloInformacao({
    required IconData icone,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: amarelo.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: cor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  valor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _graficoEnergia() {
    final opcoes = ['Semanal', 'Mensal', 'Geral'];
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
    return Container(
      height: 166,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: opcoes.map((opcao) {
              final ativo = periodoEnergia == opcao;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => periodoEnergia = opcao),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ativo
                          ? const Color(0xFF71420D)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      opcao,
                      style: TextStyle(
                        color: ativo ? Colors.white : const Color(0xFFFFE8B0),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: CustomPaint(
              painter: LinhaHistoricoPainter(
                valores: valores,
                corLinha: const Color(0xFFFFE1A1),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Row(
            children: etiquetas
                .map(
                  (e) => Expanded(
                    child: Text(
                      e,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFE8B0),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
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

  // Página de horas com distribuição por períodos, como no segundo exemplo.
  Widget _paginaHoras() {
    final manha = widget.isTv ? 5 : 7;
    final tarde = widget.isTv ? 3 : 5;
    final noite = widget.isTv ? 4 : 6;
    final maxHoras = math.max(manha, math.max(tarde, noite)).toDouble();
    return Column(
      children: [
        _barraPeriodo(
          titulo: 'Manhã',
          horasPeriodo: manha,
          total: maxHoras,
          corFundo: const Color(0xFFFFEE64),
          corPreenchimento: const Color(0xFFFFFF00),
          icone: Icons.wb_sunny_rounded,
        ),
        const SizedBox(height: 14),
        _barraPeriodo(
          titulo: 'Tarde',
          horasPeriodo: tarde,
          total: maxHoras,
          corFundo: const Color(0xFFFFCA76),
          corPreenchimento: const Color(0xFFFF891B),
          icone: Icons.wb_sunny_rounded,
        ),
        const SizedBox(height: 14),
        _barraPeriodo(
          titulo: 'Noite',
          horasPeriodo: noite,
          total: maxHoras,
          corFundo: const Color(0xFFD8B6FF),
          corPreenchimento: const Color(0xFF812BFF),
          icone: Icons.nightlight_round,
        ),
        const SizedBox(height: 26),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: creme.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: marrom.withValues(alpha: 0.13)),
          ),
          child: Column(
            children: [
              const Text(
                'Total de Horas',
                style: TextStyle(
                  color: marrom,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${manha + tarde + noite}h',
                style: const TextStyle(
                  color: laranja,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: marrom,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.isTv
                            ? 'Mais 2 horas do que ontem'
                            : 'Uso elevado em relação a ontem',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _cartaoDica(
          icone: Icons.schedule_rounded,
          titulo: 'Resumo de utilização',
          texto:
              'A distribuição é estimada a partir de dados demonstrativos. Com a integração IoT, os períodos serão calculados automaticamente.',
        ),
      ],
    );
  }

  Widget _barraPeriodo({
    required String titulo,
    required int horasPeriodo,
    required double total,
    required Color corFundo,
    required Color corPreenchimento,
    required IconData icone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: marrom,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 43,
            color: corFundo,
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: (horasPeriodo / total)
                      .clamp(0.25, 1.0)
                      .toDouble(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: corPreenchimento,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: Icon(icone, color: Colors.white, size: 20),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        icone,
                        color: Colors.white.withValues(alpha: 0.78),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: marrom,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${horasPeriodo}h',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
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
            borderRadius: BorderRadius.circular(22),
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
                        backgroundColor: const Color(0xFFE8DDB8),
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
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'de 100 pontos',
                          style: TextStyle(
                            color: textoSuave,
                            fontSize: 11,
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
                  fontFamily: 'Arvo',
                  fontSize: 20,
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
    final opcoes = ['Semanal', 'Mensal', 'Geral'];
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
        Container(
          height: 300,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF3D2100),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: opcoes
                    .map(
                      (opcao) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          onTap: () => setState(() => periodoHistorico = opcao),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: periodoHistorico == opcao
                                  ? const Color(0xFF71420D)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              opcao,
                              style: TextStyle(
                                color: periodoHistorico == opcao
                                    ? Colors.white
                                    : const Color(0xFFFFE8B0),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: CustomPaint(
                  painter: LinhaHistoricoPainter(
                    valores: valores,
                    corLinha: const Color(0xFFFFE1A1),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: labels
                    .map(
                      (e) => Expanded(
                        child: Text(
                          e,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFE8B0),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: amarelo,
                  borderRadius: BorderRadius.circular(18),
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
                      style: const TextStyle(
                        color: marrom,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isTv
                          ? 'Pequenos hábitos podem melhorar a economia.'
                          : temperatura,
                      style: const TextStyle(
                        color: laranja,
                        fontSize: 22,
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
            fontFamily: 'Arvo',
            fontSize: 18,
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
                color: creme.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(17),
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
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: marrom,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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
            borderRadius: BorderRadius.circular(21),
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
                        backgroundColor: const Color(0xFFE8DDB8),
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
                            fontSize: 38,
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
                  fontFamily: 'Arvo',
                  fontSize: 20,
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
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: marrom,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  color: laranja,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progresso.clamp(0.0, 1.0).toDouble(),
              minHeight: 9,
              backgroundColor: const Color(0xFFE8DDB8),
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
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icone, color: marrom, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitulo,
                style: const TextStyle(color: textoSuave, fontSize: 11),
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
        color: creme.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: marrom,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
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
        color: creme.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(17),
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
                Text(
                  valor,
                  style: const TextStyle(
                    color: marrom,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
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
        color: creme.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(17),
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
                Text(
                  titulo,
                  style: const TextStyle(
                    color: marrom,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: const TextStyle(
                    color: textoSuave,
                    fontSize: 11,
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
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _numero(double valor) => valor.toStringAsFixed(1).replaceAll('.', ',');
}

class MedidorSemicircularPainter extends CustomPainter {
  final double progresso;

  const MedidorSemicircularPainter({required this.progresso});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, 3, size.width - 16, size.height * 1.78);
    final fundo = Paint()
      ..color = const Color(0xFFE8DDB8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    final frente = Paint()
      ..color = const Color(0xFFD9CDA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, fundo);
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * progresso.clamp(0.0, 1.0).toDouble(),
      false,
      frente,
    );
  }

  @override
  bool shouldRepaint(covariant MedidorSemicircularPainter oldDelegate) =>
      oldDelegate.progresso != progresso;
}

class LinhaHistoricoPainter extends CustomPainter {
  final List<double> valores;
  final Color corLinha;

  const LinhaHistoricoPainter({required this.valores, required this.corLinha});

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.isEmpty) return;
    final linhaGrade = Paint()
      ..color = const Color(0x55FFE8B0)
      ..strokeWidth = 0.7;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linhaGrade);
    }

    final caminho = Path();
    final passo = size.width / math.max(1, valores.length - 1);
    final pontos = <Offset>[];
    for (var i = 0; i < valores.length; i++) {
      final ponto = Offset(
        i.toDouble() * passo,
        size.height -
            (valores[i].clamp(0.0, 1.0).toDouble() * (size.height - 9)) -
            3,
      );
      pontos.add(ponto);
      if (i == 0) {
        caminho.moveTo(ponto.dx, ponto.dy);
      } else {
        caminho.lineTo(ponto.dx, ponto.dy);
      }
    }

    final preenchimento = Path.from(caminho)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final tintaPreenchimento = Paint()
      ..color = corLinha.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawPath(preenchimento, tintaPreenchimento);

    final tintaLinha = Paint()
      ..color = corLinha
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(caminho, tintaLinha);

    final tintaPontos = Paint()..color = const Color(0xFFFFF8DF);
    for (final ponto in pontos) {
      canvas.drawCircle(ponto, 2.6, tintaPontos);
    }
  }

  @override
  bool shouldRepaint(covariant LinhaHistoricoPainter oldDelegate) =>
      oldDelegate.valores != valores || oldDelegate.corLinha != corLinha;
}
