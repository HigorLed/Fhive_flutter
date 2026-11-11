import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

/// Formulário de criação/edição de rotina, equivalente ao da versão web:
/// nome, descrição, aparelho, dias da semana, janela de horário e ações em
/// sequência. Salva via POST /rotinas (nova) ou PUT /rotinas/:id (edição).
class TelaFormularioRotina extends StatefulWidget {
  const TelaFormularioRotina({super.key, this.rotina});

  final RotinaItem? rotina;

  static Future<bool?> abrir(BuildContext context, {RotinaItem? rotina}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => TelaFormularioRotina(rotina: rotina)),
    );
  }

  @override
  State<TelaFormularioRotina> createState() => _TelaFormularioRotinaState();
}

class _AcaoForm {
  _AcaoForm({this.horario = '08:00', this.tipo = 'ligar', String nome = '', String descricao = ''})
      : nome = TextEditingController(text: nome),
        descricao = TextEditingController(text: descricao);

  String horario;
  String tipo;
  final TextEditingController nome;
  final TextEditingController descricao;

  void dispose() {
    nome.dispose();
    descricao.dispose();
  }
}

class _TelaFormularioRotinaState extends State<TelaFormularioRotina> {
  late final TextEditingController _nome =
      TextEditingController(text: widget.rotina?.nome ?? '');
  late final TextEditingController _descricao =
      TextEditingController(text: widget.rotina?.descricao ?? '');
  final List<_AcaoForm> _acoes = <_AcaoForm>[];
  late Set<String> _dias;
  late String _horarioInicial;
  late String _horarioFinal;
  String? _dispositivoId;
  String? _erro;
  bool _salvando = false;

  bool get _editando => widget.rotina != null;

