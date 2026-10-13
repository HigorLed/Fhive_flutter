import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/features/onboarding/presentation/tela_tutorial.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelho_detalhes.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  static const Color marrom = AppColors.primary;
  static const Color amarelo = AppColors.accent;
  static const Color amareloClaro = AppColors.surface;

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,

        // Controla a distância das bordas
        margin: const EdgeInsets.only(left: 18, right: 18, bottom: 69),

        backgroundColor: marrom,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

        duration: const Duration(seconds: 2),
      ),
    );
  }

  void abrirAdicionar() {
    mostrarCriarAparelho(context);
  }

  void abrirMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  color: marrom,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.settings, color: marrom),
                  title: Text('Configurações', style: TextStyle(color: marrom)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      this.context,
                      '/configuracoes',
                    );
                  },
                ),
              ),

              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.person, color: marrom),
                  title: Text('Minha conta', style: TextStyle(color: marrom)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(this.context, '/conta');
                  },
                ),
              ),

              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.help_outline, color: marrom),
                  title: Text('Ajuda', style: TextStyle(color: marrom)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(this.context, '/ajuda');
                  },
                ),
              ),

              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.logout, color: marrom),
                  title: Text('Sair', style: TextStyle(color: marrom)),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: this.context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Sair'),
                          content: const Text(
                            'Deseja realmente sair da conta?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: Text(
                                'Cancelar',
                                style: TextStyle(color: marrom),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                AuthStore.sair();
                                Navigator.pushNamedAndRemoveUntil(
                                  this.context,
                                  '/entrar',
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'Sair',
                                style: TextStyle(color: marrom),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  void _abrirControleDeSom() {
    final tv = AparelhosStore.aparelhos.value.where(
      (aparelho) => aparelho.tipo.toLowerCase() == 'tv',
    );
    final aparelhosTv = tv.toList();
    if (aparelhosTv.isEmpty) {
      mostrarMensagem('Cadastre uma TV para configurar o controle de som.');
      return;
    }
    final aparelho = aparelhosTv.first;
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
  }

  void _abrirVidaMais() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vida+'),
        content: const Text(
          'O Vida+ poderá reunir dicas de conforto e economia de energia. As recomendações personalizadas ainda dependem da integração com os serviços de dados do Fhive.',
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

  @override
  Widget build(BuildContext context) {
    return NavegacaoPorDeslize(
      itemSelecionado: 0,
      child: Scaffold(
        backgroundColor: amarelo,

        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,

            decoration: const BoxDecoration(gradient: AppGradients.main),

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
                        // CABEÇALHO
                        Row(
                          children: [
                            Text('Minha casa', style: AppTextStyles.pageTitle),

                            const Spacer(),

                            IconButton(
                              onPressed: abrirAdicionar,
                              icon: Icon(Icons.add, color: marrom, size: 30),
                              tooltip: 'Adicionar',
                            ),

                            IconButton(
                              onPressed: abrirMenu,
                              icon: Icon(
                                Icons.more_vert,
                                color: marrom,
                                size: 26,
                              ),
                              tooltip: 'Menu',
                            ),
                          ],
                        ),

                        const SizedBox(height: 19),

                        // PAINEL
                        Text(
                          'Painel',
                          style: TextStyle(
                            color: marrom,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Arvo',
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceStrong,
                            borderRadius: BorderRadius.circular(21),
                          ),

                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        ValueListenableBuilder<
                                          List<AparelhoItem>
                                        >(
                                          valueListenable:
                                              AparelhosStore.aparelhos,
                                          builder: (context, aparelhos, _) =>
                                              _cartaoPainel(
                                                icone: Icons.cloud_outlined,
                                                titulo: 'Conexões',
                                                subtitulo:
                                                    '${aparelhos.length} aparelhos',
                                                onTap: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/aparelhos',
                                                    ),
                                              ),
                                        ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: _cartaoPainel(
                                      icone: Icons.bolt_outlined,
                                      titulo: 'Energia',
                                      subtitulo: 'Gastos',
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/graficos',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: _cartaoPainel(
                                      icone: Icons.volume_up_outlined,
                                      titulo: 'Saída de som',
                                      subtitulo: 'Configurar',
                                      onTap: _abrirControleDeSom,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: _cartaoPainel(
                                      icone: Icons.favorite_border,
                                      titulo: 'Vida+',
                                      subtitulo: 'Saiba mais',
                                      onTap: _abrirVidaMais,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        _cartaoTutorial(),

                        const SizedBox(height: 17),

                        // FAVORITOS
                        const Text(
                          'Favoritos',
                          style: TextStyle(
                            color: marrom,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Arvo',
                          ),
                        ),

                        const SizedBox(height: 9),

                        ValueListenableBuilder<Set<String>>(
                          valueListenable: AparelhosStore.favoritos,
                          builder: (context, favoritos, _) {
                            if (favoritos.isEmpty) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => mostrarMensagem(
                                  'Toque na estrela de um aparelho para favoritar.',
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: 98,
                                  decoration: BoxDecoration(
                                    color: amareloClaro,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star_border,
                                        color: marrom,
                                        size: 37,
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        'Ainda não há favoritos.',
                                        style: TextStyle(
                                          color: marrom,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Arvo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final favoritosDados = AparelhosStore
                                .aparelhos
                                .value
                                .where(
                                  (aparelho) => favoritos.contains(aparelho.id),
                                )
                                .toList();

                            return Column(
                              children: favoritosDados
                                  .map(
                                    (aparelho) => Padding(
                                      padding: const EdgeInsets.only(bottom: 9),
                                      child: _AparelhoFavoritoCard(
                                        aparelho: aparelho,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  TelaDetalhesAparelho(
                                                    nome: aparelho.nome,
                                                    id: aparelho.id,
                                                    tipo: aparelho.tipo,
                                                    fabricante:
                                                        aparelho.fabricante,
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
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // BARRA NOVA
                const BarraNavegacao(itemSelecionado: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartaoPainel({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),

      child: Container(
        height: 55,

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          children: [
            Icon(icone, color: marrom, size: 32),

            const SizedBox(width: 7),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: marrom,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: marrom,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoTutorial() {
    return InkWell(
      borderRadius: BorderRadius.circular(15),

      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.55),
          builder: (context) {
            return const TelaTutorial();
          },
        );
      },

      child: Container(
        width: double.infinity,
        height: 98,
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: amareloClaro,
          borderRadius: BorderRadius.circular(15),
        ),

        child: Row(
          children: [
            Container(
              width: 80,
              height: 75,

              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE8),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(Icons.play_circle_outline, color: marrom, size: 47),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tutorial',
                    style: TextStyle(
                      color: marrom,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Arvo',
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Aprenda rapidamente como utilizar o Fhive.',
                    style: TextStyle(
                      color: marrom,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AparelhoFavoritoCard extends StatelessWidget {
  final AparelhoItem aparelho;
  final VoidCallback onTap;

  const _AparelhoFavoritoCard({required this.aparelho, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(aparelho.icone, color: AppColors.primary, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aparelho.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    aparelho.status,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remover dos favoritos',
              onPressed: () => AparelhosStore.alternarFavorito(aparelho.id),
              icon: const Icon(Icons.star, color: AppColors.primary, size: 24),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
