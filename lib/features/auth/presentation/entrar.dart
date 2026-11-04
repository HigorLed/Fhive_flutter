import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/widgets/logo_fhive.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

class TelaDeLogin extends StatefulWidget {
  const TelaDeLogin({super.key});

  @override
  State<TelaDeLogin> createState() => _TelaDeLoginState();
}

class _TelaDeLoginState extends State<TelaDeLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool mostrarSenha = false;
  bool carregando = false;

  static final RegExp _regexEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // =========================================================
  // ENTRAR
  // =========================================================

  /// Usada tanto pelo botão "Entrar" quanto pelo "Enter" do teclado,
  /// para que os dois caminhos tenham sempre o mesmo comportamento.
  Future<void> entrar() async {
    FocusScope.of(context).unfocus();
    if (carregando || !_formKey.currentState!.validate()) return;
    setState(() => carregando = true);

    try {
      final erro = await AuthStore.entrar(
        email: emailController.text,
        senha: senhaController.text,
      );
      if (erro != null) {
        _mensagem(erro);
        return;
      }

      var falhaSincronizacao = false;
      try {
        await AparelhosStore.carregarDoBackend();
      } catch (_) {
        falhaSincronizacao = true;
      }
      try {
        await RotinasStore.carregarDoBackend();
      } catch (_) {
        falhaSincronizacao = true;
      }
      if (!mounted) return;
      if (falhaSincronizacao) {
        _mensagem('Login realizado. Alguns dados não puderam ser sincronizados; confira sua conexão com o backend.');
      }
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _recuperarSenha() async {
    final email = TextEditingController(text: emailController.text.trim());
    final formEmailKey = GlobalKey<FormState>();
    final emailConfirmado = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: Form(
          key: formEmailKey,
          child: TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail da conta'),
            validator: (valor) => (valor == null || !_regexEmail.hasMatch(valor.trim()))
                ? 'Digite um e-mail válido.'
                : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formEmailKey.currentState!.validate()) {
                Navigator.pop(dialogContext, email.text.trim());
              }
            },
            child: const Text('Enviar código'),
          ),
        ],
      ),
    );
    email.dispose();
    if (!mounted || emailConfirmado == null) return;

    final erroSolicitacao = await AuthStore.solicitarRecuperacao(email: emailConfirmado);
    if (!mounted) return;
    if (erroSolicitacao != null) {
      _mensagem(erroSolicitacao);
      return;
    }
    _mensagem('Se o e-mail estiver cadastrado, o código de recuperação será enviado.');

    final codigo = TextEditingController();
    final novaSenha = TextEditingController();
    final formCodigoKey = GlobalKey<FormState>();
    final dados = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar recuperação'),
        content: Form(
          key: formCodigoKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codigo,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Código recebido por e-mail'),
                  validator: (valor) => (valor == null || valor.trim().isEmpty) ? 'Informe o código.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: novaSenha,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nova senha', helperText: '8+ caracteres, maiúscula, minúscula, número e símbolo.'),
                  validator: (valor) {
                    final senha = valor ?? '';
                    if (senha.length < 8 || !RegExp(r'[a-z]').hasMatch(senha) ||
                        !RegExp(r'[A-Z]').hasMatch(senha) || !RegExp(r'\d').hasMatch(senha) ||
                        !RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha)) {
                      return 'A senha não atende aos requisitos.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (!formCodigoKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, <String, String>{'codigo': codigo.text.trim(), 'senha': novaSenha.text});
            },
            child: const Text('Redefinir'),
          ),
        ],
      ),
    );
    codigo.dispose();
    novaSenha.dispose();
    if (!mounted || dados == null) return;

    final erroCodigo = await AuthStore.verificarCodigoRecuperacao(
      email: emailConfirmado,
      codigo: dados['codigo'] ?? '',
    );
    if (erroCodigo != null) {
      _mensagem(erroCodigo);
      return;
    }
    final erroSenha = await AuthStore.redefinirSenha(
      email: emailConfirmado,
      codigo: dados['codigo'] ?? '',
      novaSenha: dados['senha'] ?? '',
    );
    if (!mounted) return;
    _mensagem(erroSenha ?? 'Senha redefinida com sucesso. Entre com a nova senha.');
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
  }) {
    // Cor de fundo e bordas vêm do inputDecorationTheme (core/theme).
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icone, size: 20),
      suffixIcon: sufixo,
    );
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
                  // ---------------------------------------------
                  // DECORAÇÕES DO FUNDO
                  // ---------------------------------------------
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
                                child: Text('Entrar', style: AppTextStyles.display),
                              ),

                              const SizedBox(height: 40),

                              // EMAIL
                              _rotulo('Email'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _decoracao(
                                  hint: 'Digite o seu email',
                                  icone: Icons.email_outlined,
                                ),
                                validator: (valor) {
                                  final email = valor?.trim() ?? '';

                                  if (email.isEmpty) {
                                    return 'Digite seu email';
                                  }

                                  if (!_regexEmail.hasMatch(email)) {
                                    return 'Digite um email válido';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // SENHA
                              _rotulo('Senha'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: senhaController,
                                obscureText: !mostrarSenha,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => entrar(),
                                decoration: _decoracao(
                                  hint: 'Digite sua senha',
                                  icone: Icons.lock_outline,
                                  sufixo: IconButton(
                                    tooltip: mostrarSenha
                                        ? 'Ocultar senha'
                                        : 'Mostrar senha',
                                    onPressed: () {
                                      setState(() {
                                        mostrarSenha = !mostrarSenha;
                                      });
                                    },
                                    icon: Icon(
                                      mostrarSenha
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (valor) {
                                  if (valor == null || valor.isEmpty) {
                                    return 'Digite sua senha';
                                  }

                                  return null;
                                },
                              ),

                              // ESQUECI MINHA SENHA
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: _recuperarSenha,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'Esqueci minha senha',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // BOTÃO ENTRAR
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: carregando ? null : entrar,
                                  child: const Text('Entrar'),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // CRIAR CONTA
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Não tem uma conta? ',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/cadastrar',
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Cadastre-se',
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

                  // ---------------------------------------------
                  // BOTÃO VOLTAR (só aparece se houver para onde voltar)
                  // ---------------------------------------------
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
