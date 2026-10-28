import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
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

  static const TextStyle _estiloRotulo = TextStyle(
    color: AppColors.primary,
    fontSize: 18,
    fontFamily: AppFonts.title,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _estiloCampo = TextStyle(
    color: AppColors.primary,
    fontFamily: AppFonts.title,
    fontSize: 15,
  );

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

  void _informarLoginSocial() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Login social'),
        content: const Text(
          'O login com Google/Facebook precisa ser configurado com as credenciais do provedor e um serviço de autenticação. Nenhum login externo foi realizado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // COMPONENTES
  // =========================================================

  Widget _circulo(double tamanho, Color cor) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
    );
  }

  Widget _rotulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(texto, style: _estiloRotulo),
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
      hintStyle: const TextStyle(
        color: Color(0xAD964800),
        fontFamily: AppFonts.title,
        fontSize: 15,
      ),
      prefixIcon: Icon(icone, color: AppColors.primary, size: 20),
      suffixIcon: sufixo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    );
  }

  Widget _botaoSocial({
    required Widget icone,
    required String texto,
    required VoidCallback aoTocar,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: aoTocar,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xCCFFF9BE),
          side: const BorderSide(color: Color(0x5F000000)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icone,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                texto,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontFamily: AppFonts.title,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final EdgeInsets areaSegura = MediaQuery.paddingOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.auth),
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
                  Positioned(
                    left: -30,
                    top: 175,
                    child: _circulo(90, AppColors.highlight),
                  ),

                  Positioned(
                    right: -58,
                    top: -75,
                    child: _circulo(160, const Color(0xFFFFFCE4)),
                  ),

                  Positioned(
                    right: -15,
                    top: 22,
                    child: _circulo(75, AppColors.highlight),
                  ),

                  // ---------------------------------------------
                  // ÁREA CLARA COM O FORMULÁRIO (rola com o teclado)
                  // ---------------------------------------------
                  Positioned.fill(
                    top: 220,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFEF2),
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
                                  'Entrar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 40,
                                    fontFamily: AppFonts.title,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // EMAIL
                              _rotulo('Email'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: _estiloCampo,
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
                                style: _estiloCampo,
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
                                        fontSize: 13,
                                        fontFamily: AppFonts.body,
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.highlight,
                                    foregroundColor: AppColors.primary,
                                    elevation: 4,
                                    shadowColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
                                    ),
                                  ),
                                  child: const Text(
                                    'Entrar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: AppFonts.body,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // DIVISÃO
                              const Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.primary,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'ou',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontFamily: AppFonts.body,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.primary,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // GOOGLE E FACEBOOK
                              Row(
                                children: [
                                  Expanded(
                                    child: _botaoSocial(
                                      texto: 'Google',
                                      aoTocar: _informarLoginSocial,
                                      icone: Container(
                                        width: 23,
                                        height: 23,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFCCCCCC),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'G',
                                            style: TextStyle(
                                              color: Color(0xFF4285F4),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: _botaoSocial(
                                      texto: 'Facebook',
                                      aoTocar: _informarLoginSocial,
                                      icone: Container(
                                        width: 23,
                                        height: 23,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1877F2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'f',
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                                      fontSize: 13,
                                      fontFamily: AppFonts.body,
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
                                          fontSize: 13,
                                          fontFamily: AppFonts.title,
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
                      left: 18,
                      top: areaSegura.top + 8,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Voltar',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontFamily: AppFonts.title,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
