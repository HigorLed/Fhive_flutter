import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';

/// Abre o cadastro de aparelho como um pop-up integrado ao visual do Fhive.
Future<bool?> mostrarCriarAparelho(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (_) => const TelaCriarAparelho(),
  );
}

class TelaCriarAparelho extends StatefulWidget {
  const TelaCriarAparelho({super.key});

  @override
  State<TelaCriarAparelho> createState() => _TelaCriarAparelhoState();
}

class _TelaCriarAparelhoState extends State<TelaCriarAparelho> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idController = TextEditingController();
  final _fabricanteController = TextEditingController();
  final _modeloController = TextEditingController();
  final _redeController = TextEditingController();
  final _senhaController = TextEditingController();

  int _etapa = 0;
  String _tipoSelecionado = 'TV';
  String _localSelecionado = 'Sala de Estar';
  String _conexaoSelecionada = 'Wi-Fi';
  bool _mostrarSenha = false;
  bool _conexaoTestada = false;

  static const _tipos = [
    'TV',
    'Ar condicionado',
    'Lâmpada',
    'Câmera',
    'Tomada inteligente',
    'Sensor',
    'Outro',
  ];

  static const _locais = [
    'Sala de Estar',
    'Cozinha',
    'Quarto',
    'Banheiro',
    'Escritório',
    'Área externa',
    'Outro local',
  ];

  static const _conexoes = ['Wi-Fi', 'Bluetooth', 'Ethernet'];

  @override
  void dispose() {
    _nomeController.dispose();
    _idController.dispose();
    _fabricanteController.dispose();
    _modeloController.dispose();
    _redeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  IconData get _iconeSelecionado => switch (_tipoSelecionado) {
        'TV' => Icons.tv,
        'Ar condicionado' => Icons.air,
        'Lâmpada' => Icons.lightbulb_outline,
        'Câmera' => Icons.videocam_outlined,
        'Tomada inteligente' => Icons.power,
        'Sensor' => Icons.sensors_outlined,
        _ => Icons.devices_other,
      };

  String get _tituloEtapa => switch (_etapa) {
        0 => 'Identifique o aparelho',
        1 => 'Conte mais sobre ele',
        2 => 'Configure a conexão',
        _ => 'Revise o cadastro',
      };

  String get _descricaoEtapa => switch (_etapa) {
        0 => 'Dê um nome para encontrar o dispositivo depois e informe o ID único dele.',
        1 => 'Esses dados ajudam a organizar sua casa inteligente.',
        2 => 'Escolha como o dispositivo será conectado à sua rede.',
        _ => 'Confira as informações antes de adicionar o aparelho à sua casa.',
      };

  bool _validarEtapaAtual() {
    if (_etapa == 0) {
      final nome = _nomeController.text.trim();
      final id = _idController.text.trim();

      if (nome.isEmpty) {
        _mostrarErro('Digite um nome para o aparelho.');
        return false;
      }
      if (nome.length < 2) {
        _mostrarErro('O nome do aparelho deve ter pelo menos 2 caracteres.');
        return false;
      }
      if (AparelhosStore.nomeJaCadastrado(nome)) {
        _mostrarErro('Já existe um aparelho com esse nome.');
        return false;
      }
      if (id.isEmpty) {
        _mostrarErro('Informe o ID do dispositivo.');
        return false;
      }
      if (!RegExp(r'^[A-Za-z0-9_-]{4,32}$').hasMatch(id)) {
        _mostrarErro('O ID deve ter de 4 a 32 caracteres: letras, números, _ ou -.');
        return false;
      }
      if (AparelhosStore.idJaCadastrado(id)) {
        _mostrarErro('Esse ID de dispositivo já está cadastrado.');
        return false;
      }
    }

    if (_etapa == 1) {
      if (_localSelecionado.isEmpty) {
        _mostrarErro('Selecione o local do aparelho.');
        return false;
      }
    }

    if (_etapa == 2) {
      if (_conexaoSelecionada == 'Wi-Fi') {
        if (_redeController.text.trim().isEmpty) {
          _mostrarErro('Informe o nome da rede Wi-Fi.');
          return false;
        }
        if (_senhaController.text.trim().length < 8) {
          _mostrarErro('A senha do Wi-Fi deve ter pelo menos 8 caracteres.');
          return false;
        }
      }
    }

    return true;
  }

  void _avancar() {
    if (!_validarEtapaAtual()) return;

    if (_etapa < 3) {
      setState(() => _etapa++);
      return;
    }

    _criarAparelho();
  }

  void _voltar() {
    if (_etapa == 0) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _etapa--);
  }

  void _criarAparelho() {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text.trim();
    final id = _idController.text.trim();

    if (AparelhosStore.nomeJaCadastrado(nome)) {
      setState(() => _etapa = 0);
      _mostrarErro('Já existe um aparelho com esse nome.');
      return;
    }

    if (AparelhosStore.idJaCadastrado(id)) {
      setState(() => _etapa = 0);
      _mostrarErro('Esse ID de dispositivo já está cadastrado.');
      return;
    }

    final conectado = _conexaoTestada;

    AparelhosStore.adicionar(
      AparelhoItem(
        nome: nome,
        id: id,
        tipo: _tipoSelecionado,
        fabricante: _fabricanteController.text.trim().isEmpty
            ? 'Não informado'
            : _fabricanteController.text.trim(),
        modelo: _modeloController.text.trim().isEmpty
            ? 'Não informado'
            : _modeloController.text.trim(),
        status: conectado ? 'Online' : 'Aguardando conexão',
        icone: _iconeSelecionado,
        wifi: conectado && _conexaoSelecionada == 'Wi-Fi',
        local: _localSelecionado,
        conexao: _conexaoSelecionada,
      ),
    );

    Navigator.of(context).pop(true);
  }

  void _testarConexao() {
    if (_conexaoSelecionada == 'Wi-Fi' &&
        (_redeController.text.trim().isEmpty ||
            _senhaController.text.trim().length < 8)) {
      _mostrarErro('Preencha a rede e a senha antes de testar a conexão.');
      return;
    }

    setState(() => _conexaoTestada = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Conexão $_conexaoSelecionada configurada para o cadastro. '
          'O pareamento real depende do hardware e da integração IoT.',
        ),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  InputDecoration _decoracaoCampo({
    required String label,
    required IconData icone,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      hintStyle: const TextStyle(
        color: AppColors.primaryDark,
        fontFamily: 'Montserrat',
        fontSize: 12.5,
      ),
      prefixIcon: Icon(icone, color: AppColors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.devices_other_rounded,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Adicionar aparelho',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Arvo',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                tooltip: 'Fechar',
                icon: const Icon(Icons.close_rounded, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 5,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index <= _etapa
                        ? AppColors.accent
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Etapa ${_etapa + 1} de 4',
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Montserrat',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _intro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primary, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tituloEtapa,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _descricaoEtapa,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontFamily: 'Montserrat',
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudoEtapa() {
    switch (_etapa) {
      case 0:
        return _etapaIdentificacao();
      case 1:
        return _etapaCaracteristicas();
      case 2:
        return _etapaConexao();
      default:
        return _etapaRevisao();
    }
  }

  Widget _etapaIdentificacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nomeController,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: 'Montserrat',
          ),
          decoration: _decoracaoCampo(
            label: 'Nome do dispositivo',
            hint: 'Ex.: TV da sala',
            icone: Icons.drive_file_rename_outline,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _idController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: 'Montserrat',
            letterSpacing: 0.5,
          ),
          decoration: _decoracaoCampo(
            label: 'ID do dispositivo',
            hint: 'Ex.: FH-TV-CRISTAL-001',
            icone: Icons.fingerprint_rounded,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'O ID identifica o aparelho dentro do sistema. Use o número de série, MAC ou identificador fornecido pelo fabricante.',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontFamily: 'Montserrat',
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _etapaCaracteristicas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _tipoSelecionado,
          dropdownColor: AppColors.surfaceLight,
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: 'Montserrat',
          ),
          decoration: _decoracaoCampo(
            label: 'Tipo de aparelho',
            icone: Icons.category_outlined,
          ),
          items: _tipos
              .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
              .toList(),
          onChanged: (valor) {
            if (valor != null) {
              setState(() => _tipoSelecionado = valor);
            }
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fabricanteController,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Montserrat',
                ),
                decoration: _decoracaoCampo(
                  label: 'Fabricante',
                  hint: 'Opcional',
                  icone: Icons.factory_outlined,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _modeloController,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Montserrat',
                ),
                decoration: _decoracaoCampo(
                  label: 'Modelo',
                  hint: 'Opcional',
                  icone: Icons.inventory_2_outlined,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _localSelecionado,
          dropdownColor: AppColors.surfaceLight,
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: 'Montserrat',
          ),
          decoration: _decoracaoCampo(
            label: 'Local do aparelho',
            icone: Icons.location_on_outlined,
          ),
          items: _locais
              .map((local) => DropdownMenuItem(value: local, child: Text(local)))
              .toList(),
          onChanged: (valor) {
            if (valor != null) {
              setState(() => _localSelecionado = valor);
            }
          },
        ),
      ],
    );
  }

  Widget _cartaoConexao({required String tipo, required IconData icone}) {
    final selecionado = _conexaoSelecionada == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _conexaoSelecionada = tipo;
            _conexaoTestada = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
          decoration: BoxDecoration(
            color: selecionado ? AppColors.accent : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selecionado ? AppColors.primary : Colors.transparent,
              width: 1.3,
            ),
          ),
          child: Column(
            children: [
              Icon(icone, color: AppColors.primary, size: 26),
              const SizedBox(height: 7),
              Text(
                tipo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Montserrat',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _etapaConexao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final conexao in _conexoes) ...[
              _cartaoConexao(
                tipo: conexao,
                icone: switch (conexao) {
                  'Wi-Fi' => Icons.wifi_rounded,
                  'Bluetooth' => Icons.bluetooth_rounded,
                  _ => Icons.lan_outlined,
                },
              ),
              if (conexao != _conexoes.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 15),
        if (_conexaoSelecionada == 'Wi-Fi') ...[
          TextFormField(
            controller: _redeController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'Montserrat',
            ),
            decoration: _decoracaoCampo(
              label: 'Nome da rede Wi-Fi',
              hint: 'Ex.: MinhaCasa_5G',
              icone: Icons.router_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _senhaController,
            obscureText: !_mostrarSenha,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'Montserrat',
            ),
            decoration: _decoracaoCampo(
              label: 'Senha da rede',
              icone: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                icon: Icon(
                  _mostrarSenha ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _conexaoSelecionada == 'Bluetooth'
                      ? Icons.bluetooth_connected
                      : Icons.cable_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _conexaoSelecionada == 'Bluetooth'
                        ? 'Use esta opção para aparelhos que realizam o pareamento local por Bluetooth.'
                        : 'Use esta opção quando o aparelho já estiver ligado à rede por cabo Ethernet.',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontFamily: 'Montserrat',
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _conexaoTestada
                ? AppColors.accent.withValues(alpha: 0.7)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                _conexaoTestada ? Icons.check_circle : Icons.wifi_find_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _conexaoTestada
                      ? 'Configuração de conexão pronta para o cadastro.'
                      : 'Teste a configuração antes de finalizar.',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Montserrat',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: _testarConexao,
                child: Text(
                  _conexaoTestada ? 'Testado' : 'Testar',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Nesta versão do projeto, o teste confirma somente a configuração preenchida. O pareamento físico com um dispositivo depende da integração com o hardware e do protocolo escolhido.',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontFamily: 'Montserrat',
            fontSize: 10.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _linhaResumo(String titulo, String valor, {IconData? icone}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone ?? Icons.check_circle_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontFamily: 'Montserrat',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etapaRevisao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surfaceStrong,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(_iconeSelecionado, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nomeController.text.trim().isEmpty
                          ? 'Novo aparelho'
                          : _nomeController.text.trim(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _idController.text.trim(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _linhaResumo('Tipo', _tipoSelecionado, icone: Icons.category_outlined),
        _linhaResumo(
          'Fabricante',
          _fabricanteController.text.trim().isEmpty
              ? 'Não informado'
              : _fabricanteController.text.trim(),
          icone: Icons.factory_outlined,
        ),
        _linhaResumo(
          'Modelo',
          _modeloController.text.trim().isEmpty
              ? 'Não informado'
              : _modeloController.text.trim(),
          icone: Icons.inventory_2_outlined,
        ),
        _linhaResumo('Local', _localSelecionado, icone: Icons.location_on_outlined),
        _linhaResumo('Conexão', _conexaoSelecionada, icone: Icons.wifi_rounded),
        _linhaResumo(
          'Status inicial',
          _conexaoTestada ? 'Online' : 'Aguardando conexão',
          icone: _conexaoTestada ? Icons.cloud_done : Icons.cloud_off_outlined,
        ),
        const SizedBox(height: 4),
        const Text(
          'Ao adicionar, o aparelho passa a aparecer na lista da casa e poderá ser acessado pelos detalhes do dispositivo.',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontFamily: 'Montserrat',
            fontSize: 10.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 470,
          maxHeight: tamanho.height * 0.90,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _cabecalho(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _intro(),
                          const SizedBox(height: 16),
                          _conteudoEtapa(),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final botoes = <Widget>[
                        if (_etapa > 0)
                          OutlinedButton.icon(
                            onPressed: _voltar,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Voltar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: _avancar,
                          icon: Icon(
                            _etapa == 3
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            _etapa == 3 ? 'Adicionar aparelho' : 'Continuar',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ];

                      return Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: botoes,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
