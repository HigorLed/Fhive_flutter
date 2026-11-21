import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcc_mobile/core/network/api_client.dart' show ApiException;
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/features/ai/data/ia_api.dart';
import 'package:tcc_mobile/features/analytics/data/graficos_modelo_api.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

class TelaAjuda extends StatefulWidget {
  final AparelhoItem? aparelhoContexto;
  final bool abrirChatInicial;
  final String? graficoModeloId;

  const TelaAjuda({
    super.key,
    this.aparelhoContexto,
    this.abrirChatInicial = false,
    this.graficoModeloId,
  });

  @override
  State<TelaAjuda> createState() => _TelaAjudaState();
}

class _TelaAjudaState extends State<TelaAjuda> {
  static const _duvidas = <(String, String)>[
    (
      'Como adicionar um aparelho?',
      'Abra Aparelhos ou toque no botão +. Informe o nome e o ID, selecione o tipo e o local, configure os dados de conexão e revise antes de adicionar. O pareamento real depende da integração com o aparelho IoT.',
    ),
    (
      'Como favoritar um aparelho?',
      'Na tela Aparelhos, toque na estrela do cartão. Os favoritos também ficam disponíveis na tela Início e podem ser removidos diretamente por lá.',
    ),
    (
      'Como criar uma rotina?',
      'Abra Rotinas, escolha Adicionar rotina, selecione o aparelho e o horário e salve. A rotina é persistida no backend. A API atual ainda não executa comandos físicos; o botão informa essa limitação.',
    ),
    (
      'Por que alguns dados são demonstrativos?',
      'A autenticação, o perfil, os aparelhos e as rotinas usam o backend. As métricas sem telemetria MQTT real continuam demonstrativas, e os comandos físicos dos aparelhos ainda não estão conectados a uma API de controle.',
    ),
  ];

  final TextEditingController _mensagemController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<_MensagemChat> _mensagensChat = <_MensagemChat>[];
  final List<Map<String, String>> _historicoChat =
      <Map<String, String>>[];

  final GlobalKey<FormState> _formEstimativaKey = GlobalKey<FormState>();
  final TextEditingController _nomeEstimativaController =
      TextEditingController();
  final TextEditingController _tipoEstimativaController =
      TextEditingController();
  final TextEditingController _marcaEstimativaController =
      TextEditingController();
  final TextEditingController _modeloEstimativaController =
      TextEditingController();
  final TextEditingController _potenciaController = TextEditingController();
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _quantidadeController =
      TextEditingController(text: '1');
  final TextEditingController _diasController =
      TextEditingController(text: '30');

  final GlobalKey<FormState> _formAnomaliaKey = GlobalKey<FormState>();
  final TextEditingController _potenciaNominalController =
      TextEditingController();
  final TextEditingController _tensaoNominalController =
      TextEditingController();
  final TextEditingController _correnteNominalController =
      TextEditingController();
  final TextEditingController _consumoEsperadoController =
      TextEditingController();
  final TextEditingController _descricaoUsoController =
      TextEditingController();

  int _secaoSelecionada = 0;
  int _ferramentaSelecionada = 0;
  bool _enviandoMensagem = false;
  bool _estimandoConsumo = false;
  bool _analisandoDispositivo = false;
  bool _carregandoAparelhos = false;
  bool _carregandoGraficosModelo = false;
  bool _usarGraficoModelo = false;
  String? _erroCarregamentoAparelhos;
  String? _aparelhoSelecionadoId;
  String? _graficoModeloSelecionadoId;
  List<Map<String, dynamic>> _graficosModelo = <Map<String, dynamic>>[];
  Map<String, dynamic>? _resultadoEstimativa;
  Map<String, dynamic>? _resultadoAnomalia;

