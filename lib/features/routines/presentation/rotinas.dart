import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

class TelaRotinas extends StatefulWidget {
  const TelaRotinas({super.key});

  @override
  State<TelaRotinas> createState() => _TelaRotinasState();
}

class _TelaRotinasState extends State<TelaRotinas> {
  static const Color marrom = AppColors.primary;
  static const Color creme = AppColors.surface;

  String localSelecionado = 'Locais';
  bool salaAberta = true;

  @override
  Widget build(BuildContext context) {
    return NavegacaoPorDeslize(
      itemSelecionado: 3,
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

                const BarraNavegacao(itemSelecionado: 3),
              ],
            ),
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
          child: Text('Minha casa', style: AppTextStyles.pageTitle),
        ),

        IconButton(
          onPressed: () {
            mostrarCriarAparelho(context);
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.add, color: marrom, size: 30),
        ),

        const SizedBox(width: 12),

        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert, color: marrom, size: 26),
          onSelected: (valor) {
            if (valor == 'atualizar') {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${RotinasStore.rotinas.value.length} rotinas disponíveis.',
                  ),
                ),
              );
            }

            if (valor == 'ajuda') {
              _mostrarAjuda();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'atualizar', child: Text('Atualizar')),
            PopupMenuItem(value: 'ajuda', child: Text('Ajuda')),
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
              Icon(Icons.search, color: marrom, size: 20),
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
              const Icon(Icons.keyboard_arrow_down, color: marrom, size: 19),
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
              border: Border.all(color: marrom, width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(Icons.add, color: marrom, size: 17),
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
            salaAberta ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
    if (!salaAberta) return const SizedBox();

    return ValueListenableBuilder<List<RotinaItem>>(
      valueListenable: RotinasStore.rotinas,
      builder: (context, rotinas, _) {
        final filtradas = rotinas.where((rotina) {
          return localSelecionado == 'Locais' ||
              rotina.local == 'Locais' ||
              rotina.local == localSelecionado;
        }).toList();

        if (filtradas.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhuma rotina cadastrada para este local.',
              style: TextStyle(
                color: marrom,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtradas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 54,
          ),
          itemBuilder: (context, index) => _cardRotina(filtradas[index]),
        );
      },
    );
  }

  // ============================================================
  // CARD ROTINA
  // ============================================================

  Widget _cardRotina(RotinaItem rotina) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
      decoration: BoxDecoration(
        color: rotina.ativa ? creme : creme.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              rotina.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: rotina.ativa ? marrom : marrom.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => _executarRotina(rotina.id),
            child: Tooltip(
              message: rotina.ativa ? 'Executar rotina' : 'Rotina desativada',
              child: Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  color: rotina.ativa ? marrom : Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Opções da rotina',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 28),
            iconSize: 18,
            icon: const Icon(Icons.more_vert, color: marrom, size: 17),
            onSelected: (acao) {
              if (acao == 'alternar') {
                RotinasStore.alternar(rotina.id);
              } else if (acao == 'remover') {
                _confirmarRemocaoRotina(rotina);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'alternar',
                child: Text(
                  rotina.ativa ? 'Desativar rotina' : 'Ativar rotina',
                ),
              ),
              const PopupMenuItem(
                value: 'remover',
                child: Text('Remover rotina'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarRemocaoRotina(RotinaItem rotina) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover rotina'),
        content: Text('Deseja remover a rotina "${rotina.nome}"?'),
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
    RotinasStore.remover(rotina.id);
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
              for (final local in AparelhosStore.locaisDisponiveis)
                _opcaoLocal(local),
            ],
          ),
        );
      },
    );
  }

  Widget _opcaoLocal(String nome) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          nome,
          style: const TextStyle(color: marrom, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          setState(() {
            localSelecionado = nome;
          });

          Navigator.pop(context);
        },
      ),
    );
  }

  // ============================================================
  // ADICIONAR ROTINA
  // ============================================================

  void _adicionarRotina() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Adicionar rotina',
          style: TextStyle(color: marrom, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Nome da rotina'),
          onSubmitted: (_) => _salvarNovaRotina(dialogContext, controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: marrom)),
          ),
          TextButton(
            onPressed: () => _salvarNovaRotina(dialogContext, controller),
            child: const Text('Adicionar', style: TextStyle(color: marrom)),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _salvarNovaRotina(
    BuildContext dialogContext,
    TextEditingController controller,
  ) {
    final nome = controller.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para a rotina.')),
      );
      return;
    }
    final rotina = RotinasStore.adicionar(
      nome: nome,
      local: localSelecionado,
      horario: 'Sem horário',
      acoes: const <String>[],
    );
    if (rotina == null) return;
    Navigator.pop(dialogContext);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Rotina "$nome" adicionada.')));
  }

  // ============================================================
  // EXECUTAR ROTINA
  // ============================================================

  void _executarRotina(String id) {
    final rotina = RotinasStore.porId(id);
    if (rotina == null) return;
    if (!rotina.ativa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ative esta rotina antes de executá-la.')),
      );
      return;
    }
    RotinasStore.executar(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Execução de "${rotina.nome}" registrada (simulação local).',
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
            style: TextStyle(color: marrom, fontWeight: FontWeight.bold),
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
              child: const Text('Fechar', style: TextStyle(color: marrom)),
            ),
          ],
        );
      },
    );
  }
}
