import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/features/analytics/presentation/graficos.dart';

class TelaDetalhesAparelho extends StatefulWidget {
  final String nome;
  final String id;
  final String backendId;
  final String tipo;
  final String fabricante;
  final String modelo;
  final String local;
  final String conexao;
  final String status;
  final IconData icone;

  const TelaDetalhesAparelho({
    super.key,
    this.nome = 'Ar condicionado',
    this.id = 'FH-AC-SALA-001',
    this.backendId = '',
    this.tipo = 'Ar condicionado',
    this.fabricante = 'Não informado',
    this.modelo = 'Não informado',
    this.local = 'Sala de Estar',
    this.conexao = 'Wi-Fi',
    this.status = 'Offline',
    this.icone = Icons.air,
  });

  @override
  State<TelaDetalhesAparelho> createState() => _TelaDetalhesAparelhoState();
}

class _TelaDetalhesAparelhoState extends State<TelaDetalhesAparelho> {
  static const Color marrom = AppColors.primary;
  static const Color amareloCard = Color(0xFFFFF49F);
  static const Color amareloBotao = Color(0xFFFFEF73);

  bool ligado = false;
  bool modoSono = false;
  bool modoEconomico = false;
  bool mudo = false;
  bool privacidade = false;
  bool deteccaoMovimento = true;
  bool gravacao = false;
  bool temporizador = false;
  bool monitoramento = true;
  bool notificacoes = true;
  bool alerta = true;
  bool controleRemoto = false;

  double temperatura = 22;
  double volume = 35;
  double brilho = 70;
  double brilhoLampada = 76;
  double temperaturaCor = 50;