  @override
  void initState() {
    super.initState();
    final r = widget.rotina;
    _horarioInicial = (r != null && r.horarioInicial.isNotEmpty) ? r.horarioInicial : '08:00';
    _horarioFinal = (r != null && r.horarioFinal.isNotEmpty) ? r.horarioFinal : '17:00';
    _dias = (r != null && r.dias.isNotEmpty)
        ? r.dias.toSet()
        : <String>{'segunda', 'terca', 'quarta', 'quinta', 'sexta'};
    if (r != null && r.acoesDetalhe.isNotEmpty) {
      for (final a in r.acoesDetalhe) {
        _acoes.add(_AcaoForm(
          horario: a.horario.isEmpty ? _horarioInicial : a.horario,
          tipo: rotuloTipoAcao.containsKey(a.tipo) ? a.tipo : 'alterar_estado',
          nome: a.nome,
          descricao: a.descricao,
        ));
      }
    } else {
      _acoes.add(_AcaoForm(horario: _horarioInicial));
    }
    final aparelhos = AparelhosStore.aparelhos.value;
    final alvo = r?.dispositivoId;
    if (alvo != null && aparelhos.any((a) => a.id == alvo)) {
      _dispositivoId = alvo;
    } else if (aparelhos.isNotEmpty) {
      _dispositivoId = aparelhos.first.id;
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    for (final acao in _acoes) {
      acao.dispose();
    }
    super.dispose();
  }

  Future<String?> _escolherHorario(String atual) async {
    final partes = atual.split(':');
    final escolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(partes.first) ?? 8,
        minute: partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0,
      ),
    );
    if (escolhido == null) return null;
    return '${escolhido.hour.toString().padLeft(2, '0')}:'
        '${escolhido.minute.toString().padLeft(2, '0')}';
  }

  /// Mesmas regras de validação do formulário web.
  String? _validar() {
    if (_nome.text.trim().isEmpty) return 'Informe um nome para a rotina.';
    if (_dispositivoId == null) return 'Cadastre um aparelho antes de criar uma rotina.';
    if (_dias.isEmpty) return 'Selecione pelo menos um dia da semana.';
    if (_horarioFinal.compareTo(_horarioInicial) <= 0) {
      return 'O horário final precisa ser posterior ao inicial.';
    }
    if (_acoes.isEmpty) return 'Adicione pelo menos uma ação à rotina.';
    for (var i = 0; i < _acoes.length; i++) {
      final acao = _acoes[i];
      if (acao.nome.text.trim().isEmpty) return 'Informe o nome da ação ${i + 1}.';
      if (acao.horario.compareTo(_horarioInicial) < 0 ||
          acao.horario.compareTo(_horarioFinal) > 0) {
        return 'A ação ${i + 1} precisa ficar entre o início e o fim da rotina.';
      }
      if (i > 0 && acao.horario.compareTo(_acoes[i - 1].horario) < 0) {
        return 'As ações precisam estar em ordem cronológica. Use as setas para reorganizar.';
      }
    }
    return null;
  }

  Future<void> _salvar() async {
    final erro = _validar();
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    final aparelho = AparelhosStore.aparelhos.value.firstWhere((a) => a.id == _dispositivoId);
    setState(() {
      _erro = null;
      _salvando = true;
    });
    try {
      await RotinasStore.salvarNoBackend(
        id: widget.rotina?.id,
        nome: _nome.text,
        descricao: _descricao.text,
        dispositivoId: aparelho.id,
        nomeDispositivo: aparelho.nome,
        local: aparelho.local,
        horarioInicial: _horarioInicial,
        horarioFinal: _horarioFinal,
        dias: <String>[for (final d in diasDaSemanaApi) if (_dias.contains(d)) d],
        acoes: <AcaoRotina>[
          for (final a in _acoes)
            AcaoRotina(
              horario: a.horario,
              tipo: a.tipo,
              nome: a.nome.text,
              descricao: a.descricao.text,
            ),
        ],
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = '$error'.replaceFirst('Exception: ', '');
      });
    }
  }

  void _mover(int indice, int delta) {
    final destino = indice + delta;
    if (destino < 0 || destino >= _acoes.length) return;
    setState(() {
      final item = _acoes.removeAt(indice);
      _acoes.insert(destino, item);
    });
  }

  void _remover(int indice) {
    setState(() => _acoes.removeAt(indice).dispose());
  }

  void _adicionarAcao() {
    setState(() => _acoes.add(_AcaoForm(horario: _acoes.isEmpty ? _horarioInicial : _acoes.last.horario)));
  }

  static const Map<String, IconData> _iconeTipo = <String, IconData>{
    'ligar': Icons.power_settings_new_rounded,
    'desligar': Icons.power_off_outlined,
    'alterar_estado': Icons.swap_horiz_rounded,
  };

  Future<void> _editarHorarioInicial() async {
    final h = await _escolherHorario(_horarioInicial);
    if (h != null && mounted) setState(() => _horarioInicial = h);
  }

  Future<void> _editarHorarioFinal() async {
    final h = await _escolherHorario(_horarioFinal);
    if (h != null && mounted) setState(() => _horarioFinal = h);
  }

  @override
  Widget build(BuildContext context) {
    final aparelhos = AparelhosStore.aparelhos.value;
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar rotina' : 'Nova rotina')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageBottom,
                  ),
                  children: [
                    _secaoInformacoes(aparelhos),
                    const SizedBox(height: AppSpacing.cardGap),
                    _secaoQuando(),
                    const SizedBox(height: AppSpacing.section),
                    _secaoAcoes(),
                  ],
                ),
              ),
              _barraSalvar(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEÇÕES
  // ============================================================

  Widget _tituloCartao(IconData icone, String titulo) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Icon(icone, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(titulo, style: AppTextStyles.cardTitle)),
      ],
    );
  }

  Widget _secaoInformacoes(List<AparelhoItem> aparelhos) {
    return CartaoFhive(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tituloCartao(Icons.edit_note_rounded, 'Informações'),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _nome,
            enabled: !_salvando,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome da rotina',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descricao,
            enabled: !_salvando,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _dispositivoId,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(AppRadius.button),
            dropdownColor: AppColors.surfaceLight,
            decoration: const InputDecoration(
              labelText: 'Aparelho',
              prefixIcon: Icon(Icons.devices_other_rounded),
            ),
            items: aparelhos
                .map((a) => DropdownMenuItem<String>(
                      value: a.id,
                      child: Text(a.nome, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: _salvando ? null : (v) => setState(() => _dispositivoId = v),
          ),
        ],
      ),
    );
  }

  Widget _secaoQuando() {
    return CartaoFhive(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tituloCartao(Icons.event_repeat_rounded, 'Quando executar'),
          const SizedBox(height: AppSpacing.lg),
          const Text('Dias da semana', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < diasDaSemanaApi.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(child: _chipDia(diasDaSemanaApi[i])),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Janela de horário', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _tileHorario(
                  rotulo: 'Início',
                  valor: _horarioInicial,
                  onTap: _salvando ? null : _editarHorarioInicial,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.arrow_forward_rounded, size: 20),
              ),
              Expanded(
                child: _tileHorario(
                  rotulo: 'Fim',
                  valor: _horarioFinal,
                  onTap: _salvando ? null : _editarHorarioFinal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secaoAcoes() {
    final total = _acoes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloSecao(
          titulo: 'Ações',
          trailing: Text(
            '$total ${total == 1 ? 'ação' : 'ações'}',
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < _acoes.length; i++) ...[
          _cartaoAcao(i),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        OutlinedButton.icon(
          onPressed: _salvando ? null : _adicionarAcao,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Adicionar ação'),
        ),
      ],
    );
  }

  Widget _barraSalvar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_erro != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 20, color: AppColors.danger),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _erro!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          FilledButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.white,
                    ),
                  )
                : Text(_editando ? 'Salvar alterações' : 'Criar rotina'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPONENTES
  // ============================================================

  Widget _chipDia(String dia) {
    final marcado = _dias.contains(dia);
    final borda = BorderRadius.circular(AppRadius.chip);
    return Material(
      color: marcado ? AppColors.primary : AppColors.surface,
      borderRadius: borda,
      child: InkWell(
        borderRadius: borda,
        onTap: _salvando
            ? null
            : () => setState(() {
                  marcado ? _dias.remove(dia) : _dias.add(dia);
                }),
        child: SizedBox(
          height: 42,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                rotuloDiaSemana[dia]!,
                style: AppTextStyles.caption.copyWith(
                  color: marcado ? AppColors.white : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tileHorario({
    required String rotulo,
    required String valor,
    required VoidCallback? onTap,
  }) {
    final borda = BorderRadius.circular(AppRadius.button);
    return Material(
      color: AppColors.input,
      borderRadius: borda,
      child: InkWell(
        borderRadius: borda,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rotulo, style: AppTextStyles.caption),
                    Text(valor, style: AppTextStyles.sectionTitle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartaoAcao(int i) {
    final acao = _acoes[i];
    return CartaoFhive(
      key: ObjectKey(acao),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(child: Text('Ação', style: AppTextStyles.cardTitle)),
              IconButton(
                tooltip: 'Subir',
                visualDensity: VisualDensity.compact,
                onPressed: _salvando || i == 0 ? null : () => _mover(i, -1),
                icon: const Icon(Icons.arrow_upward_rounded, size: 22),
              ),
              IconButton(
                tooltip: 'Descer',
                visualDensity: VisualDensity.compact,
                onPressed:
                    _salvando || i == _acoes.length - 1 ? null : () => _mover(i, 1),
                icon: const Icon(Icons.arrow_downward_rounded, size: 22),
              ),
              IconButton(
                tooltip: 'Remover ação',
                visualDensity: VisualDensity.compact,
                onPressed: _salvando ? null : () => _remover(i),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 22, color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: acao.nome,
            enabled: !_salvando,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome da ação',
              prefixIcon: Icon(Icons.bolt_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: acao.descricao,
            enabled: !_salvando,
            decoration: const InputDecoration(
              labelText: 'Instrução (opcional)',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Tipo de ação', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final e in rotuloTipoAcao.entries)
                ChoiceChip(
                  avatar: Icon(_iconeTipo[e.key] ?? Icons.tune_rounded, size: 16),
                  label: Text(e.value),
                  selected: acao.tipo == e.key,
                  showCheckmark: false,
                  backgroundColor: AppColors.surface,
                  onSelected:
                      _salvando ? null : (_) => setState(() => acao.tipo = e.key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _tileHorario(
            rotulo: 'Horário da ação',
            valor: acao.horario,
            onTap: _salvando
                ? null
                : () async {
                    final h = await _escolherHorario(acao.horario);
                    if (h != null && mounted) setState(() => acao.horario = h);
                  },
          ),
        ],
      ),
    );
  }
}