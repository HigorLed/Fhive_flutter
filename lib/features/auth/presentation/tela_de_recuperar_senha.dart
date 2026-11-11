import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/widgets/logo_fhive.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';

/// Etapas da recuperação:
/// 1. [email]  -> o usuário informa o e-mail e recebe o código.
/// 2. [codigo] -> o usuário informa o código e define a nova senha.
enum _Etapa { email, codigo }

/// Tela de recuperação de senha.
///
/// Rota: '/recuperar-senha'. Aceita o e-mail já digitado no login como
/// `arguments` (String) e, ao redefinir com sucesso, faz `pop(true)`.
class TelaDeRecuperarSenha extends StatefulWidget {
  const TelaDeRecuperarSenha({super.key});

  @override
  State<TelaDeRecuperarSenha> createState() => _TelaDeRecuperarSenhaState();
}

class _TelaDeRecuperarSenhaState extends State<TelaDeRecuperarSenha> {
  static const int _segundosParaReenviar = 30;
  static final RegExp _regexEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _Etapa etapa = _Etapa.email;
  bool carregando = false;
  bool mostrarSenha = false;
  bool mostrarConfirmacao = false;
  bool _argumentosLidos = false;

  Timer? _timer;
  int _segundosRestantes = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preenche o e-mail com o que o usuário já digitou na tela de login.
    if (!_argumentosLidos) {
      _argumentosLidos = true;
      final argumento = ModalRoute.of(context)?.settings.arguments;
      if (argumento is String) emailController.text = argumento;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    codigoController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // =========================================================
  // VALIDAÇÕES
  // =========================================================

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) return 'Digite seu email';
    if (!_regexEmail.hasMatch(email)) return 'Digite um email válido';
    return null;
  }

  String? _validarSenha(String? valor) {
    final senha = valor ?? '';
    if (senha.length < 8 ||
        !RegExp(r'[a-z]').hasMatch(senha) ||
        !RegExp(r'[A-Z]').hasMatch(senha) ||
        !RegExp(r'\d').hasMatch(senha) ||
        !RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha)) {
      return 'A senha não atende aos requisitos.';
    }
    return null;
  }

  // =========================================================
  // AÇÕES
  // =========================================================

  void _iniciarContagemReenvio() {
    _timer?.cancel();
    setState(() => _segundosRestantes = _segundosParaReenviar);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _segundosRestantes--);
      if (_segundosRestantes <= 0) timer.cancel();
    });
  }

  /// Etapa 1: solicita o envio do código por e-mail.
  /// Também é usada pelo "Reenviar código" na etapa 2.
  Future<void> _solicitarCodigo({bool reenvio = false}) async {
    FocusScope.of(context).unfocus();
    if (carregando) return;
    if (!reenvio && !_formKey.currentState!.validate()) return;

    setState(() => carregando = true);
    try {
      final erro = await AuthStore.solicitarRecuperacao(
        email: emailController.text.trim(),
      );
      if (!mounted) return;
      if (erro != null) {
        _mensagem(erro);
        return;
      }
      _mensagem('Se o e-mail estiver cadastrado, o código de recuperação será enviado.');
      setState(() => etapa = _Etapa.codigo);
      _iniciarContagemReenvio();
    } catch (_) {
      if (mounted) _mensagem('Não foi possível enviar o código. Tente novamente.');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  /// Etapa 2: verifica o código e redefine a senha.
  Future<void> _redefinirSenha() async {
    FocusScope.of(context).unfocus();
    if (carregando || !_formKey.currentState!.validate()) return;

    setState(() => carregando = true);
    try {
      final email = emailController.text.trim();
      final codigo = codigoController.text.trim();

      final erroCodigo = await AuthStore.verificarCodigoRecuperacao(
        email: email,
        codigo: codigo,
      );
      if (!mounted) return;
      if (erroCodigo != null) {
        _mensagem(erroCodigo);
        return;
      }

      final erroSenha = await AuthStore.redefinirSenha(
        email: email,
        codigo: codigo,
        novaSenha: novaSenhaController.text,
      );
      if (!mounted) return;
      if (erroSenha != null) {
        _mensagem(erroSenha);
        return;
      }

      // Volta para o login; ele mostra a mensagem de sucesso.
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        _mensagem('Não foi possível concluir a recuperação. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void _alterarEmail() {
    _timer?.cancel();
    setState(() {
      etapa = _Etapa.email;
      _segundosRestantes = 0;
      codigoController.clear();
      novaSenhaController.clear();
      confirmarSenhaController.clear();
    });
  }

  // =========================================================
  // COMPONENTES
  // =========================================================

  Widget _rotulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(texto, style: AppTextStyles.bodyBold),
    );
  }

  InputDecoration _decoracao({
    required String hint,
    required IconData icone,
    Widget? sufixo,
    String? ajuda,
  }) {
    // Cor de fundo e bordas vêm do inputDecorationTheme (core/theme).
    return InputDecoration(
      hintText: hint,
      helperText: ajuda,
      helperMaxLines: 2,
      prefixIcon: Icon(icone, size: 20),
      suffixIcon: sufixo,
    );
  }

  Widget _botaoOlho({required bool visivel, required VoidCallback aoTocar}) {
    return IconButton(
      tooltip: visivel ? 'Ocultar senha' : 'Mostrar senha',
      onPressed: aoTocar,
      icon: Icon(
        visivel ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _textoLink(String texto, VoidCallback? aoTocar) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text(
            texto,
            style: TextStyle(
              color: aoTocar == null
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget _descricao(String texto) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  // =========================================================
  // ETAPAS
  // =========================================================

  List<Widget> _camposEtapaEmail() {
    return [
      _descricao(
        'Informe o email da sua conta e enviaremos um código para você '
        'criar uma nova senha.',
      ),
      const SizedBox(height: 32),
      _rotulo('Email'),
      const SizedBox(height: 8),
      TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.email],
        onFieldSubmitted: (_) => _solicitarCodigo(),
        decoration: _decoracao(
          hint: 'Digite o seu email',
          icone: Icons.email_outlined,
        ),
        validator: _validarEmail,
      ),
      const SizedBox(height: 28),
      SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: carregando ? null : _solicitarCodigo,
          child: Text(carregando ? 'Enviando...' : 'Enviar código'),
        ),
      ),
    ];
  }

  List<Widget> _camposEtapaCodigo() {
    final podeReenviar = !carregando && _segundosRestantes <= 0;

    return [
      _descricao(
        'Enviamos um código para ${emailController.text.trim()}. '
        'Digite-o abaixo e escolha sua nova senha.',
      ),
      const SizedBox(height: 32),

      // CÓDIGO
      _rotulo('Código'),
      const SizedBox(height: 8),
      TextFormField(
        controller: codigoController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: _decoracao(
          hint: 'Código recebido por email',
          icone: Icons.pin_outlined,
        ),
        validator: (valor) =>
            (valor == null || valor.trim().isEmpty) ? 'Informe o código.' : null,
      ),

      const SizedBox(height: 18),

      // NOVA SENHA
      _rotulo('Nova senha'),
      const SizedBox(height: 8),
      TextFormField(
        controller: novaSenhaController,
        obscureText: !mostrarSenha,
        textInputAction: TextInputAction.next,
        decoration: _decoracao(
          hint: 'Digite a nova senha',
          icone: Icons.lock_outline,
          ajuda: '8+ caracteres, maiúscula, minúscula, número e símbolo.',
          sufixo: _botaoOlho(
            visivel: mostrarSenha,
            aoTocar: () => setState(() => mostrarSenha = !mostrarSenha),
          ),
        ),
        validator: _validarSenha,
      ),

      const SizedBox(height: 18),

      // CONFIRMAR SENHA
      _rotulo('Confirmar senha'),
      const SizedBox(height: 8),
      TextFormField(
        controller: confirmarSenhaController,
        obscureText: !mostrarConfirmacao,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _redefinirSenha(),
        decoration: _decoracao(
          hint: 'Repita a nova senha',
          icone: Icons.lock_outline,
          sufixo: _botaoOlho(
            visivel: mostrarConfirmacao,
            aoTocar: () => setState(() => mostrarConfirmacao = !mostrarConfirmacao),
          ),
        ),
        validator: (valor) {
          if (valor == null || valor.isEmpty) return 'Confirme a nova senha';
          if (valor != novaSenhaController.text) return 'As senhas não coincidem';
          return null;
        },
      ),

      const SizedBox(height: 28),
      SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: carregando ? null : _redefinirSenha,
          child: Text(carregando ? 'Redefinindo...' : 'Redefinir senha'),
        ),
      ),

      const SizedBox(height: 8),
      _textoLink(
        podeReenviar
            ? 'Reenviar código'
            : 'Reenviar código em ${_segundosRestantes}s',
        podeReenviar ? () => _solicitarCodigo(reenvio: true) : null,
      ),
      _textoLink('Alterar email', carregando ? null : _alterarEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets areaSegura = MediaQuery.paddingOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: Center(
          child: ConstrainedBox(
            // Em telas largas (web/desktop) o layout fica centralizado
            // com a largura de um celular, em vez de esticar.
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  // Logo no topo, acima do painel do formulário.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 220,
                    child: Padding(
                      padding: EdgeInsets.only(top: areaSegura.top),
                      child: const Center(child: LogoFhive()),
                    ),
                  ),

                  Positioned.fill(
                    top: 220,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.bottomSheet),
                          topRight: Radius.circular(AppRadius.bottomSheet),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          37,
                          20,
                          37,
                          24 + areaSegura.bottom,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(
                                child: Text(
                                  'Recuperar senha',
                                  style: AppTextStyles.display,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...(etapa == _Etapa.email
                                  ? _camposEtapaEmail()
                                  : _camposEtapaCodigo()),
                              const SizedBox(height: 22),

                              // VOLTAR PARA O LOGIN
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Lembrou a senha? ',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: carregando
                                        ? null
                                        : () => Navigator.maybePop(context),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Entrar',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // BOTÃO VOLTAR (só aparece se houver para onde voltar)
                  if (Navigator.canPop(context))
                    Positioned(
                      left: AppSpacing.sm,
                      top: areaSegura.top + AppSpacing.xs,
                      child: const BotaoVoltar(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}