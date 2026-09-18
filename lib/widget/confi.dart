import 'package:flutter/material.dart';

import 'package:tcc_mobile/widget/barra_navegacao.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() =>
      _TelaConfiguracoesState();
}

class _TelaConfiguracoesState
    extends State<TelaConfiguracoes> {
  bool notificacoes = true;
  bool sincronizarFavoritos = true;
  bool sugestoes = true;

  static const Color marrom = Color(0xFF4A2100);
  static const Color marromCard = Color(0xFF663000);
  static const Color creme = Color(0xFFFFFCEB);

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: marromCard,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void abrirDialogo({
    required String titulo,
    required String texto,
  }) {
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
              fontFamily: 'Montserrat',
            ),
          ),

          content: Text(
            texto,
            style: const TextStyle(
              color: marrom,
              fontFamily: 'Montserrat',
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text(
                'Fechar',
                style: TextStyle(
                  color: marrom,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget itemMenu({
    required String titulo,
    required VoidCallback onTap,
    Widget? trailing,
    String? subtitulo,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),

                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        height: 1.05,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (trailing != null)
              trailing,
          ],
        ),
      ),
    );
  }

  Widget separador() {
    return Container(
      height: 1,
      color: Colors.black.withOpacity(0.18),
    );
  }

  Widget card({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: marromCard,
        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Column(
        children: children,
      ),
    );
  }

  Widget switchPersonalizado({
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: valor,
      onChanged: onChanged,
      activeColor: marrom,
      activeTrackColor: creme,
      inactiveThumbColor: creme,
      inactiveTrackColor: Colors.white24,
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: marrom,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  20,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        left: 2,
                        bottom: 8,
                      ),

                      child: Text(
                        'Configurações do Fhive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontFamily:
                              'Montserrat',
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),

                    // ENTRAR
                    card(
                      children: [
                        itemMenu(
                          titulo: 'Entrar',

                          subtitulo:
                              'Entre na sua conta para obter o\n'
                              'máximo do nosso app',

                          onTap: () {
                            mostrarMensagem(
                              'Abrindo tela de login...',
                            );
                          },
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
                              notificacoes =
                                  !notificacoes;
                            });
                          },

                          trailing:
                              switchPersonalizado(
                            valor:
                                notificacoes,

                            onChanged: (valor) {
                              setState(() {
                                notificacoes =
                                    valor;
                              });
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
                          titulo:
                              'Sincronizar favoritos',

                          onTap: () {
                            setState(() {
                              sincronizarFavoritos =
                                  !sincronizarFavoritos;
                            });
                          },

                          trailing:
                              switchPersonalizado(
                            valor:
                                sincronizarFavoritos,

                            onChanged: (valor) {
                              setState(() {
                                sincronizarFavoritos =
                                    valor;
                              });
                            },
                          ),
                        ),

                        separador(),

                        itemMenu(
                          titulo:
                              'Sugestões de função',

                          subtitulo:
                              'Receba notificações para saber mais sobre\n'
                              'nossas funções',

                          onTap: () {
                            setState(() {
                              sugestoes =
                                  !sugestoes;
                            });
                          },

                          trailing:
                              switchPersonalizado(
                            valor: sugestoes,

                            onChanged: (valor) {
                              setState(() {
                                sugestoes =
                                    valor;
                              });
                            },
                          ),
                        ),

                        separador(),

                        itemMenu(
                          titulo:
                              'Serviços vinculados',

                          subtitulo:
                              'Gerencie os serviços que você vinculou ao Fhive ou\n'
                              'exclua um serviço se não precisar mais dele',

                          onTap: () {
                            abrirDialogo(
                              titulo:
                                  'Serviços vinculados',

                              texto:
                                  'Aqui você poderá visualizar, '
                                  'adicionar ou remover serviços '
                                  'vinculados à sua conta.',
                            );
                          },
                        ),

                        itemMenu(
                          titulo:
                              'Recursos avançados',

                          onTap: () {
                            abrirDialogo(
                              titulo:
                                  'Recursos avançados',

                              texto:
                                  'Configurações avançadas '
                                  'do aplicativo.',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Padding(
                      padding:
                          EdgeInsets.only(
                        left: 8,
                        bottom: 5,
                      ),

                      child: Text(
                        'Privacidade',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily:
                              'Montserrat',
                        ),
                      ),
                    ),

                    // PRIVACIDADE
                    card(
                      children: [
                        itemMenu(
                          titulo:
                              'Aviso de privacidade',

                          onTap: () {
                            abrirDialogo(
                              titulo:
                                  'Aviso de privacidade',

                              texto:
                                  'O Fhive utiliza suas informações '
                                  'de acordo com as configurações e '
                                  'políticas de privacidade do aplicativo.',
                            );
                          },
                        ),

                        separador(),

                        itemMenu(
                          titulo:
                              'Consentimento com a coleta e o\n'
                              'uso de informações pessoais',

                          onTap: () {
                            abrirDialogo(
                              titulo:
                                  'Consentimento',

                              texto:
                                  'Aqui você poderá consultar e '
                                  'gerenciar seus consentimentos '
                                  'relacionados à coleta e utilização '
                                  'de informações pessoais.',
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
                                  'Gerencie as permissões '
                                  'utilizadas pelo Fhive.',
                            );
                          },
                        ),

                        separador(),

                        itemMenu(
                          titulo:
                              'Recursos avançados',

                          onTap: () {
                            abrirDialogo(
                              titulo:
                                  'Recursos avançados',

                              texto:
                                  'Acesse configurações adicionais '
                                  'e opções avançadas da sua conta.',
                            );
                          },
                        ),

                        separador(),

                        itemMenu(
                          titulo: 'Sair do Fhive',

                          subtitulo:
                              'Apaga todos os seus dados da Fhive e exclui o serviço\n'
                              'Fhive da sua conta',

                          onTap: () {
                            showDialog(
                              context: context,

                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor:
                                      creme,

                                  title: const Text(
                                    'Sair do Fhive',
                                    style: TextStyle(
                                      color: marrom,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  content:
                                      const Text(
                                    'Tem certeza que deseja sair do Fhive?',
                                    style: TextStyle(
                                      color: marrom,
                                    ),
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                      },

                                      child:
                                          const Text(
                                        'Cancelar',
                                        style:
                                            TextStyle(
                                          color:
                                              marrom,
                                        ),
                                      ),
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);

                                        mostrarMensagem(
                                          'Saída realizada.',
                                        );
                                      },

                                      child:
                                          const Text(
                                        'Sair',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.red,
                                          fontWeight:
                                              FontWeight.bold,
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
            const BarraNavegacao(
              itemSelecionado: 4,
            ),
          ],
        ),
      ),
    );
  }
}