  int velocidadeVentilador = 2;
  int canalAtual = 12;
  String modoImagem = 'Padrão';
  String modoAr = 'Frio';
  String cenaLampada = 'Relaxar';
  final List<String> _presetsArPersonalizados = <String>[];
  final List<String> _cenasPersonalizadas = <String>[];
  final List<String> _servicosPersonalizados = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                  child: _painelPrincipal(),
                ),
              ),
              const BarraNavegacao(itemSelecionado: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _painelPrincipal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBCB),
        borderRadius: BorderRadius.circular(29),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalhoAparelho(),
          const SizedBox(height: 14),
          _conteudoPorTipo(),
          const SizedBox(height: 18),
          _rodapeIdentificacao(),
        ],
      ),
    );
  }

  Widget _cabecalhoAparelho() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.arrow_back_ios_new, color: marrom, size: 20),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.tipo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: marrom.withValues(alpha: 0.72),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: amareloBotao,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icone, color: marrom, size: 25),
        ),
        const SizedBox(width: 2),
        ValueListenableBuilder<Set<String>>(
          valueListenable: AparelhosStore.favoritos,
          builder: (context, favoritos, _) {
            final cadastrado = AparelhosStore.porId(widget.id) != null;
            final favorito = favoritos.contains(widget.id);
            return IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
              tooltip: favorito
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              onPressed: () {
                if (!cadastrado) {
                  _mensagem(
                    'Cadastre este aparelho para adicioná-lo aos favoritos.',
                  );
                  return;
                }
                AparelhosStore.alternarFavorito(widget.id);
                _mensagem(
                  favorito
                      ? 'Removido dos favoritos.'
                      : 'Adicionado aos favoritos.',
                );
              },
              icon: Icon(
                favorito ? Icons.star_rounded : Icons.star_border_rounded,
                color: marrom,
                size: 23,
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          tooltip: 'Mais opções',
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert_rounded, color: marrom, size: 23),
          onSelected: (acao) {
            if (acao == 'informacoes') _mostrarInformacoes();
            if (acao == 'remover') _confirmarRemocao();
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              key: ValueKey<String>('menu-informacoes-aparelho'),
              value: 'informacoes',
              child: Text('Informações do aparelho'),
            ),
            if (AparelhosStore.porId(widget.id) != null)
              const PopupMenuItem<String>(
                value: 'remover',
                child: Text('Remover aparelho'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _conteudoPorTipo() {
    switch (widget.tipo) {
      case 'TV':
        return _conteudoTV();
      case 'Ar condicionado':
        return _conteudoAr();
      case 'Lâmpada':
        return _conteudoLampada();
      case 'Câmera':
        return _conteudoCamera();
      case 'Tomada inteligente':
        return _conteudoTomada();
      case 'Sensor':
        return _conteudoSensor();
      default:
        return _conteudoGenerico();
    }
  }

  Widget _conteudoTV() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF3A0), Color(0xFFFFE05C)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.largeCard),
            border: Border.all(color: marrom.withValues(alpha: 0.09)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(Icons.tv_rounded, color: marrom, size: 35),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: marrom,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.local,
                          style: TextStyle(
                            color: marrom.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: ligado
                                ? const Color(0xFFD8F0C1)
                                : AppColors.surfaceLight.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                ligado ? Icons.check_circle : Icons.power_settings_new,
                                size: 13,
                                color: ligado ? const Color(0xFF3B7629) : marrom,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ligado ? 'Ligada' : 'Desligada',
                                style: const TextStyle(
                                  color: marrom,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Material(
                    color: marrom,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: ligado ? 'Desligar TV' : 'Ligar TV',
                      onPressed: () => setState(() => ligado = !ligado),
                      icon: Icon(
                        ligado ? Icons.power_settings_new_rounded : Icons.power_settings_new,
                        color: AppColors.white,
                        size: 29,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => ligado = !ligado),
                  icon: Icon(ligado ? Icons.power_off_rounded : Icons.power_rounded),
                  label: Text(ligado ? 'Desligar TV' : 'Ligar TV'),
                  style: FilledButton.styleFrom(
                    backgroundColor: marrom,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Controles rápidos',
          style: TextStyle(color: marrom, fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        _linhaSlider(
          titulo: 'Volume',
          valor: volume,
          min: 0,
          max: 100,
          textoValor: '${volume.round()}%',
          iconeFinal: Icons.volume_up_rounded,
          onChanged: (valor) => setState(() => volume = valor),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: amareloCard,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.live_tv_rounded, color: marrom, size: 23),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Canal',
                  style: TextStyle(color: marrom, fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => canalAtual = (canalAtual - 1).clamp(1, 999)),
                icon: const Icon(Icons.remove_rounded),
                style: IconButton.styleFrom(foregroundColor: marrom, backgroundColor: AppColors.surfaceLight),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Text('$canalAtual', style: const TextStyle(color: marrom, fontSize: 17, fontWeight: FontWeight.w900)),
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => canalAtual = (canalAtual + 1).clamp(1, 999)),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(foregroundColor: marrom, backgroundColor: AppColors.surfaceLight),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _linhaSwitch(
          'Desligamento automático',
          temporizador,
          Icons.timer_outlined,
          (valor) => setState(() => temporizador = valor),
        ),
        _linhaSwitch(
          'Controle remoto',
          controleRemoto,
          Icons.settings_remote_outlined,
          (valor) => setState(() => controleRemoto = valor),
        ),
        const SizedBox(height: 12),
        const Text(
          'Modo de imagem',
          style: TextStyle(color: marrom, fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: ['Padrão', 'Cinema', 'Jogo'].map((modo) {
            final selecionado = modoImagem == modo;
            return ChoiceChip(
              avatar: Icon(
                modo == 'Cinema' ? Icons.movie_outlined : modo == 'Jogo' ? Icons.sports_esports_outlined : Icons.tune_rounded,
                size: 17,
                color: marrom,
              ),
              label: Text(modo),
              selected: selecionado,
              onSelected: (_) => setState(() => modoImagem = modo),
              selectedColor: amareloBotao,
              backgroundColor: amareloCard,
              labelStyle: const TextStyle(color: marrom, fontWeight: FontWeight.w800, fontSize: 12),
              side: BorderSide(color: marrom.withValues(alpha: 0.12)),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _atalhosRapidosTV(),
        const SizedBox(height: 18),
        _linkTitulo('Ver gráficos deste aparelho', _abrirGraficos),
        const SizedBox(height: 20),
        const Text(
          'Aplicativos de streaming',
          style: TextStyle(color: marrom, fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        _streamingGrid(),
        const SizedBox(height: 6),
        Text(
          'Os comandos são demonstrativos nesta versão. O controle físico será conectado futuramente ao serviço IoT.',
          style: TextStyle(color: marrom.withValues(alpha: 0.7), fontSize: 10.5, height: 1.3),
        ),
      ],
    );
  }

  Widget _atalhosRapidosTV() {
    const comandos = <String, IconData>{
      'Ligar TV': Icons.power_settings_new_rounded,
      'Desligar TV': Icons.power_off_rounded,
      'Aumentar volume': Icons.volume_up_rounded,
      'Diminuir volume': Icons.volume_down_rounded,
      'Silenciar': Icons.volume_off_rounded,
      'Canal +': Icons.add_circle_outline_rounded,
      'Canal -': Icons.remove_circle_outline_rounded,
      'Modo Cinema': Icons.movie_outlined,
      'Modo Jogo': Icons.sports_esports_outlined,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Atalhos rápidos',
                style: TextStyle(color: marrom, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton.icon(
              onPressed: _adicionarAtalhoTV,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Adicionar'),
              style: TextButton.styleFrom(foregroundColor: marrom),
            ),
          ],
        ),
        ValueListenableBuilder<List<AtalhoAparelho>>(
          valueListenable: AparelhosStore.atalhos,
          builder: (context, todosAtalhos, _) {
            final atalhos = todosAtalhos.where((item) => item.aparelhoId == widget.id).toList();
            if (atalhos.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: amareloCard,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: marrom.withValues(alpha: 0.08)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: marrom, size: 25),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Crie um atalho para executar seus comandos favoritos em um toque.',
                        style: TextStyle(color: marrom, fontSize: 11.5, height: 1.3, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: atalhos.map((atalho) {
                return SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 84) / 2,
                  child: Material(
                    color: amareloCard,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      onTap: () => _executarAtalhoTV(atalho.comando),
                      onLongPress: () => _removerAtalhoTV(atalho.id),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(11, 10, 7, 10),
                        child: Row(
                          children: [
                            Icon(comandos[atalho.comando] ?? atalho.icone, color: marrom, size: 22),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                atalho.nome,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: marrom, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _adicionarAtalhoTV() async {
    final nomeController = TextEditingController();
    const comandos = <String, IconData>{
      'Ligar TV': Icons.power_settings_new_rounded,
      'Desligar TV': Icons.power_off_rounded,
      'Aumentar volume': Icons.volume_up_rounded,
      'Diminuir volume': Icons.volume_down_rounded,
      'Silenciar': Icons.volume_off_rounded,
      'Canal +': Icons.add_circle_outline_rounded,
      'Canal -': Icons.remove_circle_outline_rounded,
      'Modo Cinema': Icons.movie_outlined,
      'Modo Jogo': Icons.sports_esports_outlined,
    };
    var comandoSelecionado = 'Ligar TV';
    final dados = await showDialog<(String, String)?>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar atalho'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome do atalho',
                  hintText: 'Ex.: Noite de cinema',
                  prefixIcon: Icon(Icons.bolt_rounded),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: comandoSelecionado,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Comando'),
                items: comandos.keys.map((comando) => DropdownMenuItem<String>(
                  value: comando,
                  child: Text(comando, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (valor) {
                  if (valor != null) setDialogState(() => comandoSelecionado = valor);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                (nomeController.text.trim(), comandoSelecionado),
              ),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
    nomeController.dispose();
    if (!mounted || dados == null) return;
    if (dados.$1.isEmpty) {
      _mensagem('Informe um nome para o atalho.');
      return;
    }
    final adicionado = AparelhosStore.adicionarAtalho(
      aparelhoId: widget.id,
      nome: dados.$1,
      comando: dados.$2,
      icone: comandos[dados.$2] ?? Icons.bolt_rounded,
    );
    if (!adicionado) {
      _mensagem('Já existe um atalho com esse nome ou o aparelho não está cadastrado.');
      return;
    }
    _mensagem('Atalho "${dados.$1}" adicionado. Toque nele para executar; mantenha pressionado para remover.');
  }

  void _executarAtalhoTV(String comando) {
    setState(() {
      switch (comando) {
        case 'Ligar TV':
          ligado = true;
          break;
        case 'Desligar TV':
          ligado = false;
          break;
        case 'Aumentar volume':
          volume = (volume + 5).clamp(0, 100).toDouble();
          break;
        case 'Diminuir volume':
          volume = (volume - 5).clamp(0, 100).toDouble();
          break;
        case 'Silenciar':
          mudo = !mudo;
          break;
        case 'Canal +':
          canalAtual = (canalAtual + 1).clamp(1, 999);
          break;
        case 'Canal -':
          canalAtual = (canalAtual - 1).clamp(1, 999);
          break;
        case 'Modo Cinema':
          modoImagem = 'Cinema';
          break;
        case 'Modo Jogo':
          modoImagem = 'Jogo';
          break;
      }
    });
    _mensagem('Atalho executado: $comando. A ação é local nesta versão de demonstração.');
  }

  Future<void> _removerAtalhoTV(String id) async {
    final remover = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover atalho?'),
        content: const Text('Esse atalho será removido da lista deste aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Remover')),
        ],
      ),
    );
    if (!mounted || remover != true) return;
    AparelhosStore.removerAtalho(id);
    _mensagem('Atalho removido.');
  }

  Widget _conteudoAr() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        _linhaSlider(
          titulo: 'Temperatura',
          valor: temperatura,
          min: 16,
          max: 30,
          textoValor: '${temperatura.round()}°C',
          iconeFinal: Icons.thermostat_auto_outlined,
          onChanged: (valor) => setState(() => temperatura = valor),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _botaoOpcao(
                icon: Icons.power_settings_new_rounded,
                label: 'Desligamento\nAutomático',
                ativo: temporizador,
                onTap: () => setState(() => temporizador = !temporizador),
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              child: _botaoOpcao(
                icon: Icons.speed_rounded,
                label: 'Velocidade do\nventilador',
                onTap: () => setState(
                  () => velocidadeVentilador = velocidadeVentilador == 4
                      ? 1
                      : velocidadeVentilador + 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _botaoOpcao(
                icon: Icons.air_rounded,
                label: 'Modo\nEconômico',
                ativo: modoEconomico,
                onTap: () => setState(() => modoEconomico = !modoEconomico),
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              child: _botaoOpcao(
                icon: Icons.nightlight_round,
                label: 'Modo sono',
                ativo: modoSono,
                onTap: () => setState(() => modoSono = !modoSono),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _linkTitulo('Gráficos', _abrirGraficos),
        const SizedBox(height: 13),
        const Text(
          'Pré-configurações',
          style: TextStyle(
            color: marrom,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _preset('Frio', modoAr == 'Frio'),
            _preset('Calor', modoAr == 'Calor'),
            for (final preset in _presetsArPersonalizados)
              _preset(preset, modoAr == preset),
            _preset('+', false, icon: Icons.add, largura: 68),
          ],
        ),
      ],
    );
  }

  Widget _conteudoLampada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        _linhaSlider(
          titulo: 'Brilho',
          valor: brilhoLampada,
          min: 1,
          max: 100,
          textoValor: '${brilhoLampada.round()}%',
          iconeFinal: Icons.light_mode_outlined,
          onChanged: (valor) => setState(() => brilhoLampada = valor),
        ),
        _linhaSlider(
          titulo: 'Temperatura da cor',
          valor: temperaturaCor,
          min: 0,
          max: 100,
          textoValor: temperaturaCor < 45
              ? 'Quente'
              : temperaturaCor > 65
              ? 'Fria'
              : 'Neutra',
          iconeFinal: Icons.palette_outlined,
          onChanged: (valor) => setState(() => temperaturaCor = valor),
        ),
        _linkTitulo('Cenas', _abrirCenas),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final cena in <String>[
              'Relaxar',
              'Leitura',
              'Filme',
              ..._cenasPersonalizadas,
            ])
              _preset(cena, cena == cenaLampada),
            _preset('+', false, icon: Icons.add, largura: 68),
          ],
        ),
      ],
    );
  }

  Widget _conteudoCamera() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBanner(
          Icons.videocam_outlined,
          'Visualização disponível quando a integração de vídeo estiver ativa.',
        ),
        const SizedBox(height: 14),
        _linhaSwitch(
          'Privacidade',
          privacidade,
          Icons.visibility_off_outlined,
          (valor) => setState(() => privacidade = valor),
        ),
        _linhaSwitch(
          'Detecção de movimento',
          deteccaoMovimento,
          Icons.directions_run_rounded,
          (valor) => setState(() => deteccaoMovimento = valor),
        ),
        _linhaSwitch(
          'Gravação',
          gravacao,
          Icons.fiber_manual_record_outlined,
          (valor) => setState(() => gravacao = valor),
        ),
        _linkTitulo('Gráficos', _abrirGraficos),
      ],
    );
  }

  Widget _conteudoTomada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _indicador('Potência', '184 W', Icons.bolt_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _indicador('Hoje', '1,8 kWh', Icons.bar_chart_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _linhaSwitch(
          'Temporizador',
          temporizador,
          Icons.timer_outlined,
          (valor) => setState(() => temporizador = valor),
        ),
        _linhaSwitch(
          'Economia de energia',
          modoEconomico,
          Icons.eco_outlined,
          (valor) => setState(() => modoEconomico = valor),
        ),
      ],
    );
  }

  Widget _conteudoSensor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _indicador(
                'Temperatura',
                '23°C',
                Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _indicador('Umidade', '58%', Icons.water_drop_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _linhaSwitch(
          'Monitoramento ativo',
          monitoramento,
          Icons.sensors_outlined,
          (valor) => setState(() => monitoramento = valor),
        ),
        _linhaSwitch(
          'Notificar alterações',
          notificacoes,
          Icons.notifications_none_outlined,
          (valor) => setState(() => notificacoes = valor),
        ),
        _linhaSwitch(
          'Alertas de limite',
          alerta,
          Icons.warning_amber_outlined,
          (valor) => setState(() => alerta = valor),
        ),
      ],
    );
  }

  Widget _conteudoGenerico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        _linhaSwitch(
          'Notificações',
          notificacoes,
          Icons.notifications_none_outlined,
          (valor) => setState(() => notificacoes = valor),
        ),
        _linkTitulo('Gráficos', _abrirGraficos),
      ],
    );
  }

  Widget _linhaSwitch(
    String titulo,
    bool valor,
    IconData icone,
    ValueChanged<bool> onChanged,
  ) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: marrom,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch.adaptive(
            value: valor,
            onChanged: onChanged,
            activeThumbColor: marrom,
            activeTrackColor: amareloBotao,
            inactiveThumbColor: marrom,
            inactiveTrackColor: const Color(0xFF7E3C03),
          ),
        ],
      ),
    );
  }

  Widget _linhaSlider({
    required String titulo,
    required double valor,
    required double min,
    required double max,
    required String textoValor,
    required IconData iconeFinal,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            titulo,
            style: const TextStyle(
              color: marrom,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: marrom,
              inactiveTrackColor: marrom.withValues(alpha: 0.18),
              thumbColor: marrom,
              overlayColor: marrom.withValues(alpha: 0.10),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              min: min,
              max: max,
              value: valor.clamp(min, max).toDouble(),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            textoValor,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: marrom,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Icon(iconeFinal, color: marrom, size: 21),
      ],
    );
  }

  Widget _botaoOpcao({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool ativo = false,
  }) {
    return Material(
      color: ativo ? amareloBotao : amareloCard,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: marrom, size: 37),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preset(
    String texto,
    bool ativo, {
    IconData? icon,
    double largura = 68,
  }) {
    return Material(
      color: ativo ? amareloBotao : amareloCard,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          if (texto == '+') {
            _adicionarPreConfiguracao();
            return;
          }
          if (widget.tipo == 'Ar condicionado') {
            setState(() => modoAr = texto);
          } else if (widget.tipo == 'Lâmpada') {
            setState(() => cenaLampada = texto);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: largura,
          height: 68,
          child: Center(
            child: icon != null
                ? Icon(icon, color: marrom, size: 36)
                : Text(
                    texto,
                    style: const TextStyle(
                      color: marrom,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _linkTitulo(String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        texto,
        style: const TextStyle(
          color: marrom,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.underline,
          decorationThickness: 1.3,
        ),
      ),
    );
  }

  Widget _streamingGrid() {
    final itens = <(String, Color, IconData)>[
      ('Twitch', const Color(0xFF9146FF), Icons.chat_bubble_outline_rounded),
      ('Disney+', const Color(0xFF071A5B), Icons.movie_creation_outlined),
      ('Prime', const Color(0xFF20A6F5), Icons.play_arrow_rounded),
      ('YouTube', const Color(0xFFFF1F19), Icons.play_arrow_rounded),
      ('Netflix', Colors.black, Icons.movie_outlined),
      for (final nome in _servicosPersonalizados)
        (nome, marrom, Icons.apps_outlined),
      ('+', amareloBotao, Icons.add),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: itens.map((item) {
        final ehAdicionar = item.$1 == '+';
        return Material(
          color: item.$2,
          borderRadius: BorderRadius.circular(7),
          child: InkWell(
            onTap: () {
              if (ehAdicionar) {
                _adicionarServicoStreaming();
              } else {
                _mensagem(
                  'O serviço ${item.$1} foi selecionado. Para abrir o streaming, é necessário configurar o aplicativo ou link externo correspondente.',
                );
              }
            },
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 55,
              height: 55,
              child: Center(
                child: Icon(
                  item.$3,
                  color: ehAdicionar ? marrom : AppColors.white,
                  size: ehAdicionar ? 31 : 27,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoBanner(IconData icon, String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          Icon(icon, color: marrom, size: 26),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: marrom,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicador(String titulo, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: marrom, size: 22),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: marrom.withValues(alpha: 0.70),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: marrom,
                    fontSize: 13.5,
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

  Widget _rodapeIdentificacao() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      iconColor: marrom,
      collapsedIconColor: marrom,
      title: const Text(
        'Informações do aparelho',
        style: TextStyle(
          color: marrom,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      children: [
        _linhaInfo('ID', widget.id),
        _linhaInfo('Fabricante', widget.fabricante),
        _linhaInfo('Modelo', widget.modelo),
        _linhaInfo('Conexão', widget.conexao),
        _linhaInfo('Local', widget.local),
        _linhaInfo('Status', widget.status),
      ],
    );
  }

  Widget _linhaInfo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: marrom, fontSize: 11.5, height: 1.25),
          children: [
            TextSpan(
              text: '$titulo: ',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionarPreConfiguracao() async {
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova pré-configuração'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nome'),
          onSubmitted: (valor) => Navigator.pop(dialogContext, valor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || nome == null) return;
    final limpo = nome.trim();
    if (limpo.isEmpty) {
      _mensagem('Informe um nome para a pré-configuração.');
      return;
    }
    final listaExistente = widget.tipo == 'Ar condicionado'
        ? _presetsArPersonalizados
        : _cenasPersonalizadas;
    final nomeDuplicado = listaExistente.any(
      (item) => item.toLowerCase() == limpo.toLowerCase(),
    );
    if (nomeDuplicado) {
      _mensagem('Essa pré-configuração já existe.');
      return;
    }

    setState(() {
      if (widget.tipo == 'Ar condicionado') {
        _presetsArPersonalizados.add(limpo);
        modoAr = limpo;
      } else if (widget.tipo == 'Lâmpada') {
        _cenasPersonalizadas.add(limpo);
        cenaLampada = limpo;
      }
    });
  }

  Future<void> _adicionarServicoStreaming() async {
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adicionar streaming'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nome do serviço'),
          onSubmitted: (valor) => Navigator.pop(dialogContext, valor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || nome == null) return;
    final limpo = nome.trim();
    if (limpo.isEmpty) {
      _mensagem('Digite o nome do serviço.');
      return;
    }
    if (<String>[
      'Twitch',
      'Disney+',
      'Prime',
      'YouTube',
      'Netflix',
      ..._servicosPersonalizados,
    ].any((item) => item.toLowerCase() == limpo.toLowerCase())) {
      _mensagem('Esse serviço já está na lista.');
      return;
    }
    setState(() => _servicosPersonalizados.add(limpo));
  }

  void _abrirCenas() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: amareloCard,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cenas da iluminação',
                style: TextStyle(
                  color: marrom,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              for (final cena in <String>[
                'Relaxar',
                'Leitura',
                'Filme',
                ..._cenasPersonalizadas,
              ])
                ListTile(
                  title: Text(cena, style: const TextStyle(color: marrom)),
                  trailing: cenaLampada == cena
                      ? const Icon(Icons.check, color: marrom)
                      : null,
                  onTap: () {
                    setState(() => cenaLampada = cena);
                    Navigator.pop(sheetContext);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.add, color: marrom),
                title: const Text(
                  'Criar cena',
                  style: TextStyle(color: marrom),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _adicionarPreConfiguracao();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirGraficos() {
    if (widget.tipo != 'TV' && widget.tipo != 'Ar condicionado') {
      Navigator.pushNamed(context, '/graficos');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaGraficosDetalhes(
          tipo: widget.tipo == 'TV'
              ? TipoAparelho.tv
              : TipoAparelho.arCondicionado,
          nomePersonalizado: widget.nome,
          local: widget.local,
          status: widget.status,
          deviceBackendId: widget.backendId,
        ),
      ),
    );
  }

  void _mostrarInformacoes() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Informações do aparelho'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _linhaInfo('Nome', widget.nome),
              _linhaInfo('Tipo', widget.tipo),
              _linhaInfo('ID', widget.id),
              _linhaInfo('Fabricante', widget.fabricante),
              _linhaInfo('Modelo', widget.modelo),
              _linhaInfo('Conexão', widget.conexao),
              _linhaInfo('Local', widget.local),
              _linhaInfo('Status', widget.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarRemocao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover aparelho'),
        content: Text('Deseja remover "${widget.nome}" da lista da casa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    try {
      await AparelhosStore.removerDoBackend(widget.id);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) _mensagem(error.toString());
    }
  }

  void _mensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
