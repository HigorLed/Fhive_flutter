import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/network/api_client.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/features/devices/presentation/criar_aparelho.dart';
import 'package:tcc_mobile/shared/state/preferencias_store.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  bool notificacoes = PreferenciasStore.notificacoes;
  bool sincronizarFavoritos = PreferenciasStore.sincronizarFavoritos;
  bool sugestoes = PreferenciasStore.sugestoes;

  static const Color marrom = AppColors.primaryDeep;
  static const Color marromCard = AppColors.primaryCard;
  static const Color creme = AppColors.cream;

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: marromCard,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void abrirDialogo({required String titulo, required String texto}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: creme,

          title: Text(
            titulo,
            style: const TextStyle(
              color: marrom,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.body,
            ),
          ),

          content: Text(
            texto,
            style: const TextStyle(color: marrom, fontFamily: AppFonts.body),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text(
                'Fechar',
                style: TextStyle(color: marrom, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDiagnostico() async {
    final aparelhos = AparelhosStore.aparelhos.value;
    final favoritos = AparelhosStore.favoritosLista.length;
    final rotinas = RotinasStore.rotinas.value;
    final rotinasAtivas = rotinas.where((rotina) => rotina.ativa).length;
    var estadoApi = 'Não foi possível verificar a API.';
    try {
      final resposta = await ApiClient.get('/');
      final mensagem = resposta is Map ? resposta['mensagem'] : null;
      estadoApi = mensagem is String && mensagem.trim().isNotEmpty
          ? 'Conectada — $mensagem'
          : 'Conectada';
    } catch (error) {
      estadoApi = 'Indisponível — $error';
    }
    if (!mounted) return;
    final texto =
        'Estado da API: $estadoApi\n'
        'Aparelhos cadastrados: ${aparelhos.length}\n'
        'Favoritos: $favoritos\n'
        'Rotinas cadastradas: ${rotinas.length}\n'
        'Rotinas ativas: $rotinasAtivas\n\n'
        'Aparelhos e rotinas são sincronizados com o backend. '
        'Favoritos e preferências continuam locais. O diagnóstico não testa a '
        'conexão física dos aparelhos; isso depende do hardware e do MQTT.';
    abrirDialogo(titulo: 'Recursos avançados', texto: texto);
  }

  Widget itemMenu({
    required String titulo,
    required VoidCallback onTap,
    Widget? trailing,
    String? subtitulo,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: 10),

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),

                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.2,
                        fontFamily: AppFonts.body,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget separador() {
    return Container(height: 1, color: Colors.black.withValues(alpha: 0.18));
  }

  Widget card({required List<Widget> children}) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: marromCard,
        borderRadius: BorderRadius.circular(AppRadius.largeCard),
      ),

      child: Column(children: children),
    );
  }

  Widget switchPersonalizado({
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: valor,
      onChanged: onChanged,
      activeThumbColor: marrom,
      activeTrackColor: creme,
      inactiveThumbColor: creme,
      inactiveTrackColor: Colors.white24,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavegacaoPorDeslize(
      itemSelecionado: 4,
      child: Scaffold(
        backgroundColor: marrom,

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Configurações do Fhive',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 17,
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              mostrarCriarAparelho(context);
                            },
                            tooltip: 'Criar aparelho',
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.white,
                              size: 29,
                            ),
                          ),
                        ],
                      ),

                      // CONTA E AJUDA
                      card(
                        children: [
                          itemMenu(
                            titulo: 'Minha conta',
                            subtitulo: 'Visualize e edite os dados do perfil',
                            onTap: () => Navigator.pushNamed(context, '/conta'),
                          ),
                          separador(),
                          itemMenu(
                            titulo: 'Ajuda',
                            subtitulo:
                                'Veja orientações sobre as funções do Fhive',
                            onTap: () => Navigator.pushNamed(context, '/ajuda'),
                          ),
                          separador(),
                          itemMenu(
                            titulo: 'Entrar',
                            subtitulo: 'Entre com sua conta Fhive cadastrada no backend',
                            onTap: () =>
                                Navigator.pushNamed(context, '/entrar'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // NOTIFICAÇÕES
                      card(
                        children: [
                          itemMenu(
                            titulo: 'Notificação',

                            onTap: () {
                              setState(() {
                                notificacoes = !notificacoes;
                                PreferenciasStore.notificacoes = notificacoes;
                              });
                              mostrarMensagem(
                                notificacoes
                                    ? 'Preferência ativada nesta sessão; notificações do sistema ainda não estão integradas.'
                                    : 'Preferência de notificações desativada nesta sessão.',
                              );
                            },

                            trailing: switchPersonalizado(
                              valor: notificacoes,

                              onChanged: (valor) {
                                setState(() {
                                  notificacoes = valor;
                                  PreferenciasStore.notificacoes = valor;
                                });
                                mostrarMensagem(
                                  valor
                                      ? 'Preferência ativada nesta sessão; notificações do sistema ainda não estão integradas.'
                                      : 'Preferência de notificações desativada nesta sessão.',
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // FUNÇÕES
                      card(
                        children: [
                          itemMenu(
                            titulo: 'Sincronizar favoritos',

                            onTap: () {
                              setState(() {
                                sincronizarFavoritos = !sincronizarFavoritos;
                                PreferenciasStore.sincronizarFavoritos =
                                    sincronizarFavoritos;
                              });
                              mostrarMensagem(
                                sincronizarFavoritos
                                    ? 'Ainda não existe endpoint de favoritos; esta opção só altera a preferência local.'
                                    : 'A sincronização de favoritos está desativada nesta sessão.',
                              );
                            },

                            trailing: switchPersonalizado(
                              valor: sincronizarFavoritos,

                              onChanged: (valor) {
                                setState(() {
                                  sincronizarFavoritos = valor;
                                  PreferenciasStore.sincronizarFavoritos =
                                      valor;
                                });
                                mostrarMensagem(
                                  valor
                                      ? 'Ainda não existe endpoint de favoritos; esta opção só altera a preferência local.'
                                      : 'A sincronização de favoritos está desativada nesta sessão.',
                                );
                              },
                            ),
                          ),

                          separador(),

                          itemMenu(
                            titulo: 'Sugestões de função',

                            subtitulo:
                                'Receba notificações para saber mais sobre '
                                'nossas funções',

                            onTap: () {
                              setState(() {
                                sugestoes = !sugestoes;
                                PreferenciasStore.sugestoes = sugestoes;
                              });
                              mostrarMensagem(
                                sugestoes
                                    ? 'Preferência de sugestões ativada nesta sessão.'
                                    : 'Preferência de sugestões desativada nesta sessão.',
                              );
                            },

                            trailing: switchPersonalizado(
                              valor: sugestoes,

                              onChanged: (valor) {
                                setState(() {
                                  sugestoes = valor;
                                  PreferenciasStore.sugestoes = valor;
                                });
                                mostrarMensagem(
                                  valor
                                      ? 'Preferência de sugestões ativada nesta sessão.'
                                      : 'Preferência de sugestões desativada nesta sessão.',
                                );
                              },
                            ),
                          ),

                          separador(),

                          itemMenu(
                            titulo: 'Serviços vinculados',

                            subtitulo:
                                'Gerencie os serviços que você vinculou ao Fhive ou '
                                'exclua um serviço se não precisar mais dele',

                            onTap: () {
                              abrirDialogo(
                                titulo: 'Serviços vinculados',
                                texto:
                                    'Nenhum serviço externo está autenticado nesta versão. '
                                    'Vincular Google Home, Alexa, streaming ou outros provedores '
                                    'exige credenciais, APIs e configuração segura. Esta tela '
                                    'não cria vínculos externos.',
                              );
                            },
                          ),

                          itemMenu(
                            titulo: 'Recursos avançados',

                            onTap: () {
                              _mostrarDiagnostico();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 5),

                        child: Text(
                          'Privacidade',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontFamily: AppFonts.body,
                          ),
                        ),
                      ),

                      // PRIVACIDADE
                      card(
                        children: [
                          itemMenu(
                            titulo: 'Aviso de privacidade',

                            onTap: () {
                              abrirDialogo(
                                titulo: 'Aviso de privacidade',
                                texto:
                                    'O app envia ao backend os dados necessários para autenticação, perfil, aparelhos, rotinas e telemetria disponível. Favoritos, atalhos e preferências permanecem locais. '
                                    'Use apenas uma instância de backend confiável e uma conexão HTTPS em produção. Este aviso não substitui uma política de privacidade formal.',
                              );
                            },
                          ),

                          separador(),

                          itemMenu(
                            titulo:
                                'Consentimento com a coleta e o '
                                'uso de informações pessoais',

                            onTap: () {
                              abrirDialogo(
                                titulo: 'Consentimento',
                                texto:
                                    'As opções desta tela alteram preferências locais e ainda não enviam consentimento ao backend. A API consulta apenas os dados necessários às funções conectadas.',
                              );
                            },
                          ),

                          separador(),

                          itemMenu(
                            titulo: 'Permissões',

                            onTap: () {
                              abrirDialogo(
                                titulo: 'Permissões',
                                texto:
                                    'As permissões nativas de câmera, localização, Bluetooth e '
                                    'rede ainda não estão conectadas a serviços do aplicativo. '
                                    'Por isso, esta versão não solicita nem altera permissões '
                                    'do sistema operacional.',
                              );
                            },
                          ),

                          separador(),

                          itemMenu(
                            titulo: 'Recursos avançados',

                            onTap: () {
                              _mostrarDiagnostico();
                            },
                          ),

                          separador(),

                          itemMenu(
                            titulo: 'Sair do Fhive',

                            subtitulo:
                                'Encerra a sessão neste dispositivo; não exclui sua conta no servidor',

                            onTap: () {
                              showDialog(
                                context: context,

                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: creme,

                                    title: const Text(
                                      'Sair do Fhive',
                                      style: TextStyle(
                                        color: marrom,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    content: const Text(
                                      'Isso encerra sua sessão e limpa do aplicativo o cache de aparelhos e rotinas. Sua conta e seus dados salvos no backend não serão excluídos. Deseja continuar?',
                                      style: TextStyle(color: marrom),
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
                                          Navigator.pop(context);
                                          AuthStore.reset();
                                          AparelhosStore.reset();
                                          RotinasStore.reset();
                                          PreferenciasStore.reset();

                                          // A remoção local retorna à tela de entrada do aplicativo.
                                          Navigator.pushNamedAndRemoveUntil(
                                            this.context,
                                            '/inicio',
                                            (route) => false,
                                          );
                                        },

                                        child: const Text(
                                          'Sair',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // BARRA INFERIOR
              const BarraNavegacao(itemSelecionado: 4),
            ],
          ),
        ),
      ),
    );
  }
}
