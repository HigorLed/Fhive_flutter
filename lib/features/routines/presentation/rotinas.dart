import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

class TelaRotinas extends StatefulWidget {
  const TelaRotinas({super.key});

  @override
  State<TelaRotinas> createState() => _TelaRotinasState();
}

class _TelaRotinasState extends State<TelaRotinas> {
  static const Color marrom = AppColors.primary;

  String localSelecionado = 'Locais';

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
                        CabecalhoPagina(
                          titulo: 'Minha casa',
                          acoes: [
                            AcaoCabecalho(
                              icone: Icons.refresh,
                              tooltip: 'Atualizar rotinas',
                              onPressed: _carregarRotinas,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.section),
                        TituloSecao(
                          titulo: 'Rotinas',
                          trailing: _seletorLocal(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _botaoAdicionarRotina(),
                        const SizedBox(height: AppSpacing.cardGap),
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
  // SELETOR DE LOCAL E ADICIONAR ROTINA
  // ============================================================

  Widget _seletorLocal() {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      onTap: _selecionarLocal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localSelecionado, style: AppTextStyles.bodyBold),
            const Icon(Icons.keyboard_arrow_down, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _botaoAdicionarRotina() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _adicionarRotina,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar rotina'),
      ),
    );
  }

  // ============================================================
  // LISTA DE ROTINAS
  // ============================================================

  Widget _listaRotinas() {
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
              style: AppTextStyles.caption,
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
        color: rotina.ativa
            ? AppColors.surfaceLight
            : AppColors.surfaceLight.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppRadius.button),
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
                  color: AppColors.white,
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
                _alternarRotina(rotina);
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
    try {
      await RotinasStore.removerDoBackend(rotina.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rotina "${rotina.nome}" removida.')),
        );
      }
    } catch (error) {
      if (mounted) _mensagemRotina(error.toString());
    }
  }

  // ============================================================
  // SELECIONAR LOCAL
  // ============================================================

  void _selecionarLocal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecionar local',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                _opcaoLocal('Locais'),
                for (final local in AparelhosStore.locaisDisponiveis)
                  _opcaoLocal(local),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _opcaoLocal(String nome) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(nome, style: AppTextStyles.bodyBold),
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
    final dispositivos = AparelhosStore.aparelhos.value;
    if (dispositivos.isEmpty) {
      _mensagemRotina('Cadastre um aparelho antes de criar uma rotina.');
      return;
    }

    final controller = TextEditingController();
    var dispositivoSelecionado = dispositivos.first.id;
    var horarioSelecionado = '07:00';
    var salvando = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar rotina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Nome da rotina'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: dispositivoSelecionado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Aparelho'),
                  items: dispositivos.map((dispositivo) => DropdownMenuItem<String>(
                    value: dispositivo.id,
                    child: Text(dispositivo.nome, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: salvando ? null : (valor) {
                    if (valor != null) setDialogState(() => dispositivoSelecionado = valor);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: salvando ? null : () async {
                    final horario = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(horarioSelecionado.split(':')[0]),
                        minute: int.parse(horarioSelecionado.split(':')[1]),
                      ),
                    );
                    if (horario != null) {
                      setDialogState(() => horarioSelecionado =
                          '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}');
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: Text('Horário inicial: $horarioSelecionado'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A rotina será salva no backend para todos os dias da semana, com uma ação inicial de ligar o aparelho. A execução física depende do executor de rotinas, ainda não exposto pela API.',
                  style: TextStyle(fontSize: 12, color: marrom),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: salvando ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: salvando ? null : () async {
                final nome = controller.text.trim();
                if (nome.isEmpty) {
                  _mensagemRotina('Digite um nome para a rotina.');
                  return;
                }
                final dispositivo = dispositivos.firstWhere(
                  (item) => item.id == dispositivoSelecionado,
                );
                setDialogState(() => salvando = true);
                try {
                  await RotinasStore.adicionarNoBackend(
                    nome: nome,
                    dispositivoId: dispositivo.id,
                    nomeDispositivo: dispositivo.nome,
                    local: dispositivo.local,
                    horario: horarioSelecionado,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (mounted) _mensagemRotina('Rotina "$nome" salva no backend.');
                } catch (error) {
                  if (dialogContext.mounted) setDialogState(() => salvando = false);
                  if (mounted) _mensagemRotina(error.toString());
                }
              },
              child: Text(salvando ? 'Salvando...' : 'Adicionar'),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  Future<void> _alternarRotina(RotinaItem rotina) async {
    try {
      await RotinasStore.alternarNoBackend(rotina.id);
    } catch (error) {
      if (mounted) _mensagemRotina(error.toString());
    }
  }

  Future<void> _carregarRotinas() async {
    try {
      await RotinasStore.carregarDoBackend();
      if (mounted) {
        _mensagemRotina('${RotinasStore.rotinas.value.length} rotinas sincronizadas.');
      }
    } catch (error) {
      if (mounted) _mensagemRotina(error.toString());
    }
  }

  void _mensagemRotina(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // ============================================================
  // EXECUTAR ROTINA
  // ============================================================

  void _executarRotina(String id) {
    final rotina = RotinasStore.porId(id);
    if (rotina == null) return;
    if (!rotina.ativa) {
      _mensagemRotina('Ative esta rotina antes de executá-la.');
      return;
    }
    _mensagemRotina(
      'A rotina está salva no backend, mas a API ainda não disponibiliza a execução física dos comandos.',
    );
  }
}
