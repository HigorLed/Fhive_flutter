import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';

class TelaDetalhesAparelho extends StatefulWidget {
  final String nome;
  final String id;
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
  String modoAr = 'Frio';
  String cenaLampada = 'Relaxar';

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
        _linhaSwitch('Ligar/Desligar', ligado, Icons.power_settings_new,
            (valor) => setState(() => ligado = valor)),
        _linhaSlider(
          titulo: 'Volume',
          valor: volume,
          min: 0,
          max: 100,
          textoValor: '${volume.round()}%',
          iconeFinal: Icons.volume_up_rounded,
          onChanged: (valor) => setState(() => volume = valor),
        ),
        _linhaSwitch('Desligamento Automático', temporizador, Icons.timer_outlined,
            (valor) => setState(() => temporizador = valor)),
        _linhaSwitch('Controle Remoto', controleRemoto, Icons.settings_remote_outlined,
            (valor) => setState(() => controleRemoto = valor)),
        _linkTitulo('Gráficos', () => _mensagem('Abrindo gráficos de ${widget.nome}.')),
        const SizedBox(height: 24),
        const Text(
          'Streamings',
          style: TextStyle(
            color: marrom,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        _streamingGrid(),
      ],
    );
  }

  Widget _conteudoAr() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch('Ligar/Desligar', ligado, Icons.power_settings_new,
            (valor) => setState(() => ligado = valor)),
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
        _linkTitulo('Gráficos', () => _mensagem('Abrindo gráficos de ${widget.nome}.')),
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
            _preset('Calor', modoAr == 'Quente'),
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
        _linhaSwitch('Ligar/Desligar', ligado, Icons.power_settings_new,
            (valor) => setState(() => ligado = valor)),
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
        _linkTitulo('Cenas', () => _mensagem('Cenas da iluminação abertas.')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final cena in ['Relaxar', 'Leitura', 'Filme'])
              _preset(cena, cena == cenaLampada),
          ],
        ),
      ],
    );
  }

  Widget _conteudoCamera() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBanner(Icons.videocam_outlined,
            'Visualização disponível quando a integração de vídeo estiver ativa.'),
        const SizedBox(height: 14),
        _linhaSwitch('Privacidade', privacidade, Icons.visibility_off_outlined,
            (valor) => setState(() => privacidade = valor)),
        _linhaSwitch('Detecção de movimento', deteccaoMovimento,
            Icons.directions_run_rounded,
            (valor) => setState(() => deteccaoMovimento = valor)),
        _linhaSwitch('Gravação', gravacao, Icons.fiber_manual_record_outlined,
            (valor) => setState(() => gravacao = valor)),
        _linkTitulo('Gráficos', () => _mensagem('Abrindo dados da câmera.')),
      ],
    );
  }

  Widget _conteudoTomada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch('Ligar/Desligar', ligado, Icons.power_settings_new,
            (valor) => setState(() => ligado = valor)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _indicador('Potência', '184 W', Icons.bolt_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _indicador('Hoje', '1,8 kWh', Icons.bar_chart_outlined)),
          ],
        ),
        const SizedBox(height: 10),
        _linhaSwitch('Temporizador', temporizador, Icons.timer_outlined,
            (valor) => setState(() => temporizador = valor)),
        _linhaSwitch('Economia de energia', modoEconomico, Icons.eco_outlined,
            (valor) => setState(() => modoEconomico = valor)),
      ],
    );
  }

  Widget _conteudoSensor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _indicador('Temperatura', '23°C', Icons.thermostat_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _indicador('Umidade', '58%', Icons.water_drop_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        _linhaSwitch('Monitoramento ativo', monitoramento, Icons.sensors_outlined,
            (valor) => setState(() => monitoramento = valor)),
        _linhaSwitch('Notificar alterações', notificacoes,
            Icons.notifications_none_outlined,
            (valor) => setState(() => notificacoes = valor)),
        _linhaSwitch('Alertas de limite', alerta, Icons.warning_amber_outlined,
            (valor) => setState(() => alerta = valor)),
      ],
    );
  }

  Widget _conteudoGenerico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch('Ligar/Desligar', ligado, Icons.power_settings_new,
            (valor) => setState(() => ligado = valor)),
        _linhaSwitch('Notificações', notificacoes,
            Icons.notifications_none_outlined,
            (valor) => setState(() => notificacoes = valor)),
        _linkTitulo('Gráficos', () => _mensagem('Abrindo gráficos do aparelho.')),
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
          if (texto == 'Frio') setState(() => modoAr = 'Frio');
          if (texto == 'Calor') setState(() => modoAr = 'Quente');
          if (texto == 'Relaxar' || texto == 'Leitura' || texto == 'Filme') {
            setState(() => cenaLampada = texto);
          }
          if (texto == '+') _mensagem('Adicionar nova pré-configuração.');
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
            onTap: () => _mensagem(
              ehAdicionar ? 'Adicionar aplicativo.' : '${item.$1} selecionado.',
            ),
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 55,
              height: 55,
              child: Center(
                child: Icon(
                  item.$3,
                  color: ehAdicionar ? marrom : Colors.white,
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
        borderRadius: BorderRadius.circular(14),
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
          style: const TextStyle(
            color: marrom,
            fontSize: 11.5,
            height: 1.25,
          ),
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

  void _mensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }


}
