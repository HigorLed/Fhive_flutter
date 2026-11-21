import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';

class TelaConta extends StatefulWidget {
  const TelaConta({super.key});

  @override
  State<TelaConta> createState() => _TelaContaState();
}

class _TelaContaState extends State<TelaConta> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _formPerfilKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _inicializado = false;
  bool _mostrarSenhaAtual = false;
  bool _mostrarNovaSenha = false;
  bool _mostrarConfirmarSenha = false;
  final _formSegurancaKey = GlobalKey<FormState>();
  final ImagePicker _seletorImagem = ImagePicker();
  bool _alterandoFoto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      final conta = AuthStore.usuarioAtual.value;
      _nomeController.text = conta?.nome ?? '';
      _emailController.text = conta?.email ?? '';
      _inicializado = true;
      unawaited(_carregarPerfilRemoto());
    }
  }

  Future<void> _carregarPerfilRemoto() async {
    final erro = await AuthStore.carregarPerfil();
    if (!mounted || erro != null) return;
    final conta = AuthStore.usuarioAtual.value;
    if (conta == null) return;
    setState(() {
      _nomeController.text = conta.nome;
      _emailController.text = conta.email;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _mensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: erro ? AppColors.danger : null,
        ),
      );
  }

  Future<void> _salvarPerfil() async {
    FocusScope.of(context).unfocus();
    if (!(_formPerfilKey.currentState?.validate() ?? false)) return;

    final resultado = await AuthStore.atualizarPerfil(
      nome: _nomeController.text,
      email: _emailController.text,
    );
    if (!mounted) return;
    if (resultado != null) {
      _mensagem(resultado, erro: true);
      return;
    }
    final contaAtualizada = AuthStore.usuarioAtual.value;
    _nomeController.text = contaAtualizada?.nome ?? '';
    _emailController.text = contaAtualizada?.email ?? '';
    FocusScope.of(context).unfocus();
    _mensagem('Perfil atualizado com sucesso.');
  }

  Future<void> _selecionarFotoPerfil() async {
    if (_alterandoFoto) return;
    final conta = AuthStore.usuarioAtual.value;
    if (conta == null) {
      _mensagem('Entre na sua conta para alterar a foto.', erro: true);
      return;
    }

    try {
      final arquivo = await _seletorImagem.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 78,
        requestFullMetadata: false,
      );
      if (arquivo == null || !mounted) return;

      final bytes = await arquivo.readAsBytes();
      const limiteBytes = 2 * 1024 * 1024;
      if (bytes.length > limiteBytes) {
        _mensagem(
          'A imagem ainda ficou maior que 2 MB. Escolha outra foto.',
          erro: true,
        );
        return;
      }

      final extensao = arquivo.name.toLowerCase().split('.').last;
      final mime = arquivo.mimeType ?? switch (extensao) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
      final fotoEmBase64 = 'data:$mime;base64,${base64Encode(bytes)}';

      setState(() => _alterandoFoto = true);
      final resultado = await AuthStore.atualizarPerfil(
        nome: _nomeController.text.trim().isEmpty
            ? conta.nome
            : _nomeController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? conta.email
            : _emailController.text.trim(),
        fotoPerfil: fotoEmBase64,
      );

      if (!mounted) return;
      if (resultado != null) {
        _mensagem(resultado, erro: true);
      } else {
        _mensagem('Foto de perfil atualizada com sucesso.');
      }
    } catch (erro) {
      if (mounted) {
        _mensagem(
          'Não foi possível selecionar ou enviar a foto. Tente novamente.',
          erro: true,
        );
      }
    } finally {
      if (mounted) setState(() => _alterandoFoto = false);
    }
  }

  ImageProvider? _imagemPerfil(ContaLocal? conta) {
    final foto = conta?.fotoPerfil?.trim();
    if (foto == null || foto.isEmpty) return null;

    try {
      if (foto.startsWith('data:')) {
        final separador = foto.indexOf(',');
        if (separador < 0) return null;
        return MemoryImage(base64Decode(foto.substring(separador + 1)));
      }
      if (foto.startsWith('https://') || foto.startsWith('http://')) {
        return NetworkImage(foto);
      }
      return MemoryImage(base64Decode(foto));
    } catch (_) {
      return null;
    }
  }

  Future<void> _alterarSenha() async {
    FocusScope.of(context).unfocus();
    if (!(_formSegurancaKey.currentState?.validate() ?? false)) return;
    if (_novaSenhaController.text != _confirmarSenhaController.text) {
      _mensagem('A confirmação não corresponde à nova senha.', erro: true);
      return;
    }
    final resultado = await AuthStore.atualizarSenha(
      senhaAtual: _senhaAtualController.text,
      novaSenha: _novaSenhaController.text,
    );
    if (!mounted) return;
    if (resultado != null) {
      _mensagem(resultado, erro: true);
      return;
    }
    _senhaAtualController.clear();
    _novaSenhaController.clear();
    _confirmarSenhaController.clear();
    _formSegurancaKey.currentState?.reset();
    FocusScope.of(context).unfocus();
    _mensagem('Senha alterada com sucesso no backend.');
  }

  String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'F';
    String primeiraLetra(String texto) =>
        String.fromCharCode(texto.runes.first).toUpperCase();
    if (partes.length == 1) return primeiraLetra(partes.first);
    return '${primeiraLetra(partes.first)}${primeiraLetra(partes.last)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          top: false,
          child: ValueListenableBuilder<ContaLocal?>(
            valueListenable: AuthStore.usuarioAtual,
            builder: (context, conta, _) {
              if (conta != null &&
                  _nomeController.text.isEmpty &&
                  _emailController.text.isEmpty) {
                _nomeController.text = conta.nome;
                _emailController.text = conta.email;
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _cartaoPerfil(conta),
                    const SizedBox(height: AppSpacing.cardGap),
                    _cartaoDadosPessoais(conta),
                    const SizedBox(height: 14),
                    _cartaoSeguranca(conta),
                    const SizedBox(height: 14),
                    const Text(
                      'Os dados do perfil são salvos no backend Fhive. A sessão é encerrada ao sair do aplicativo; autenticação biométrica e armazenamento local seguro ainda não estão integrados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _cartaoPerfil(ContaLocal? conta) {
    final nome = conta?.nome ?? 'Visitante';
    final email = conta?.email ?? 'Nenhuma conta conectada';
    final imagemPerfil = _imagemPerfil(conta);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: 'Alterar foto de perfil',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: conta == null || _alterandoFoto
                  ? null
                  : _selecionarFotoPerfil,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 43,
                    backgroundColor: AppColors.accent,
                    backgroundImage: imagemPerfil,
                    child: imagemPerfil == null
                        ? Text(
                            _iniciais(nome),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: AppFonts.title,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceLight,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  if (_alterandoFoto)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0x88000000),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: AppFonts.title,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  conta == null ? 'Visitante' : 'Conta Fhive',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoDadosPessoais(ContaLocal? conta) {
    return _cartaoBase(
      titulo: 'Dados pessoais',
      subtitulo: 'Mantenha suas informações atualizadas.',
      icone: Icons.person_rounded,
      child: Form(
        key: _formPerfilKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              enabled: conta != null,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                hintText: 'Como devemos chamar você?',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (valor) {
                final nome = valor?.trim() ?? '';
                if (nome.length < 2) {
                  return 'Informe pelo menos 2 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              enabled: conta != null,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'seuemail@exemplo.com',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (valor) {
                final email = valor?.trim() ?? '';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                    .hasMatch(email)) {
                  return 'Digite um e-mail válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: conta == null ? null : _salvarPerfil,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoSeguranca(ContaLocal? conta) {
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey<String>('perfil-seguranca'),
          maintainState: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: const Icon(Icons.lock_rounded, color: AppColors.primary),
          ),
          title: const Text(
            'Segurança',
            style: AppTextStyles.cardTitle,
          ),
          subtitle: const Text(
            'Altere sua senha de acesso',
            style: TextStyle(color: AppColors.primaryDark, fontSize: 12),
          ),
          children: [
            Form(
              key: _formSegurancaKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _senhaAtualController,
                    enabled: conta != null,
                    obscureText: !_mostrarSenhaAtual,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Senha atual',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _mostrarSenhaAtual
                            ? 'Ocultar senha'
                            : 'Mostrar senha',
                        onPressed: () => setState(
                          () => _mostrarSenhaAtual = !_mostrarSenhaAtual,
                        ),
                        icon: Icon(
                          _mostrarSenhaAtual
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    validator: (valor) => valor == null || valor.isEmpty
                        ? 'Informe sua senha atual.'
                        : null,
                  ),
                  const SizedBox(height: 11),
                  TextFormField(
                    controller: _novaSenhaController,
                    enabled: conta != null,
                    obscureText: !_mostrarNovaSenha,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nova senha',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        tooltip: _mostrarNovaSenha
                            ? 'Ocultar senha'
                            : 'Mostrar senha',
                        onPressed: () => setState(
                          () => _mostrarNovaSenha = !_mostrarNovaSenha,
                        ),
                        icon: Icon(
                          _mostrarNovaSenha
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    validator: (valor) {
                      final senha = valor ?? '';
                      if (senha.length < 8 ||
                          !RegExp(r'[a-z]').hasMatch(senha) ||
                          !RegExp(r'[A-Z]').hasMatch(senha) ||
                          !RegExp(r'\d').hasMatch(senha) ||
                          !RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha)) {
                        return 'Use 8+ caracteres, maiúscula, minúscula, número e símbolo.';
                      }
                      if (senha == _senhaAtualController.text) {
                        return 'Escolha uma senha diferente da atual.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 11),
                  TextFormField(
                    controller: _confirmarSenhaController,
                    enabled: conta != null,
                    obscureText: !_mostrarConfirmarSenha,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nova senha',
                      prefixIcon: const Icon(Icons.verified_user_outlined),
                      suffixIcon: IconButton(
                        tooltip: _mostrarConfirmarSenha
                            ? 'Ocultar senha'
                            : 'Mostrar senha',
                        onPressed: () => setState(
                          () => _mostrarConfirmarSenha =
                              !_mostrarConfirmarSenha,
                        ),
                        icon: Icon(
                          _mostrarConfirmarSenha
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    validator: (valor) =>
                        (valor ?? '') != _novaSenhaController.text
                        ? 'A confirmação não corresponde à nova senha.'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Use pelo menos 8 caracteres, uma maiúscula, uma minúscula, um número e um caractere especial.',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: conta == null ? null : _alterarSenha,
                icon: const Icon(Icons.password_rounded),
                label: const Text('Atualizar senha'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoBase({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(icone, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
