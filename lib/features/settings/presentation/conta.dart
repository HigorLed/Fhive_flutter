import 'dart:async';

import 'package:flutter/material.dart';
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
          backgroundColor: erro ? AppColors.danger : AppColors.primary,
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
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.backgroundTop,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
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
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _cartaoPerfil(conta),
                    const SizedBox(height: 16),
                    _cartaoDadosPessoais(conta),
                    const SizedBox(height: 14),
                    _cartaoSeguranca(conta),
                    const SizedBox(height: 14),
                    const Text(
                      'Os dados do perfil são salvos no backend Fhive. A sessão é encerrada ao sair do aplicativo; autenticação biométrica e armazenamento local seguro ainda não estão integrados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 11,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 43,
            backgroundColor: AppColors.accent,
            child: Text(
              _iniciais(nome),
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: AppFonts.title,
                fontSize: 27,
                fontWeight: FontWeight.w900,
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
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(20),
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
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.25,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoSeguranca(ContaLocal? conta) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey<String>('perfil-seguranca'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.lock_rounded, color: AppColors.primary),
          ),
          title: const Text(
            'Segurança',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: const Text(
            'Altere sua senha de acesso',
            style: TextStyle(color: AppColors.primaryDark, fontSize: 11),
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
                    autofillHints: const [AutofillHints.password],
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
                  fontSize: 11,
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
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
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
        color: AppColors.surfaceLight.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(13),
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
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 11,
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