  @override
  void initState() {
    super.initState();

    final aparelho = widget.aparelhoContexto;
    if (aparelho != null) {
      _aparelhoSelecionadoId = aparelho.backendId.trim().isEmpty
          ? null
          : aparelho.backendId;
      _nomeEstimativaController.text = aparelho.nome;
      _tipoEstimativaController.text = aparelho.tipo;
      if (aparelho.fabricante.trim().isNotEmpty &&
          aparelho.fabricante.toLowerCase() != 'não informado') {
        _marcaEstimativaController.text = aparelho.fabricante;
      }
      if (aparelho.modelo.trim().isNotEmpty &&
          aparelho.modelo.toLowerCase() != 'não informado') {
        _modeloEstimativaController.text = aparelho.modelo;
      }
    }

    if (widget.abrirChatInicial) {
      _secaoSelecionada = 1;
    }
    if (widget.graficoModeloId != null) {
      _secaoSelecionada = 2;
      _ferramentaSelecionada = 1;
      _usarGraficoModelo = true;
      _graficoModeloSelecionadoId = widget.graficoModeloId;
    }

    _carregarAparelhos();

    // Ao entrar pela opção "Dicas" dos gráficos, já solicita uma orientação
    // inicial ao Gemini utilizando o contexto do aparelho selecionado.
    if (widget.abrirChatInicial && aparelho != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _enviarPergunta(
          'Com base nas informações deste aparelho, dê dicas personalizadas e seguras para melhorar o uso, acompanhar o funcionamento e, quando possível, reduzir o consumo de energia. Diferencie informações conhecidas de hipóteses e não invente especificações.',
        );
      });
    }
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    _chatScrollController.dispose();
    _nomeEstimativaController.dispose();
    _tipoEstimativaController.dispose();
    _marcaEstimativaController.dispose();
    _modeloEstimativaController.dispose();
    _potenciaController.dispose();
    _horasController.dispose();
    _quantidadeController.dispose();
    _diasController.dispose();
    _potenciaNominalController.dispose();
    _tensaoNominalController.dispose();
    _correnteNominalController.dispose();
    _consumoEsperadoController.dispose();
    _descricaoUsoController.dispose();
    super.dispose();
  }

  Future<void> _carregarAparelhos() async {
    if (!mounted) return;
    setState(() {
      _carregandoAparelhos = true;
      _erroCarregamentoAparelhos = null;
    });

    try {
      await AparelhosStore.carregarDoBackend();
      final disponiveis = AparelhosStore.aparelhos.value
          .where((aparelho) => aparelho.backendId.trim().isNotEmpty)
          .toList(growable: false);
      if (!mounted) return;

      String? idSelecionado = _aparelhoSelecionadoId;
      if (disponiveis.isNotEmpty &&
          !disponiveis.any((aparelho) => aparelho.backendId == idSelecionado)) {
        idSelecionado = disponiveis.first.backendId;
      }

      setState(() => _aparelhoSelecionadoId = idSelecionado);
      if (idSelecionado != null) {
        await _carregarGraficosModelo(idSelecionado);
      }
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erroCarregamentoAparelhos = _mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _carregandoAparelhos = false);
    }
  }

  Future<void> _carregarGraficosModelo(String dispositivoId) async {
    if (dispositivoId.trim().isEmpty) return;
    if (mounted) setState(() => _carregandoGraficosModelo = true);
    try {
      final todos = await GraficosModeloApi.listar();
      final filtrados = todos.where((grafico) {
        final device = grafico['dispositivo'];
        final deviceId = device is Map
            ? '${device['id'] ?? ''}'
            : '${grafico['dispositivoId'] ?? ''}';
        return deviceId == dispositivoId;
      }).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _graficosModelo = filtrados;
        if (!filtrados.any((item) => '${item['id']}' == _graficoModeloSelecionadoId)) {
          _graficoModeloSelecionadoId = filtrados.isEmpty
              ? null
              : '${filtrados.first['id']}';
        }
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _graficosModelo = <Map<String, dynamic>>[]);
    } finally {
      if (mounted) setState(() => _carregandoGraficosModelo = false);
    }
  }

  String _mensagemErro(Object erro) {
    if (erro is ApiException) return erro.message;
    return 'Não foi possível concluir a solicitação. Tente novamente.';
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _enviarPergunta([String? perguntaRapida]) async {
    final pergunta = (perguntaRapida ?? _mensagemController.text).trim();
    if (pergunta.isEmpty || _enviandoMensagem) return;

    _mensagemController.clear();
    final historicoAnterior = _historicoChat
        .map((mensagem) => Map<String, String>.from(mensagem))
        .toList(growable: false);

    setState(() {
      _mensagensChat.add(_MensagemChat(texto: pergunta, usuario: true));
      _enviandoMensagem = true;
    });
    _rolarChatParaFinal();

    try {
      final aparelho = widget.aparelhoContexto;
      final resposta = await IaApi.perguntar(
        pergunta: pergunta,
        historico: historicoAnterior,
        aparelho: aparelho == null
            ? null
            : <String, dynamic>{
                'nome': aparelho.nome,
                'tipo': aparelho.tipo,
                if (aparelho.fabricante.trim().isNotEmpty &&
                    aparelho.fabricante.toLowerCase() != 'não informado')
                  'marca': aparelho.fabricante,
                if (aparelho.modelo.trim().isNotEmpty &&
                    aparelho.modelo.toLowerCase() != 'não informado')
                  'modelo': aparelho.modelo,
              },
      );
      final textoResposta = '${resposta['resposta'] ?? ''}'.trim();
      if (textoResposta.isEmpty) {
        throw const ApiException(
          'O assistente não retornou uma resposta. Tente novamente.',
        );
      }

      if (!mounted) return;
      setState(() {
        _mensagensChat.add(
          _MensagemChat(texto: textoResposta, usuario: false),
        );
        _historicoChat.addAll(<Map<String, String>>[
          <String, String>{'papel': 'user', 'texto': pergunta},
          <String, String>{'papel': 'assistant', 'texto': textoResposta},
        ]);
        // O backend aceita as oito mensagens mais recentes.
        if (_historicoChat.length > 8) {
          _historicoChat.removeRange(0, _historicoChat.length - 8);
        }
      });
      _rolarChatParaFinal();
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _mensagensChat.add(
          _MensagemChat(
            texto: _mensagemErro(erro),
            usuario: false,
            erro: true,
          ),
        );
      });
      _rolarChatParaFinal();
    } finally {
      if (mounted) setState(() => _enviandoMensagem = false);
    }
  }

  void _rolarChatParaFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  double? _numeroOpcional(TextEditingController controller) {
    final texto = controller.text.trim().replaceAll(',', '.');
    if (texto.isEmpty) return null;
    return double.tryParse(texto);
  }

  String? _validarNumeroOpcional(
    String? valor, {
    double? minimo,
    double? maximo,
    bool inteiro = false,
  }) {
    final texto = (valor ?? '').trim().replaceAll(',', '.');
    if (texto.isEmpty) return null;
    final numero = double.tryParse(texto);
    if (numero == null) return 'Informe um número válido.';
    if (minimo != null && numero < minimo) {
      return 'O valor mínimo é ${_formatarNumero(minimo)}.';
    }
    if (maximo != null && numero > maximo) {
      return 'O valor máximo é ${_formatarNumero(maximo)}.';
    }
    if (inteiro && numero != numero.roundToDouble()) {
      return 'Informe um número inteiro.';
    }
    return null;
  }

  String _formatarNumero(num? valor, {int casas = 2}) {
    if (valor == null) return '—';
    return valor.toStringAsFixed(casas).replaceAll('.', ',');
  }

  Future<void> _estimarConsumo() async {
    FocusScope.of(context).unfocus();
    if (_estimandoConsumo ||
        !(_formEstimativaKey.currentState?.validate() ?? false)) {
      return;
    }

    final corpo = <String, dynamic>{
      'nome': _nomeEstimativaController.text.trim(),
      'tipo': _tipoEstimativaController.text.trim(),
      'quantidade': int.tryParse(_quantidadeController.text.trim()) ?? 1,
      'diasNoMes': int.tryParse(_diasController.text.trim()) ?? 30,
      if (_marcaEstimativaController.text.trim().isNotEmpty)
        'marca': _marcaEstimativaController.text.trim(),
      if (_modeloEstimativaController.text.trim().isNotEmpty)
        'modelo': _modeloEstimativaController.text.trim(),
      if (_numeroOpcional(_potenciaController) != null)
        'potenciaW': _numeroOpcional(_potenciaController),
      if (_numeroOpcional(_horasController) != null)
        'horasPorDia': _numeroOpcional(_horasController),
    };

    setState(() {
      _estimandoConsumo = true;
      _resultadoEstimativa = null;
    });

    try {
      final resultado = await IaApi.estimarConsumo(dados: corpo);
      if (!mounted) return;
      setState(() => _resultadoEstimativa = resultado);
    } catch (erro) {
      _mostrarMensagem(_mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _estimandoConsumo = false);
    }
  }

  Future<void> _analisarDispositivo() async {
    FocusScope.of(context).unfocus();
    if (_analisandoDispositivo ||
        !(_formAnomaliaKey.currentState?.validate() ?? false)) {
      return;
    }

    final aparelhos = AparelhosStore.aparelhos.value
        .where((aparelho) => aparelho.backendId.trim().isNotEmpty)
        .toList(growable: false);
    final selecionado = aparelhos.where(
      (aparelho) => aparelho.backendId == _aparelhoSelecionadoId,
    );
    if (selecionado.isEmpty) {
      _mostrarMensagem('Selecione um aparelho cadastrado na sua conta.');
      return;
    }

    if (_usarGraficoModelo && (_graficoModeloSelecionadoId == null || _graficoModeloSelecionadoId!.isEmpty)) {
      _mostrarMensagem('Crie ou selecione um gráfico modelo para continuar.');
      return;
    }

    final especificacoes = <String, dynamic>{
      if (_numeroOpcional(_potenciaNominalController) != null)
        'potenciaNominalW': _numeroOpcional(_potenciaNominalController),
      if (_numeroOpcional(_tensaoNominalController) != null)
        'tensaoNominalV': _numeroOpcional(_tensaoNominalController),
      if (_numeroOpcional(_correnteNominalController) != null)
        'correnteNominalA': _numeroOpcional(_correnteNominalController),
      if (_numeroOpcional(_consumoEsperadoController) != null)
        'consumoEsperadoWhPorMinuto':
            _numeroOpcional(_consumoEsperadoController),
      if (_descricaoUsoController.text.trim().isNotEmpty)
        'descricaoUso': _descricaoUsoController.text.trim(),
    };

    setState(() {
      _analisandoDispositivo = true;
      _resultadoAnomalia = null;
    });

    try {
      final resultado = await IaApi.analisarAnomalias(
        dispositivoId: selecionado.first.backendId,
        especificacoes: especificacoes,
        graficoModeloId: _usarGraficoModelo ? _graficoModeloSelecionadoId : null,
      );
      if (!mounted) return;
      setState(() => _resultadoAnomalia = resultado);
    } catch (erro) {
      _mostrarMensagem(_mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _analisandoDispositivo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente FHIVE'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _seletorSecao(),
              Expanded(child: _conteudoSelecionado()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seletorSecao() {
    const opcoes = <(String, IconData)>[
      ('Perguntas', Icons.help_outline_rounded),
      ('Chat IA', Icons.auto_awesome_rounded),
      ('Ferramentas', Icons.analytics_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          children: [
            for (var indice = 0; indice < opcoes.length; indice++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _botaoSecao(
                    indice: indice,
                    rotulo: opcoes[indice].$1,
                    icone: opcoes[indice].$2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _botaoSecao({
    required int indice,
    required String rotulo,
    required IconData icone,
  }) {
    final selecionado = _secaoSelecionada == indice;
    return Material(
      color: selecionado ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: () => setState(() => _secaoSelecionada = indice),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 19,
                color: selecionado ? AppColors.white : AppColors.primary,
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  rotulo,
                  style: AppTextStyles.caption.copyWith(
                    color: selecionado ? AppColors.white : AppColors.primary,
                    fontSize: 10,
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

  Widget _conteudoSelecionado() {
    return switch (_secaoSelecionada) {
      0 => _construirPerguntas(),
      1 => _construirChat(),
      _ => _construirFerramentas(),
    };
  }

  Widget _construirPerguntas() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.pageBottom,
      ),
      children: [
        const Text('Como podemos ajudar?', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Consulte as orientações rápidas ou converse com o assistente para tirar outras dúvidas sobre IoT e eletrodomésticos.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.section),
        for (final duvida in _duvidas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Material(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.card),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: Text(duvida.$1, style: AppTextStyles.bodyBold),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      duvida.$2,
                      style: AppTextStyles.body.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        _cartaoAcessoChat(),
      ],
    );
  }

  Widget _cartaoAcessoChat() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => setState(() => _secaoSelecionada = 1),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.white,
                size: 30,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Converse com a IA',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Envie sua própria pergunta ao Gemini.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirChat() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            0,
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Assistente Gemini',
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                ),
              ),
              if (_historicoChat.isNotEmpty)
                TextButton.icon(
                  onPressed: _enviandoMensagem
                      ? null
                      : () => setState(() {
                          _historicoChat.clear();
                          _mensagensChat.clear();
                        }),
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Nova conversa'),
                ),
            ],
          ),
        ),
        if (widget.aparelhoContexto != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              0,
              AppSpacing.pageHorizontal,
              AppSpacing.sm,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.devices_other_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dicas contextualizadas para',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          '${widget.aparelhoContexto!.nome} • ${widget.aparelhoContexto!.tipo}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: _mensagensChat.isEmpty
              ? _boasVindasChat()
              : ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                  ),
                  itemCount: _mensagensChat.length + (_enviandoMensagem ? 1 : 0),
                  itemBuilder: (context, indice) {
                    if (indice >= _mensagensChat.length) {
                      return const _BolhaDigitando();
                    }
                    return _BolhaMensagem(mensagem: _mensagensChat[indice]);
                  },
                ),
        ),
        _campoMensagem(),
      ],
    );
  }

  Widget _boasVindasChat() {
    const sugestoes = <String>[
      'Como posso monitorar o consumo de um aparelho com IoT?',
      'Quais cuidados devo ter com uma tomada inteligente?',
      'O que pode causar aumento no consumo de uma geladeira?',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: AppColors.surfaceStrong,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Olá! Sou o assistente do FHIVE.',
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Pergunte sobre IoT, eletrodomésticos, automação e consumo de energia. Escreva sua dúvida abaixo para conversar com o Gemini.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        const Text('Sugestões de perguntas', style: AppTextStyles.bodyBold),
        const SizedBox(height: AppSpacing.sm),
        for (final sugestao in sugestoes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.button),
                onTap: _enviandoMensagem ? null : () => _enviarPergunta(sugestao),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(sugestao, style: AppTextStyles.caption),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _campoMensagem() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          boxShadow: AppShadows.soft,
          border: Border(
            top: BorderSide(color: AppColors.primary.withValues(alpha: 0.10)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _mensagemController,
                minLines: 1,
                maxLines: 4,
                maxLength: 1800,
                enabled: !_enviandoMensagem,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviarPergunta(),
                decoration: const InputDecoration(
                  hintText: 'Pergunte ao assistente...',
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              tooltip: 'Enviar mensagem',
              onPressed: _enviandoMensagem ? null : _enviarPergunta,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.35),
              ),
              icon: _enviandoMensagem
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFerramentas() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.pageBottom,
      ),
      children: [
        const Text('Ferramentas inteligentes', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Estime o consumo de um eletrodoméstico ou peça ao Gemini para interpretar as telemetrias de um aparelho cadastrado.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _botaoFerramenta(
                indice: 0,
                titulo: 'Estimar consumo',
                icone: Icons.bolt_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _botaoFerramenta(
                indice: 1,
                titulo: 'Analisar aparelho',
                icone: Icons.health_and_safety_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_ferramentaSelecionada == 0)
          _formularioEstimativa()
        else
          _formularioAnomalia(),
      ],
    );
  }

  Widget _botaoFerramenta({
    required int indice,
    required String titulo,
    required IconData icone,
  }) {
    final selecionado = _ferramentaSelecionada == indice;
    return Material(
      color: selecionado ? AppColors.primary : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: () => setState(() => _ferramentaSelecionada = indice),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 5),
          child: Column(
            children: [
              Icon(
                icone,
                color: selecionado ? AppColors.white : AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: selecionado ? AppColors.white : AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formularioEstimativa() {
    return Form(
      key: _formEstimativaKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cartaoFormulario(
            titulo: 'Dados do aparelho',
            subtitulo: 'Informe os dados conhecidos. O Gemini tentará estimar os campos que ficarem em branco.',
            children: [
              _campoFormulario(
                controller: _nomeEstimativaController,
                label: 'Nome do aparelho *',
                hint: 'Ex.: Ventilador',
                validator: (valor) => (valor ?? '').trim().isEmpty
                    ? 'Informe o nome do aparelho.'
                    : null,
              ),
              _campoFormulario(
                controller: _tipoEstimativaController,
                label: 'Tipo de aparelho',
                hint: 'Ex.: Ventilador doméstico',
              ),
              _campoFormulario(
                controller: _marcaEstimativaController,
                label: 'Marca (opcional)',
              ),
              _campoFormulario(
                controller: _modeloEstimativaController,
                label: 'Modelo (opcional)',
              ),
              _campoFormulario(
                controller: _potenciaController,
                label: 'Potência em watts (opcional)',
                hint: 'Ex.: 75',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) => _validarNumeroOpcional(
                  valor,
                  minimo: 0.1,
                  maximo: 100000,
                ),
              ),
              _campoFormulario(
                controller: _horasController,
                label: 'Horas de uso por dia (opcional)',
                hint: 'De 0,1 até 24 horas',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) => _validarNumeroOpcional(
                  valor,
                  minimo: 0.1,
                  maximo: 24,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _campoFormulario(
                      controller: _quantidadeController,
                      label: 'Quantidade',
                      teclado: TextInputType.number,
                      validator: (valor) => _validarNumeroOpcional(
                        valor,
                        minimo: 1,
                        maximo: 100,
                        inteiro: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _campoFormulario(
                      controller: _diasController,
                      label: 'Dias no mês',
                      teclado: TextInputType.number,
                      validator: (valor) => _validarNumeroOpcional(
                        valor,
                        minimo: 1,
                        maximo: 31,
                        inteiro: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _estimandoConsumo ? null : _estimarConsumo,
                  icon: _estimandoConsumo
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _estimandoConsumo ? 'Calculando...' : 'Estimar consumo',
                  ),
                ),
              ),
            ],
          ),
          if (_resultadoEstimativa != null) ...[
            const SizedBox(height: AppSpacing.md),
            _resultadoEstimativaWidget(_resultadoEstimativa!),
          ],
        ],
      ),
    );
  }

  Widget _formularioAnomalia() {
    return Form(
      key: _formAnomaliaKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cartaoFormulario(
            titulo: 'Selecionar aparelho',
            subtitulo: 'O FHIVE consultará as telemetrias registradas para o aparelho selecionado.',
            children: [
              _seletorAparelho(),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _usarGraficoModelo,
                onChanged: (valor) {
                  setState(() {
                    _usarGraficoModelo = valor;
                    _resultadoAnomalia = null;
                  });
                  final id = _aparelhoSelecionadoId;
                  if (valor && id != null) _carregarGraficosModelo(id);
                },
                title: const Text('Analisar um gráfico modelo'),
                subtitle: const Text(
                  'Usa dados artificiais salvos para testar a análise. Não representa medições reais.',
                  style: AppTextStyles.caption,
                ),
                activeColor: AppColors.primary,
              ),
              if (_usarGraficoModelo) _seletorGraficoModelo(),
              _campoFormulario(
                controller: _potenciaNominalController,
                label: 'Potência nominal em watts (opcional)',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) => _validarNumeroOpcional(
                  valor,
                  minimo: 0.1,
                  maximo: 100000,
                ),
              ),
              _campoFormulario(
                controller: _tensaoNominalController,
                label: 'Tensão nominal em volts (opcional)',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) => _validarNumeroOpcional(
                  valor,
                  minimo: 1,
                  maximo: 1000,
                ),
              ),
              _campoFormulario(
                controller: _correnteNominalController,
                label: 'Corrente nominal em ampères (opcional)',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) => _validarNumeroOpcional(
                  valor,
                  minimo: 0.01,
                  maximo: 1000,
                ),
              ),
              _campoFormulario(
                controller: _consumoEsperadoController,
                label: 'Consumo esperado em Wh/min (opcional)',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) => _validarNumeroOpcional(
                  valor,
                  minimo: 0,
                  maximo: 100000,
                ),
              ),
              _campoFormulario(
                controller: _descricaoUsoController,
                label: 'Descrição de uso (opcional)',
                hint: 'Ex.: utilizado diariamente durante a noite',
                maxLines: 3,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _analisandoDispositivo ||
                          _carregandoAparelhos ||
                          (_usarGraficoModelo && _carregandoGraficosModelo) ||
                          _aparelhosDisponiveis.isEmpty
                      ? null
                      : _analisarDispositivo,
                  icon: _analisandoDispositivo
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    _analisandoDispositivo
                        ? 'Analisando telemetrias...'
                        : 'Analisar aparelho com IA',
                  ),
                ),
              ),
            ],
          ),
          if (_resultadoAnomalia != null) ...[
            const SizedBox(height: AppSpacing.md),
            _resultadoAnomaliaWidget(_resultadoAnomalia!),
          ],
        ],
      ),
    );
  }

  List<AparelhoItem> get _aparelhosDisponiveis =>
      AparelhosStore.aparelhos.value
          .where((aparelho) => aparelho.backendId.trim().isNotEmpty)
          .toList(growable: false);

  Widget _seletorGraficoModelo() {
    if (_carregandoGraficosModelo) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_graficosModelo.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0B8),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: const Text(
          'Este aparelho ainda não possui gráficos modelo. Acesse Gráficos, toque no + da seção Gráficos modelo e crie um conjunto de dados de teste.',
          style: AppTextStyles.caption,
        ),
      );
    }

    final existe = _graficosModelo.any(
      (item) => '${item['id']}' == _graficoModeloSelecionadoId,
    );
    final valorSelecionado = existe
        ? _graficoModeloSelecionadoId
        : '${_graficosModelo.first['id']}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DropdownButtonFormField<String>(
        value: valorSelecionado,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Gráfico modelo para análise'),
        items: _graficosModelo.map((grafico) {
          final leituras = grafico['leituras'] is List
              ? (grafico['leituras'] as List).length
              : grafico['minutoAtual'] ?? 0;
          return DropdownMenuItem<String>(
            value: '${grafico['id']}',
            child: Text(
              '${grafico['nome'] ?? 'Gráfico modelo'} • $leituras leituras',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(growable: false),
        onChanged: (valor) => setState(() {
          _graficoModeloSelecionadoId = valor;
          _resultadoAnomalia = null;
        }),
      ),
    );
  }

  Widget _seletorAparelho() {
    if (_carregandoAparelhos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_aparelhosDisponiveis.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _erroCarregamentoAparelhos ??
                  'Nenhum aparelho cadastrado foi encontrado na sua conta.',
              style: AppTextStyles.caption,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _carregandoAparelhos ? null : _carregarAparelhos,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Atualizar aparelhos'),
              ),
            ),
          ],
        ),
      );
    }

    final selecionadoExiste = _aparelhosDisponiveis.any(
      (aparelho) => aparelho.backendId == _aparelhoSelecionadoId,
    );
    final valorSelecionado = selecionadoExiste
        ? _aparelhoSelecionadoId
        : _aparelhosDisponiveis.first.backendId;
    if (_aparelhoSelecionadoId != valorSelecionado) {
      _aparelhoSelecionadoId = valorSelecionado;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: valorSelecionado,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Aparelho da sua conta',
          ),
          items: _aparelhosDisponiveis
              .map(
                (aparelho) => DropdownMenuItem<String>(
                  value: aparelho.backendId,
                  child: Text(
                    '${aparelho.nome} • ${aparelho.tipo}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (valor) {
            setState(() {
              _aparelhoSelecionadoId = valor;
              _graficoModeloSelecionadoId = null;
              _graficosModelo = <Map<String, dynamic>>[];
              _resultadoAnomalia = null;
            });
            if (valor != null) _carregarGraficosModelo(valor);
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'A análise usa o ID interno do aparelho e busca as telemetrias no backend. Não é necessário informar o ID MQTT.',
          style: AppTextStyles.caption,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _carregandoAparelhos ? null : _carregarAparelhos,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Atualizar lista'),
          ),
        ),
      ],
    );
  }

  Widget _campoFormulario({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? teclado,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        validator: validator,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: teclado == TextInputType.number
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Widget _cartaoFormulario({
    required String titulo,
    required String subtitulo,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitulo, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _resultadoEstimativaWidget(Map<String, dynamic> resultado) {
    final faixa = resultado['faixaMensalKwh'] is Map
        ? (resultado['faixaMensalKwh'] as Map)
        : const <String, dynamic>{};
    final premissas = resultado['premissas'] is List
        ? (resultado['premissas'] as List)
        : const <dynamic>[];
    final confianca = '${resultado['confianca'] ?? 'baixa'}';
    final origem = resultado['origem'] == 'estimativa_gemini'
        ? 'Estimativa gerada com apoio do Gemini'
        : 'Cálculo com os dados informados';

    return _cartaoResultado(
      titulo: 'Resultado da estimativa',
      icone: Icons.bolt_rounded,
      children: [
        Text(origem, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${_formatarNumero(resultado['consumoEstimadoKwhMes'] as num?)} kWh/mês',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 23),
        ),
        const SizedBox(height: AppSpacing.sm),
        _linhaResultado(
          'Potência considerada',
          '${_formatarNumero(resultado['potenciaConsideradaW'] as num?)} W',
        ),
        _linhaResultado(
          'Uso diário',
          '${_formatarNumero(resultado['horasUsoPorDia'] as num?)} horas',
        ),
        _linhaResultado(
          'Consumo diário',
          '${_formatarNumero(resultado['consumoEstimadoKwhDia'] as num?)} kWh',
        ),
        _linhaResultado(
          'Faixa mensal',
          '${_formatarNumero(faixa['minimo'] as num?)} – ${_formatarNumero(faixa['maximo'] as num?)} kWh',
        ),
        _linhaResultado('Confiança', confianca.toUpperCase()),
        if (premissas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Premissas utilizadas', style: AppTextStyles.bodyBold),
          const SizedBox(height: AppSpacing.xs),
          for (final premissa in premissas)
            _itemTextoResultado('$premissa'),
        ],
        if ('${resultado['observacao'] ?? ''}'.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('${resultado['observacao']}', style: AppTextStyles.caption),
        ],
      ],
    );
  }

  Widget _resultadoAnomaliaWidget(Map<String, dynamic> resultado) {
    final status = '${resultado['status'] ?? 'dados_insuficientes'}';
    final corStatus = switch (status) {
      'normal' => AppColors.success,
      'atencao' => AppColors.warning,
      'anomalia' => AppColors.danger,
      _ => AppColors.primaryDark,
    };
    final anomalias = resultado['anomalias'] is List
        ? (resultado['anomalias'] as List)
        : const <dynamic>[];
    final causas = resultado['possiveisCausas'] is List
        ? (resultado['possiveisCausas'] as List)
        : const <dynamic>[];
    final recomendacoes = resultado['recomendacoes'] is List
        ? (resultado['recomendacoes'] as List)
        : const <dynamic>[];
    final dados = resultado['dadosAnalisados'] is Map
        ? (resultado['dadosAnalisados'] as Map)
        : const <String, dynamic>{};

    return _cartaoResultado(
      titulo: 'Resultado da análise',
      icone: Icons.health_and_safety_outlined,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: corStatus.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            _rotuloStatus(status),
            style: AppTextStyles.bodyBold.copyWith(color: corStatus),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: resultado['origemDados'] == 'modelo_artificial'
                ? const Color(0xFFFFF0B8)
                : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            resultado['origemDados'] == 'modelo_artificial'
                ? 'ANÁLISE COM DADOS SIMULADOS'
                : 'ANÁLISE COM TELEMETRIA REAL',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${resultado['resumo'] ?? 'Não foi possível gerar um resumo.'}',
          style: AppTextStyles.body.copyWith(height: 1.4),
        ),
        const SizedBox(height: AppSpacing.md),
        _linhaResultado(
          'Leituras analisadas',
          '${dados['quantidadeLeituras'] ?? 0}',
        ),
        _linhaResultado(
          'Sessões consultadas',
          '${dados['sessoesConsultadas'] ?? 0}',
        ),
        _linhaResultado(
          'Confiança',
          '${resultado['confianca'] ?? 'baixa'}'.toUpperCase(),
        ),
        if (anomalias.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Possíveis anormalidades', style: AppTextStyles.bodyBold),
          const SizedBox(height: AppSpacing.xs),
          for (final item in anomalias)
            if (item is Map) _cartaoAnomalia(item),
        ],
        if (causas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Possíveis causas', style: AppTextStyles.bodyBold),
          for (final causa in causas) _itemTextoResultado('$causa'),
        ],
        if (recomendacoes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Recomendações', style: AppTextStyles.bodyBold),
          for (final recomendacao in recomendacoes)
            _itemTextoResultado('$recomendacao'),
        ],
        if ('${resultado['limitacoes'] ?? ''}'.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Limitações', style: AppTextStyles.bodyBold),
          Text('${resultado['limitacoes']}', style: AppTextStyles.caption),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          '${resultado['aviso'] ?? 'A análise é automatizada e não substitui um diagnóstico técnico.'}',
          style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  String _rotuloStatus(String status) => switch (status) {
    'normal' => 'Comportamento aparentemente normal',
    'atencao' => 'Ponto de atenção identificado',
    'anomalia' => 'Possível anormalidade identificada',
    _ => 'Dados insuficientes para concluir',
  };

  Widget _cartaoAnomalia(Map item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${item['indicador'] ?? 'Indicador'}', style: AppTextStyles.bodyBold),
          const SizedBox(height: 3),
          Text(
            'Observado: ${item['observado'] ?? '—'}',
            style: AppTextStyles.caption,
          ),
          Text(
            'Referência: ${item['referencia'] ?? 'Não informada'}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${item['explicacao'] ?? ''}',
            style: AppTextStyles.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _cartaoResultado({
    required String titulo,
    required IconData icone,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 21),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(titulo, style: AppTextStyles.cardTitle)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _linhaResultado(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(rotulo, style: AppTextStyles.caption)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTextoResultado(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: AppTextStyles.bodyBold),
          Expanded(child: Text(texto, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}

class _MensagemChat {
  final String texto;
  final bool usuario;
  final bool erro;

  const _MensagemChat({
    required this.texto,
    required this.usuario,
    this.erro = false,
  });
}

class _BolhaMensagem extends StatelessWidget {
  final _MensagemChat mensagem;

  const _BolhaMensagem({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final alinhamento = mensagem.usuario
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final cor = mensagem.usuario
        ? AppColors.primary
        : AppColors.surfaceLight;
    final corTexto = mensagem.usuario
        ? AppColors.white
        : mensagem.erro
            ? AppColors.danger
            : AppColors.primary;

    return Align(
      alignment: alinhamento,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.84,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.card),
            topRight: const Radius.circular(AppRadius.card),
            bottomLeft: Radius.circular(mensagem.usuario ? AppRadius.card : 4),
            bottomRight: Radius.circular(mensagem.usuario ? 4 : AppRadius.card),
          ),
          boxShadow: AppShadows.soft,
        ),
        child: SelectableText(
          mensagem.texto,
          textAlign: mensagem.usuario || mensagem.erro
              ? TextAlign.start
              : TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: corTexto,
            fontSize: mensagem.usuario ? 14 : 16,
            height: 1.5,
            fontWeight: mensagem.usuario ? FontWeight.normal : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BolhaDigitando extends StatelessWidget {
  const _BolhaDigitando();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppSpacing.sm),
            Text('Gemini está respondendo...', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
