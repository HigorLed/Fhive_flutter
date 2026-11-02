import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/network/api_client.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';
import 'package:tcc_mobile/shared/state/preferencias_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  bool notificacoes = PreferenciasStore.notificacoes;
  bool sincronizarFavoritos = PreferenciasStore.sincronizarFavoritos;
  bool sugestoes = PreferenciasStore.sugestoes;

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirDialogo({required String titulo, required String texto}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
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
    _abrirDialogo(titulo: 'Recursos avançados', texto: texto);
  }

  void _confirmarSaida() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair do Fhive'),
        content: const Text(
          'Isso encerra sua sessão e limpa do aplicativo o cache de aparelhos e rotinas. Sua conta e seus dados salvos no backend não serão excluídos. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AuthStore.reset();
              AparelhosStore.reset();
              RotinasStore.reset();
              PreferenciasStore.reset();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/inicio',
                (route) => false,
              );
            },
            child: Text(
              'Sair',
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _preferencia({
    required String titulo,
    String? subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return _ItemConfiguracao(
      titulo: titulo,
      subtitulo: subtitulo,
      onTap: () => onChanged(!valor),
      trailing: Switch(value: valor, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavegacaoPorDeslize(
      itemSelecionado: 4,
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
                        const CabecalhoPagina(titulo: 'Configurações do Fhive'),
                        const SizedBox(height: AppSpacing.section),
                        _CartaoConfiguracoes(
                          children: [
                            _ItemConfiguracao(
                              titulo: 'Minha conta',
                              subtitulo: 'Visualize e edite os dados do perfil',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/conta'),
                            ),
                            _ItemConfiguracao(
                              titulo: 'Ajuda',
                              subtitulo:
                                  'Veja orientações sobre as funções do Fhive',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/ajuda'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.cardGap),
                        _CartaoConfiguracoes(
                          children: [
                            _preferencia(
                              titulo: 'Notificações',
                              valor: notificacoes,
                              onChanged: (valor) {
                                setState(() {
                                  notificacoes = valor;
                                  PreferenciasStore.notificacoes = valor;
                                });
                                _mensagem(
                                  valor
                                      ? 'Preferência ativada nesta sessão; notificações do sistema ainda não estão integradas.'
                                      : 'Preferência de notificações desativada nesta sessão.',
                                );
                              },
                            ),
                            _preferencia(
                              titulo: 'Sincronizar favoritos',
                              valor: sincronizarFavoritos,
                              onChanged: (valor) {
                                setState(() {
                                  sincronizarFavoritos = valor;
                                  PreferenciasStore.sincronizarFavoritos =
                                      valor;
                                });
                                _mensagem(
                                  valor
                                      ? 'Ainda não existe endpoint de favoritos; esta opção só altera a preferência local.'
                                      : 'A sincronização de favoritos está desativada nesta sessão.',
                                );
                              },
                            ),
                            _preferencia(
                              titulo: 'Sugestões de função',
                              subtitulo:
                                  'Receba notificações para saber mais sobre nossas funções',
                              valor: sugestoes,
                              onChanged: (valor) {
                                setState(() {
                                  sugestoes = valor;
                                  PreferenciasStore.sugestoes = valor;
                                });
                                _mensagem(
                                  valor
                                      ? 'Preferência de sugestões ativada nesta sessão.'
                                      : 'Preferência de sugestões desativada nesta sessão.',
                                );
                              },
                            ),
                            _ItemConfiguracao(
                              titulo: 'Recursos avançados',
                              onTap: _mostrarDiagnostico,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.section),
                        const TituloSecao(titulo: 'Privacidade'),
                        const SizedBox(height: AppSpacing.sm),
                        _CartaoConfiguracoes(
                          children: [
                            _ItemConfiguracao(
                              titulo: 'Aviso de privacidade',
                              onTap: () => _abrirDialogo(
                                titulo: 'Aviso de privacidade',
                                texto:
                                    'O app envia ao backend os dados necessários para autenticação, perfil, aparelhos, rotinas e telemetria disponível. Favoritos, atalhos e preferências permanecem locais. '
                                    'Use apenas uma instância de backend confiável e uma conexão HTTPS em produção. Este aviso não substitui uma política de privacidade formal.',
                              ),
                            ),
                            _ItemConfiguracao(
                              titulo:
                                  'Consentimento com a coleta e o uso de informações pessoais',
                              onTap: () => _abrirDialogo(
                                titulo: 'Consentimento',
                                texto:
                                    'As opções desta tela alteram preferências locais e ainda não enviam consentimento ao backend. A API consulta apenas os dados necessários às funções conectadas.',
                              ),
                            ),
                            _ItemConfiguracao(
                              titulo: 'Sair do Fhive',
                              subtitulo:
                                  'Encerra a sessão neste dispositivo; não exclui sua conta no servidor',
                              onTap: _confirmarSaida,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const BarraNavegacao(itemSelecionado: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão creme que agrupa itens separados por divisores.
class _CartaoConfiguracoes extends StatelessWidget {
  const _CartaoConfiguracoes({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ItemConfiguracao extends StatelessWidget {
  const _ItemConfiguracao({
    required this.titulo,
    required this.onTap,
    this.subtitulo,
    this.trailing,
  });

  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppTextStyles.bodyBold),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitulo!, style: AppTextStyles.caption),
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
}
