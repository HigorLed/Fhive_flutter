import 'package:flutter/material.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';

class TelaAparelhos extends StatefulWidget {
  const TelaAparelhos({super.key});

  static const Color marrom = AppColors.primary;

  @override
  State<TelaAparelhos> createState() => _TelaAparelhosState();
}

class _TelaAparelhosState extends State<TelaAparelhos> {
  final Map<String, bool> _locaisAbertos = <String, bool>{};

  void _abrirCriar(BuildContext context) {
    mostrarCriarAparelho(context);
  }

  void _alternarLocal(String local) {
    setState(() {
      _locaisAbertos[local] = !(_locaisAbertos[local] ?? true);
    });
  }

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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageTop,
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Minha casa',
                              style: AppTextStyles.pageTitle,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _abrirCriar(context),
                            tooltip: 'Criar aparelho',
                            icon: const Icon(
                              Icons.add,
                              color: TelaAparelhos.marrom,
                              size: 30,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            tooltip: 'Menu',
                            icon: const Icon(
                              Icons.more_vert,
                              color: TelaAparelhos.marrom,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.section),
                      Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: TelaAparelhos.marrom,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Todos aparelhos',
                            style: TextStyle(
                              color: TelaAparelhos.marrom,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Locais',
                            style: TextStyle(
                              color: TelaAparelhos.marrom,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: TelaAparelhos.marrom,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      ValueListenableBuilder<List<AparelhoItem>>(
                        valueListenable: AparelhosStore.aparelhos,
                        builder: (context, aparelhos, _) {
                          final locais = <String>[];
                          for (final aparelho in aparelhos) {
                            if (!locais.contains(aparelho.local)) {
                              locais.add(aparelho.local);
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final local in locais) ...[
                                _cabecalhoLocal(
                                  local,
                                  aparelhos
                                      .where((aparelho) => aparelho.local == local)
                                      .length,
                                ),
                                if (_locaisAbertos[local] ?? true) ...[
                                  const SizedBox(height: 18),
                                  _gradeAparelhos(
                                    context,
                                    aparelhos
                                        .where((aparelho) => aparelho.local == local)
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 27),
                              ],
                              if (locais.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Nenhum aparelho cadastrado.',
                                    style: TextStyle(
                                      color: TelaAparelhos.marrom,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const BarraNavegacao(itemSelecionado: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalhoLocal(String local, int quantidade) {
    final aberto = _locaisAbertos[local] ?? true;

    return InkWell(
      onTap: () => _alternarLocal(local),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                local,
                style: const TextStyle(
                  color: TelaAparelhos.marrom,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$quantidade',
              style: TextStyle(
                color: TelaAparelhos.marrom.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              aberto
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: TelaAparelhos.marrom,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeAparelhos(BuildContext context, List<AparelhoItem> aparelhos) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: aparelhos
          .map(
            (aparelho) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 50) / 2,
              child: _AparelhoCard(
                aparelho: aparelho,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaDetalhesAparelho(
                        nome: aparelho.nome,
                        id: aparelho.id,
                        tipo: aparelho.tipo,
                        fabricante: aparelho.fabricante,
                        modelo: aparelho.modelo,
                        local: aparelho.local,
                        conexao: aparelho.conexao,
                        status: aparelho.status,
                        icone: aparelho.icone,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AparelhoCard extends StatelessWidget {
  final AparelhoItem aparelho;
  final VoidCallback onTap;

  const _AparelhoCard({
    required this.aparelho,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 108,
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C9),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  aparelho.icone,
                  color: TelaAparelhos.marrom,
                  size: 31,
                ),
                const Spacer(),
                Icon(
                  aparelho.conexao == 'Bluetooth'
                      ? Icons.bluetooth
                      : aparelho.conexao == 'Ethernet'
                          ? Icons.lan_outlined
                          : aparelho.wifi
                              ? Icons.wifi
                              : Icons.wifi_off,
                  color: TelaAparelhos.marrom,
                  size: 18,
                ),
                ValueListenableBuilder<Set<String>>(
                  valueListenable: AparelhosStore.favoritos,
                  builder: (context, favoritos, _) {
                    final ativo = favoritos.contains(aparelho.nome);
                    return IconButton(
                      onPressed: () {
                        AparelhosStore.alternarFavorito(aparelho.nome);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ativo
                                  ? 'Removido dos favoritos.'
                                  : 'Adicionado aos favoritos.',
                            ),
                          ),
                        );
                      },
                      tooltip: ativo ? 'Remover dos favoritos' : 'Favoritar',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        ativo ? Icons.star : Icons.star_border,
                        color: TelaAparelhos.marrom,
                        size: 22,
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Text(
              aparelho.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TelaAparelhos.marrom,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              aparelho.status,
              style: const TextStyle(
                color: TelaAparelhos.marrom,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
