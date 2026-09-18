import 'package:flutter/material.dart';
import 'barra_navegacao.dart';

class TelaDetalhesAparelho extends StatefulWidget {
  final String nome;
  final IconData icone;

  const TelaDetalhesAparelho({
    super.key,
    this.nome = 'Ar condicionado',
    this.icone = Icons.air,
  });

  @override
  State<TelaDetalhesAparelho> createState() =>
      _TelaDetalhesAparelhoState();
}

class _TelaDetalhesAparelhoState extends State<TelaDetalhesAparelho> {
  // ==========================================================
  // CORES
  // ==========================================================

  static const Color marrom = Color(0xFF964900);
  static const Color amareloClaro = Color(0xFFFFF7B7);
  static const Color amareloBotao = Color(0xFFFFEE82);

  // ==========================================================
  // CONTROLES
  // ==========================================================

  bool ligado = false;
  bool desligamentoAutomatico = false;
  bool modoSono = false;
  bool modoEconomico = false;

  double temperatura = 18;

  int velocidadeVentilador = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD20D),

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFE51A),
                Color(0xFFF5A900),
              ],
            ),
          ),

          child: Column(
            children: [
              // ==================================================
              // CONTEÚDO
              // ==================================================

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    27,
                    24,
                    22,
                    18,
                  ),

                  child: Column(
                    children: [
                      _cabecalho(),

                      const SizedBox(height: 20),

                      _painelAparelho(),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // BARRA DE NAVEGAÇÃO
              // ==================================================

              const BarraNavegacao(
                itemSelecionado: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CABEÇALHO
  // ==========================================================

  Widget _cabecalho() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Minha casa',
            style: TextStyle(
              color: marrom,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            _mensagem('Adicionar aparelho');
          },
          child: const Icon(
            Icons.add,
            color: marrom,
            size: 34,
          ),
        ),

        const SizedBox(width: 24),

        GestureDetector(
          onTap: _abrirMenu,
          child: const Icon(
            Icons.more_vert,
            color: marrom,
            size: 29,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PAINEL
  // ==========================================================

  Widget _painelAparelho() {
    return Container(
      width: double.infinity,

      // Não usamos mais uma altura fixa.
      // Isso impede o BOTTOM OVERFLOWED.
      constraints: const BoxConstraints(
        minHeight: 500,
      ),

      padding: const EdgeInsets.fromLTRB(
        21,
        17,
        21,
        20,
      ),

      decoration: BoxDecoration(
        color: amareloClaro,
        borderRadius: BorderRadius.circular(30),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // NOME DO APARELHO
          // ====================================================

          _topoAparelho(),

          const SizedBox(height: 9),

          const Divider(
            color: Color(0xFFB87817),
            thickness: 1,
            height: 1,
          ),

          const SizedBox(height: 10),

          // ====================================================
          // LIGAR / DESLIGAR
          // ====================================================

          _linhaLigarDesligar(),

          // ====================================================
          // TEMPERATURA
          // ====================================================

          _linhaTemperatura(),

          // ====================================================
          // DESLIGAMENTO
          // ====================================================

          _linhaSwitch(
            titulo: 'Desligamento Automático',
            valor: desligamentoAutomatico,
            onChanged: (valor) {
              setState(() {
                desligamentoAutomatico = valor;
              });
            },
          ),

          // ====================================================
          // VELOCIDADE
          // ====================================================

          _linhaVelocidade(),

          // ====================================================
          // MODO SONO
          // ====================================================

          _linhaSwitch(
            titulo: 'Modo Sono',
            valor: modoSono,
            onChanged: (valor) {
              setState(() {
                modoSono = valor;
              });
            },
          ),

          // ====================================================
          // MODO ECONÔMICO
          // ====================================================

          _linhaSwitch(
            titulo: 'Modo Econômico',
            valor: modoEconomico,
            onChanged: (valor) {
              setState(() {
                modoEconomico = valor;
              });
            },
          ),

          // ====================================================
          // GRÁFICOS
          // ====================================================

          _linhaTexto(
            'Gráficos',
            iconeFinal: Icons.bar_chart,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/graficos',
              );
            },
          ),

          const SizedBox(height: 6),

          // ====================================================
          // PRÉ-CONFIGURAÇÕES
          // ====================================================

          const Text(
            'Pré - configurações',
            style: TextStyle(
              color: marrom,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          _preConfiguracoes(),

          // Espaço vazio dentro do card,
          // igual ao design do Figma.
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==========================================================
  // TOPO DO APARELHO
  // ==========================================================

  Widget _topoAparelho() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.nome,
            style: const TextStyle(
              color: marrom,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        Icon(
          widget.icone,
          color: marrom,
          size: 34,
        ),
      ],
    );
  }

  // ==========================================================
  // LIGAR / DESLIGAR
  // ==========================================================

  Widget _linhaLigarDesligar() {
    return SizedBox(
      height: 35,

      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Ligar/Desligar',
              style: TextStyle(
                color: marrom,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          _switchCustom(
            valor: ligado,
            onChanged: (valor) {
              setState(() {
                ligado = valor;
              });
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TEMPERATURA
  // ==========================================================

  Widget _linhaTemperatura() {
    return SizedBox(
      height: 34,

      child: Row(
        children: [
          const SizedBox(
            width: 108,

            child: Text(
              'Temperatura',
              style: TextStyle(
                color: marrom,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,

                activeTrackColor: marrom,

                inactiveTrackColor:
                    const Color(0xFFC8951B),

                thumbColor: marrom,

                thumbShape:
                    const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),

                overlayShape:
                    SliderComponentShape.noOverlay,
              ),

              child: Slider(
                min: 10,
                max: 30,

                divisions: 20,

                value: temperatura,

                onChanged: (valor) {
                  setState(() {
                    temperatura = valor;
                  });
                },
              ),
            ),
          ),

          SizedBox(
            width: 43,

            child: Text(
              '${temperatura.round()}°C',

              textAlign: TextAlign.right,

              style: const TextStyle(
                color: marrom,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SWITCH
  // ==========================================================

  Widget _linhaSwitch({
    required String titulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      height: 35,

      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,

              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                color: marrom,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          _switchCustom(
            valor: valor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SWITCH PERSONALIZADO
  // ==========================================================

  Widget _switchCustom({
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!valor);
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),

        width: 68,
        height: 36,

        padding: const EdgeInsets.all(4),

        decoration: BoxDecoration(
          color: const Color(0xFFE2A512),
          borderRadius: BorderRadius.circular(25),
        ),

        child: AnimatedAlign(
          duration: const Duration(
            milliseconds: 180,
          ),

          alignment: valor
              ? Alignment.centerRight
              : Alignment.centerLeft,

          child: Container(
            width: 28,
            height: 28,

            decoration: const BoxDecoration(
              color: marrom,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // VELOCIDADE
  // ==========================================================

  Widget _linhaVelocidade() {
    return SizedBox(
      height: 35,

      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Velocidade do ventilador',

              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: marrom,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: velocidadeVentilador,

              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: marrom,
                size: 19,
              ),

              style: const TextStyle(
                color: marrom,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),

              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Text('1'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('2'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('3'),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text('4'),
                ),
              ],

              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    velocidadeVentilador = valor;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LINHA GRÁFICOS
  // ==========================================================

  Widget _linhaTexto(
    String texto, {
    IconData? iconeFinal,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        height: 35,

        child: Row(
          children: [
            Expanded(
              child: Text(
                texto,

                style: const TextStyle(
                  color: marrom,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            if (iconeFinal != null)
              Icon(
                iconeFinal,
                color: marrom,
                size: 21,
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PRÉ-CONFIGURAÇÕES
  // ==========================================================

  Widget _preConfiguracoes() {
    return Row(
      children: [
        _botaoPreConfig(
          texto: 'Frio',

          onTap: () {
            setState(() {
              temperatura = 18;
            });

            _mensagem(
              'Temperatura configurada para 18°C',
            );
          },
        ),

        const SizedBox(width: 10),

        _botaoPreConfig(
          texto: 'Calor',

          onTap: () {
            setState(() {
              temperatura = 25;
            });

            _mensagem(
              'Temperatura configurada para 25°C',
            );
          },
        ),

        const SizedBox(width: 10),

        GestureDetector(
          onTap: () {
            _mensagem(
              'Nova pré-configuração',
            );
          },

          child: Container(
            width: 64,
            height: 50,

            decoration: BoxDecoration(
              color: amareloBotao,
              borderRadius: BorderRadius.circular(8),
            ),

            child: const Icon(
              Icons.add,
              color: marrom,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BOTÃO PRÉ-CONFIGURAÇÃO
  // ==========================================================

  Widget _botaoPreConfig({
    required String texto,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 72,
        height: 50,

        decoration: BoxDecoration(
          color: amareloBotao,
          borderRadius: BorderRadius.circular(8),
        ),

        alignment: Alignment.center,

        child: Text(
          texto,

          style: const TextStyle(
            color: marrom,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MENU
  // ==========================================================

  void _abrirMenu() {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(18),

          decoration: const BoxDecoration(
            color: amareloClaro,

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
                  'Atualizar aparelho',

                  style: TextStyle(
                    color: marrom,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                onTap: () {
                  Navigator.pop(context);

                  _mensagem(
                    'Aparelho atualizado.',
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

                  _mostrarInformacoes();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // INFORMAÇÕES
  // ==========================================================

  void _mostrarInformacoes() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Aparelho',

            style: TextStyle(
              color: marrom,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            '${widget.nome} conectado à sua casa inteligente.',
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
  }

  // ==========================================================
  // MENSAGEM
  // ==========================================================

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }
}