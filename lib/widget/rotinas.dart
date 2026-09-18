import 'package:flutter/material.dart';
import 'barra_navegacao.dart';

class TelaRotinas extends StatefulWidget {
  const TelaRotinas({super.key});

  @override
  State<TelaRotinas> createState() => _TelaRotinasState();
}

class _TelaRotinasState extends State<TelaRotinas> {
  static const Color marrom = Color(0xFF964900);
  static const Color creme = Color(0xFFFFF6C9);
  static const Color amareloCard = Color(0xFFFFE778);

  String localSelecionado = 'Locais';
  bool salaAberta = true;

  final List<String> rotinas = [
    'Acordar',
    'Ao sair de casa',
    'Dormir',
    'Economizar energia',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE72B),
              Color(0xFFFFCC0A),
              Color(0xFFF5A800),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabecalho(),

                      const SizedBox(height: 18),

                      _linhaRotinas(),

                      const SizedBox(height: 14),

                      _botaoAdicionarRotina(),

                      const SizedBox(height: 12),

                      _tituloSala(),

                      const SizedBox(height: 10),

                      _listaRotinas(),
                    ],
                  ),
                ),
              ),

              const BarraNavegacao(
                itemSelecionado: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CABEÇALHO
  // ============================================================

  Widget _cabecalho() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Minha casa',
            style: TextStyle(
              color: marrom,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            _adicionarRotina();
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.add,
            color: marrom,
            size: 29,
          ),
        ),

        const SizedBox(width: 12),

        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.more_vert,
            color: marrom,
            size: 25,
          ),
          onSelected: (valor) {
            if (valor == 'atualizar') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rotinas atualizadas.'),
                ),
              );
            }

            if (valor == 'ajuda') {
              _mostrarAjuda();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'atualizar',
              child: Text('Atualizar'),
            ),
            PopupMenuItem(
              value: 'ajuda',
              child: Text('Ajuda'),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ROTINAS / LOCAIS
  // ============================================================

  Widget _linhaRotinas() {
    return Row(
      children: [
        const Expanded(
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: marrom,
                size: 20,
              ),
              SizedBox(width: 5),
              Text(
                'Rotinas',
                style: TextStyle(
                  color: marrom,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: _selecionarLocal,
          child: Row(
            children: [
              Text(
                localSelecionado,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.keyboard_arrow_down,
                color: marrom,
                size: 19,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADICIONAR ROTINA
  // ============================================================

  Widget _botaoAdicionarRotina() {
    return GestureDetector(
      onTap: _adicionarRotina,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: marrom,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(
              Icons.add,
              color: marrom,
              size: 17,
            ),
          ),

          const SizedBox(width: 7),

          const Text(
            'Adicionar rotina',
            style: TextStyle(
              color: marrom,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO SALA
  // ============================================================

  Widget _tituloSala() {
    return GestureDetector(
      onTap: () {
        setState(() {
          salaAberta = !salaAberta;
        });
      },
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Sala de Estar',
              style: TextStyle(
                color: marrom,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Icon(
            salaAberta
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: marrom,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LISTA DE ROTINAS
  // ============================================================

  Widget _listaRotinas() {
    if (!salaAberta) {
      return const SizedBox();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rotinas.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 54,
      ),
      itemBuilder: (context, index) {
        return _cardRotina(rotinas[index]);
      },
    );
  }

  // ============================================================
  // CARD ROTINA
  // ============================================================

  Widget _cardRotina(String nome) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        10,
        6,
        7,
        6,
      ),
      decoration: BoxDecoration(
        color: creme,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: marrom,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 4),

          GestureDetector(
            onTap: () {
              _executarRotina(nome);
            },
            child: Container(
              width: 21,
              height: 21,
              decoration: const BoxDecoration(
                color: marrom,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECIONAR LOCAL
  // ============================================================

  void _selecionarLocal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: creme,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecionar local',
                style: TextStyle(
                  color: marrom,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              _opcaoLocal('Locais'),
              _opcaoLocal('Sala de Estar'),
              _opcaoLocal('Quarto'),
              _opcaoLocal('Cozinha'),
            ],
          ),
        );
      },
    );
  }

  Widget _opcaoLocal(String nome) {
    return ListTile(
      title: Text(
        nome,
        style: const TextStyle(
          color: marrom,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        setState(() {
          localSelecionado = nome;
        });

        Navigator.pop(context);
      },
    );
  }

  // ============================================================
  // ADICIONAR ROTINA
  // ============================================================

  void _adicionarRotina() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Adicionar rotina',
            style: TextStyle(
              color: marrom,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nome da rotina',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: marrom),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    rotinas.add(controller.text.trim());
                  });
                }

                Navigator.pop(context);
              },
              child: const Text(
                'Adicionar',
                style: TextStyle(color: marrom),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EXECUTAR ROTINA
  // ============================================================

  void _executarRotina(String rotina) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Executando rotina: $rotina',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // AJUDA
  // ============================================================

  void _mostrarAjuda() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Rotinas',
            style: TextStyle(
              color: marrom,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'As rotinas permitem executar várias ações '
            'dos seus dispositivos de uma só vez.',
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
}