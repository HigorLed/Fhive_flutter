import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
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
  _AcaoForm({String horario = '08:00', this.tipo = 'ligar', String nome = '', String descricao = ''})
      : horario = horario,
        nome = TextEditingController(text: nome),
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

  @override
  Widget build(BuildContext context) {
    final aparelhos = AparelhosStore.aparelhos.value;
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar rotina' : 'Nova rotina')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          children: [
            TextField(
              controller: _nome,
              enabled: !_salvando,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome da rotina'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descricao,
              enabled: !_salvando,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _dispositivoId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Aparelho'),
              items: aparelhos
                  .map((a) => DropdownMenuItem<String>(
                        value: a.id,
                        child: Text(a.nome, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: _salvando ? null : (v) => setState(() => _dispositivoId = v),
            ),
            const SizedBox(height: 16),
            const Text('Dias da semana', style: AppTextStyles.bodyBold),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final dia in diasDaSemanaApi)
                  FilterChip(
                    label: Text(rotuloDiaSemana[dia]!),
                    selected: _dias.contains(dia),
                    onSelected: _salvando
                        ? null
                        : (marcado) => setState(() {
                              marcado ? _dias.add(dia) : _dias.remove(dia);
                            }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando
                        ? null
                        : () async {
                            final h = await _escolherHorario(_horarioInicial);
                            if (h != null && mounted) setState(() => _horarioInicial = h);
                          },
                    icon: const Icon(Icons.schedule),
                    label: Text('Início: $_horarioInicial'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando
                        ? null
                        : () async {
                            final h = await _escolherHorario(_horarioFinal);
                            if (h != null && mounted) setState(() => _horarioFinal = h);
                          },
                    icon: const Icon(Icons.schedule),
                    label: Text('Fim: $_horarioFinal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Ações', style: AppTextStyles.bodyBold),
            const SizedBox(height: 8),
            for (var i = 0; i < _acoes.length; i++) _cartaoAcao(i),
            TextButton.icon(
              onPressed: _salvando ? null : _adicionarAcao,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar ação'),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Salvando...' : (_editando ? 'Salvar alterações' : 'Criar rotina')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoAcao(int i) {
    final acao = _acoes[i];
    return Card(
      key: ObjectKey(acao),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Ação ${i + 1}', style: AppTextStyles.bodyBold),
                const Spacer(),
                IconButton(
                  tooltip: 'Subir',
                  onPressed: _salvando || i == 0 ? null : () => _mover(i, -1),
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  tooltip: 'Descer',
                  onPressed: _salvando || i == _acoes.length - 1 ? null : () => _mover(i, 1),
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  tooltip: 'Remover ação',
                  onPressed: _salvando ? null : () => _remover(i),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextField(
              controller: acao.nome,
              enabled: !_salvando,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome da ação'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: acao.descricao,
              enabled: !_salvando,
              decoration: const InputDecoration(labelText: 'Instrução (opcional)'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: acao.tipo,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: rotuloTipoAcao.entries
                  .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: _salvando ? null : (v) => setState(() => acao.tipo = v ?? acao.tipo),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _salvando
                  ? null
                  : () async {
                      final h = await _escolherHorario(acao.horario);
                      if (h != null && mounted) setState(() => acao.horario = h);
                    },
              icon: const Icon(Icons.schedule),
              label: Text('Horário: ${acao.horario}'),
            ),
          ],
        ),
      ),
    );
  }
}
