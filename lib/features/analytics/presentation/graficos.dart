import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/network/api_client.dart' show ApiException;
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/analytics/presentation/indicador_grafico_detalhe.dart';
import 'package:tcc_mobile/features/analytics/data/graficos_modelo_api.dart';
import 'package:tcc_mobile/features/settings/presentation/ajuda.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/widgets/seletor_locais.dart';

enum TipoAparelho { tv, arCondicionado, outro }

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
  bool _carregandoModelos = false;
  List<Map<String, dynamic>> _graficosModelo = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _carregarGraficosModelo();
  }

  Future<void> _carregarGraficosModelo() async {
    if (mounted) setState(() => _carregandoModelos = true);
    try {
      if (AparelhosStore.aparelhos.value.isEmpty) {
        await AparelhosStore.carregarDoBackend();
      }
      final modelos = await GraficosModeloApi.listar();
      if (!mounted) return;
      setState(() => _graficosModelo = modelos);
    } catch (erro) {
      if (!mounted) return;
      _mensagemGraficoIndisponivel(
        erro is ApiException ? erro.message : 'Não foi possível carregar os gráficos modelo.',
      );
    } finally {
      if (mounted) setState(() => _carregandoModelos = false);
    }
  }

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
            const SizedBox(height: AppSpacing.section),
            TituloSecao(
              titulo: 'Gráficos modelo',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Atualizar gráficos modelo',
                    visualDensity: VisualDensity.compact,
                    onPressed: _carregandoModelos ? null : _carregarGraficosModelo,
                    icon: const Icon(Icons.refresh_rounded, color: marrom),
                  ),
                  IconButton.filled(
                    tooltip: 'Criar gráfico modelo',
                    visualDensity: VisualDensity.compact,
                    onPressed: _abrirCriacaoGraficoModelo,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Dados artificiais para visualizar gráficos e testar a análise do Gemini. Não são leituras reais do aparelho.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_carregandoModelos)
              const Center(child: CircularProgressIndicator())
            else if (_graficosModelo.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Text(
                  'Nenhum gráfico modelo criado. Toque no + para escolher um aparelho e gerar dados de teste.',
                  style: AppTextStyles.body,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: _graficosModelo.map((grafico) {
                  final dispositivo = grafico['dispositivo'] is Map
                      ? (grafico['dispositivo'] as Map)
                      : const <String, dynamic>{};
                  final dispositivoId = '${dispositivo['id'] ?? grafico['dispositivoId'] ?? ''}';
                  final aparelhoEncontrado = AparelhosStore.aparelhos.value.where(
                    (item) => item.backendId == dispositivoId,
                  );
                  final aparelho = aparelhoEncontrado.isEmpty
                      ? null
                      : aparelhoEncontrado.first;
                  final nomeAparelho = '${dispositivo['nome'] ?? aparelho?.nome ?? 'Aparelho'}';
                  final nomeGrafico = '${grafico['nome'] ?? 'Gráfico modelo'}';
                  final leituras = grafico['leituras'] is List
                      ? (grafico['leituras'] as List).length
                      : ((grafico['minutoAtual'] as num?)?.toInt() ?? 0);
                  final consumoWh = grafico['consumoAcumulado'] is num
                      ? (grafico['consumoAcumulado'] as num).toDouble()
                      : 0.0;
                  final consumoKwh = consumoWh / 1000;
                  final tamanhoCard = (MediaQuery.sizeOf(context).width -
                      2 * AppSpacing.pageHorizontal - AppSpacing.md) / 2;

                  return SizedBox(
                    width: tamanhoCard,
                    child: GestureDetector(
                      onTap: aparelho == null
                          ? null
                          : () => _abrirGraficoModelo(aparelho, grafico),
                      child: _cardAparelho(
                        nome: nomeGrafico,
                        subtitulo: '$nomeAparelho • $leituras min',
                        icone: aparelho?.icone ?? Icons.science_outlined,
                        metrica: '${consumoKwh.toStringAsFixed(4).replaceAll('.', ',')} kWh',
                        mostrarMiniGrafico: true,
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
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

  Future<void> _abrirCriacaoGraficoModelo() async {
    try {
      if (AparelhosStore.aparelhos.value.isEmpty) {
        await AparelhosStore.carregarDoBackend();
      }
    } catch (erro) {
      _mensagemGraficoIndisponivel(
        erro is ApiException ? erro.message : 'Não foi possível carregar seus aparelhos.',
      );
      return;
    }

    final aparelhos = AparelhosStore.aparelhos.value
        .where((aparelho) => aparelho.backendId.trim().isNotEmpty)
        .toList(growable: false);
    if (aparelhos.isEmpty) {
      _mensagemGraficoIndisponivel('Cadastre um aparelho na sua conta antes de criar um gráfico modelo.');
      return;
    }

    final nomeController = TextEditingController();
    String dispositivoId = aparelhos.first.backendId;
    int quantidade = 30;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, atualizarDialogo) => AlertDialog(
          title: const Text('Criar gráfico modelo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0B8),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.science_outlined, color: AppColors.primary),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Este é um gráfico modelo. O FHIVE vai gerar leituras artificiais de potência, tensão, corrente e energia consumida a cada minuto. Elas serão salvas em Telemetrias com identificação de dados simulados e aparecerão no mesmo painel dos gráficos existentes.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: dispositivoId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Aparelho'),
                  items: aparelhos.map((aparelho) => DropdownMenuItem<String>(
                    value: aparelho.backendId,
                    child: Text('${aparelho.nome} • ${aparelho.tipo}', overflow: TextOverflow.ellipsis),
                  )).toList(growable: false),
                  onChanged: (valor) {
                    if (valor != null) atualizarDialogo(() => dispositivoId = valor);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: nomeController,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Nome do gráfico (opcional)',
                    hintText: 'Ex.: Teste de consumo noturno',
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: quantidade,
                  decoration: const InputDecoration(labelText: 'Quantidade de leituras'),
                  items: const [10, 20, 30, 45, 60].map((valor) => DropdownMenuItem<int>(
                    value: valor,
                    child: Text('$valor leituras • 1 minuto cada'),
                  )).toList(),
                  onChanged: (valor) {
                    if (valor != null) atualizarDialogo(() => quantidade = valor);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.add_chart_rounded),
              label: const Text('Criar modelo'),
            ),
          ],
        ),
      ),
    );

    final nome = nomeController.text.trim();
    nomeController.dispose();
    if (confirmado != true || !mounted) return;

    setState(() => _carregandoModelos = true);
    try {
      final resposta = await GraficosModeloApi.criar(
        dispositivoId: dispositivoId,
        nome: nome,
        quantidadeLeituras: quantidade,
      );
      final grafico = resposta['grafico'] is Map
          ? (resposta['grafico'] as Map).map((key, value) => MapEntry('$key', value))
          : resposta;
      if (!mounted) return;
      setState(() => _graficosModelo = <Map<String, dynamic>>[
        Map<String, dynamic>.from(grafico),
        ..._graficosModelo,
      ]);
      _mensagemGraficoIndisponivel('Gráfico modelo criado e salvo com sucesso.');
    } catch (erro) {
      _mensagemGraficoIndisponivel(
        erro is ApiException ? erro.message : 'Não foi possível criar o gráfico modelo.',
      );
    } finally {
      if (mounted) setState(() => _carregandoModelos = false);
    }
  }

  void _abrirGraficoModelo(
    AparelhoItem aparelho,
    Map<String, dynamic> grafico,
  ) {
    final tipoNormalizado = aparelho.tipo.trim().toLowerCase();
    final tipoGrafico = tipoNormalizado == 'tv' ||
            tipoNormalizado == 'televisão' ||
            tipoNormalizado == 'televisao'
        ? TipoAparelho.tv
        : tipoNormalizado.contains('ar condicionado') ||
                tipoNormalizado.contains('ar-condicionado')
            ? TipoAparelho.arCondicionado
            : TipoAparelho.outro;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TelaGraficosDetalhes(
          tipo: tipoGrafico,
          nomePersonalizado: aparelho.nome,
          local: aparelho.local,
          status: aparelho.status,
          deviceBackendId: aparelho.backendId,
          aparelhoSelecionado: aparelho,
          graficoModelo: grafico,
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
          aparelhoSelecionado: aparelho,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
  final AparelhoItem? aparelhoSelecionado;
  /// Quando informado, este mesmo painel usa uma sessão artificial de Telemetrias.
  final Map<String, dynamic>? graficoModelo;

  const TelaGraficosDetalhes({
    super.key,
    required this.tipo,
    this.nomePersonalizado,
    this.local = 'Sala de Estar',
    this.status = 'Online',
    this.deviceBackendId,
    this.aparelhoSelecionado,
    this.graficoModelo,
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
  bool get isOutro => widget.tipo == TipoAparelho.outro;

  bool get estaOnline => widget.status.trim().toLowerCase() == 'online';

  String get nomeAparelho => widget.nomePersonalizado ??
      (isTv ? 'TV - Cristal' : isOutro ? 'Aparelho' : 'Ar condicionado');

  IconData get iconeAparelho =>
      isTv ? Icons.tv_outlined : isOutro ? Icons.devices_other_outlined : Icons.air;

  bool get ehGraficoModelo => widget.graficoModelo != null;

  List<Map<String, dynamic>> get leiturasModelo {
    final lista = widget.graficoModelo?['leituras'];
    if (lista is! List) return <Map<String, dynamic>>[];
    return lista.whereType<Map>().map((item) => item.map(
      (key, value) => MapEntry('$key', value),
    )).toList(growable: false);
  }

  double get consumoModeloKwh {
    final totalWh = widget.graficoModelo?['consumoAcumulado'];
    return totalWh is num ? totalWh.toDouble() / 1000 : 0.0;
  }

  int get intervaloLeituraMinutos =>
      (widget.graficoModelo?['intervaloLeituraMinutos'] as num?)?.toInt() ?? 1;

  List<double> get serieEnergiaModelo {
    return leiturasModelo
        .map((item) => item['energy_wh'])
        .whereType<num>()
        .map((item) => item.toDouble() / 1000)
        .toList(growable: false);
  }

  List<double> _normalizarSerie(List<double> origem) {
    if (origem.isEmpty) return <double>[];
    final maximo = origem.reduce((a, b) => a > b ? a : b);
    if (maximo <= 0) return List<double>.filled(origem.length, 0.0);
    return origem.map((valor) => (valor / maximo).clamp(0.0, 1.0).toDouble()).toList(growable: false);
  }

  List<double> _amostrarSerie(List<double> origem, {int maxPontos = 7}) {
    if (origem.length <= maxPontos) return origem;
    return List<double>.generate(maxPontos, (indice) {
      final posicao = (indice * (origem.length - 1) / (maxPontos - 1)).round();
      return origem[posicao];
    }, growable: false);
  }

  List<String> _etiquetasModelo(int quantidade) {
    if (quantidade <= 0) return <String>[];
    if (quantidade == 1) return <String>['1 min'];
    return List<String>.generate(quantidade, (indice) {
      final ponto = (indice * (leiturasModelo.length - 1) / (quantidade - 1)).round() + 1;
      return '${ponto * intervaloLeituraMinutos}m';
    }, growable: false);
  }

  int get pontos => isTv ? 76 : isOutro ? 80 : 82;

  String get avaliacao => isTv ? 'Muito bom' : isOutro ? 'Modelo de teste' : 'Excelente';

  double get gastoEnergia => ehGraficoModelo ? consumoModeloKwh : (isTv ? 12.5 : isOutro ? 18.0 : 28.4);

  double get horasUsadas => ehGraficoModelo
      ? leiturasModelo.length * intervaloLeituraMinutos / 60.0
      : (isTv ? 12.0 : isOutro ? 8.0 : 18.0);

  String get horasUsadasLabel => ehGraficoModelo
      ? '${horasUsadas.toStringAsFixed(2).replaceAll('.', ',')} h'
      : '${horasUsadas.toInt()} h';

  String get terceiraValor => isTv ? '72%' : isOutro ? '—' : '23°C';

  List<double> get valoresGrafico {
    if (ehGraficoModelo) {
      return _normalizarSerie(_amostrarSerie(serieEnergiaModelo));
    }

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
    if (ehGraficoModelo) return _etiquetasModelo(valoresGrafico.length);
    if (periodoSelecionado == '6 meses') {
      return <String>['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
    }

    if (periodoSelecionado == '4 semanas') {
      return <String>['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'];
    }

    return <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  }

  @override
  void initState() {
    super.initState();
    if (ehGraficoModelo) periodoSelecionado = 'Por minuto';
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

                      const SizedBox(height: 14),

                      // Atalho contextual para dicas da IA sobre este aparelho.
                      _barraNotificacaoDicas(),

                      if (ehGraficoModelo) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0B8),
                            borderRadius: BorderRadius.circular(AppRadius.button),
                            border: Border.all(color: const Color(0xFFE1B54E)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.science_outlined, color: AppColors.primary, size: 18),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  '${widget.graficoModelo?['nome'] ?? 'Gráfico modelo'} • DADOS SIMULADOS: valores de energia gerados a cada minuto; não são medições reais.',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

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

  // Barra de notificação com acesso direto às dicas contextualizadas do Gemini.
  Widget _barraNotificacaoDicas() {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _abrirDicasDoAparelho,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceStrong,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dicas para $nomeAparelho',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Receba orientações da IA com o contexto deste aparelho.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  'Dicas',
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
    );
  }

  void _abrirDicasDoAparelho() {
    final aparelho = widget.aparelhoSelecionado ??
        AparelhoItem(
          nome: nomeAparelho,
          id: '',
          backendId: widget.deviceBackendId ?? '',
          tipo: isTv ? 'TV' : isOutro ? widget.aparelhoSelecionado?.tipo ?? 'Outro' : 'Ar condicionado',
          fabricante: 'Não informado',
          modelo: 'Não informado',
          status: widget.status,
          icone: iconeAparelho,
          wifi: false,
          local: widget.local,
          conexao: 'Não informado',
        );

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TelaAjuda(
          aparelhoContexto: aparelho,
          abrirChatInicial: true,
          graficoModeloId: widget.graficoModelo?['id']?.toString(),
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
                      : isOutro
                          ? 'Resumo baseado nas leituras de consumo e funcionamento do aparelho.'
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
            '${gastoEnergia.toStringAsFixed(ehGraficoModelo ? 4 : 1).replaceAll('.', ',')} kWh',
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
            horasUsadasLabel,
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
                isTv ? Icons.trending_flat : isOutro ? Icons.science_outlined : Icons.trending_up,
                color: marrom,
                size: 20,
              ),

              const SizedBox(width: 4),

              Text(
                isTv ? 'Uso estável' : isOutro ? 'Sessão simulada' : 'Uso elevado',
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
              Expanded(
                child: Text(
                  ehGraficoModelo ? 'Consumo por minuto' : 'Uso ao longo do tempo',
                  style: AppTextStyles.cardTitle,
                ),
              ),

              if (ehGraficoModelo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: amareloClaro,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Text('Por minuto', style: AppTextStyles.caption),
                )
              else
                PopupMenuButton<String>(
                  initialValue: periodoSelecionado,
                  color: amareloClaro,
                  onSelected: (valor) => setState(() => periodoSelecionado = valor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: '7 dias', child: Text('7 dias', style: TextStyle(color: marrom, fontWeight: FontWeight.w700))),
                    PopupMenuItem(value: '4 semanas', child: Text('4 semanas', style: TextStyle(color: marrom, fontWeight: FontWeight.w700))),
                    PopupMenuItem(value: '6 meses', child: Text('6 meses', style: TextStyle(color: marrom, fontWeight: FontWeight.w700))),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: amareloClaro, borderRadius: BorderRadius.circular(AppRadius.chip)),
                    child: Row(
                      children: [
                        Text(periodoSelecionado, style: AppTextStyles.caption),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: marrom, size: 17),
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
            ehGraficoModelo
                ? 'Consumo de energia gerado artificialmente a cada minuto.'
                : periodoSelecionado == '7 dias'
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
            isTv ? 'Recomendações' : isOutro ? 'Dados do aparelho' : 'Temperatura',
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
          ] else if (isOutro) ...[
            const Text(
              'Leituras simuladas',
              style: TextStyle(
                color: laranja,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _itemRecomendacaoGrande(Icons.bolt_rounded, 'Potência variando por minuto'),
                  _itemRecomendacaoGrande(Icons.electric_meter_outlined, 'Energia acumulada na sessão'),
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
                  _itemRecomendacaoGrande(Icons.check_circle_outline, 'Faixa recomendada'),
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
    final double eficiencia = isTv ? 0.82 : isOutro ? 0.75 : 0.72;

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
                : isOutro
                    ? 'Acompanhe a variação das leituras simuladas.'
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
          graficoModelo: widget.graficoModelo,
          isGenerico: isOutro,
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