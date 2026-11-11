import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/features/routines/presentation/formulario_rotina.dart';

class TelaRotinas extends StatefulWidget {
  const TelaRotinas({super.key});

  @override
  State<TelaRotinas> createState() => _TelaRotinasState();
}

class _TelaRotinasState extends State<TelaRotinas> {
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
                        const SizedBox(height: AppSpacing.section),
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
    final borda = BorderRadius.circular(AppRadius.chip);
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: borda,
      child: InkWell(
        borderRadius: borda,
        onTap: _selecionarLocal,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(localSelecionado, style: AppTextStyles.bodyBold),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botaoAdicionarRotina() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _adicionarRotina,
        icon: const Icon(Icons.add_rounded),
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

        if (filtradas.isEmpty) return _estadoVazio();

        final ativas = filtradas.where((r) => r.ativa).length;
        final total = filtradas.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$total ${total == 1 ? 'rotina' : 'rotinas'} · '
              '$ativas ${ativas == 1 ? 'ativa' : 'ativas'}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final rotina in filtradas) ...[
              _cardRotina(rotina),
              const SizedBox(height: AppSpacing.cardGap),
            ],
          ],
        );
      },
    );
  }

  Widget _estadoVazio() {
    return CartaoFhive(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Icon(Icons.event_repeat_outlined, size: 36),
            const SizedBox(height: AppSpacing.md),
            const Text('Nenhuma rotina por aqui', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Nenhuma rotina cadastrada para este local.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD ROTINA
  // ============================================================

  String _textoDias(List<String> dias) {
    if (dias.isEmpty) return '';
    if (dias.length == 7) return 'Todos os dias';
    final ordenados = diasDaSemanaApi.where(dias.contains).toList();
    final lista = ordenados.isEmpty ? dias : ordenados;
    return lista.map((d) => rotuloDiaSemana[d] ?? d).join(', ');
  }

  Widget _cardRotina(RotinaItem rotina) {
    final ativa = rotina.ativa;
    final subtitulo = <String>[
      if (rotina.nomeDispositivo.isNotEmpty) rotina.nomeDispositivo,
      if (rotina.local.isNotEmpty && rotina.local != 'Locais') rotina.local,
    ].join(' · ');
    final dias = _textoDias(rotina.dias);

    return Opacity(
      opacity: ativa ? 1 : 0.7,
      child: CartaoFhive(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
        ),
        onTap: () => _editarRotina(rotina),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ativa ? AppColors.accent : AppColors.track,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: const Icon(Icons.schedule_rounded, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rotina.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle,
                      ),
                      if (subtitulo.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _botaoExecutar(rotina),
                _menuRotina(rotina),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _chipStatus(ativa),
                  if (rotina.horario.isNotEmpty)
                    _chipInfo(Icons.access_time_rounded, rotina.horario),
                  if (dias.isNotEmpty)
                    _chipInfo(Icons.calendar_today_outlined, dias),
                  if (rotina.acoes.isNotEmpty)
                    _chipInfo(
                      Icons.bolt_outlined,
                      '${rotina.acoes.length} '
                      '${rotina.acoes.length == 1 ? 'ação' : 'ações'}',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoExecutar(RotinaItem rotina) {
    return Tooltip(
      message: rotina.ativa ? 'Executar rotina' : 'Rotina desativada',
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _executarRotina(rotina.id),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.play_arrow_rounded,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuRotina(RotinaItem rotina) {
    return PopupMenuButton<String>(
      tooltip: 'Opções da rotina',
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert_rounded, size: 22),
      onSelected: (acao) {
        if (acao == 'editar') {
          _editarRotina(rotina);
        } else if (acao == 'alternar') {
          _alternarRotina(rotina);
        } else if (acao == 'remover') {
          _confirmarRemocaoRotina(rotina);
        }
      },
      itemBuilder: (_) => [
        _itemMenu('editar', Icons.edit_outlined, 'Editar rotina'),
        _itemMenu(
          'alternar',
          rotina.ativa
              ? Icons.pause_circle_outline_rounded
              : Icons.check_circle_outline_rounded,
          rotina.ativa ? 'Desativar rotina' : 'Ativar rotina',
        ),
        _itemMenu(
          'remover',
          Icons.delete_outline_rounded,
          'Remover rotina',
          cor: AppColors.danger,
        ),
      ],
    );
  }

  PopupMenuItem<String> _itemMenu(
    String valor,
    IconData icone,
    String texto, {
    Color cor = AppColors.primary,
  }) {
    return PopupMenuItem<String>(
      value: valor,
      child: Row(
        children: [
          Icon(icone, size: 20, color: cor),
          const SizedBox(width: AppSpacing.md),
          Text(texto, style: AppTextStyles.body.copyWith(color: cor)),
        ],
      ),
    );
  }

  Widget _chipStatus(bool ativa) {
    final cor = ativa ? AppColors.success : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ativa ? AppColors.successSoft : AppColors.track,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            ativa ? 'Ativa' : 'Desativada',
            style: AppTextStyles.caption.copyWith(
              color: cor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipInfo(IconData icone, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
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
        contentPadding: EdgeInsets.zero,
        title: Text(nome, style: AppTextStyles.bodyBold),
        trailing: nome == localSelecionado
            ? const Icon(Icons.check_rounded)
            : null,
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

  Future<void> _adicionarRotina() async {
    if (AparelhosStore.aparelhos.value.isEmpty) {
      _mensagemRotina('Cadastre um aparelho antes de criar uma rotina.');
      return;
    }
    final salvou = await TelaFormularioRotina.abrir(context);
    if (mounted && salvou == true) _mensagemRotina('Rotina salva.');
  }

  Future<void> _editarRotina(RotinaItem rotina) async {
    final salvou = await TelaFormularioRotina.abrir(context, rotina: rotina);
    if (mounted && salvou == true) _mensagemRotina('Rotina atualizada.');
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