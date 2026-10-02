import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

class TelaDeCadastro extends StatefulWidget {
  const TelaDeCadastro({super.key});

  @override
  State<TelaDeCadastro> createState() => _TelaDeCadastroState();
}

class _TelaDeCadastroState extends State<TelaDeCadastro> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool mostrarSenha = false;
  bool aceitouTermos = false;
  bool carregando = false;

  static final RegExp _regexEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const TextStyle _estiloRotulo = TextStyle(
    color: AppColors.primary,
    fontSize: 18,
    fontFamily: 'Arvo',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _estiloCampo = TextStyle(
    color: AppColors.primary,
    fontFamily: 'Arvo',
    fontSize: 15,
  );

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os termos do Site!'),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    // Conecte aqui a autenticação real (Firebase / Supabase / API).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      carregando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );

    Navigator.pushReplacementNamed(context, '/entrar');
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> cadastrarComGoogle() async {
    _mensagem('Cadastro com Google selecionado.');
  }

  Future<void> cadastrarComFacebook() async {
    _mensagem('Cadastro com Facebook selecionado.');
  }

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
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xAD964800),
        fontFamily: 'Arvo',
        fontSize: 15,
      ),
      prefixIcon: Icon(icone, color: AppColors.primary, size: 20),
      suffixIcon: sufixo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    );
  }

  int get _pontuacaoSenha {
    final senha = senhaController.text;

    if (senha.isEmpty) return 0;

    var pontos = 0;

    // Cada requisito atendido vale 1 ponto.
    if (senha.length >= 6) pontos++;
    if (RegExp(r'[a-z]').hasMatch(senha)) pontos++;
    if (RegExp(r'[A-Z]').hasMatch(senha)) pontos++;
    if (RegExp(r'\d').hasMatch(senha)) pontos++;
    if (RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha)) pontos++;

    return pontos;
  }

  List<String> get _requisitosFaltantes {
    final senha = senhaController.text;
    final faltantes = <String>[];

    if (senha.length < 6) {
      faltantes.add('6 caracteres');
    }
    if (!RegExp(r'[a-z]').hasMatch(senha)) {
      faltantes.add('1 letra minúscula');
    }
    if (!RegExp(r'[A-Z]').hasMatch(senha)) {
      faltantes.add('1 letra maiúscula');
    }
    if (!RegExp(r'\d').hasMatch(senha)) {
      faltantes.add('1 número');
    }
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha)) {
      faltantes.add('1 caractere especial');
    }

    return faltantes;
  }

  int get _barrasSenha {
    switch (_pontuacaoSenha) {
      case 0:
        return 0;
      case 1:
        return 1; // Fraca
      case 2:
        return 2; // Média - 2 barras
      case 3:
      case 4:
        return 3; // Média - 3 barras
      case 5:
        return 4; // Forte - somente quando tudo estiver correto
      default:
        return 0;
    }
  }

  String get _textoForcaSenha {
    switch (_pontuacaoSenha) {
      case 0:
        return '';
      case 1:
        return 'Fraca';
      case 2:
      case 3:
      case 4:
        return 'Média';
      case 5:
        return 'Forte';
      default:
        return '';
    }
  }

  Color get _corForcaSenha {
    switch (_pontuacaoSenha) {
      case 1:
        return const Color(0xFFC07A3A);
      case 2:
      case 3:
      case 4:
        return AppColors.backgroundBottom;
      case 5:
        return const Color(0xFF6F9650);
      default:
        return const Color(0xFFD9C9A8);
    }
  }

  Widget _indicadorForcaSenha() {
    final preenchidas = _barrasSenha;
    final texto = _textoForcaSenha;
    final cor = _corForcaSenha;
    final faltantes = _requisitosFaltantes;

    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(4, (index) {
              final preenchida = index < preenchidas;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 3 ? 0 : 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: 4,
                    decoration: BoxDecoration(
                      color: preenchida
                          ? cor
                          : const Color(0xFFD9C9A8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            }),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: senhaController.text.isEmpty
                ? const SizedBox(height: 18)
                : Padding(
                    key: ValueKey('${texto}_${faltantes.join('|')}'),
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          texto,
                          style: TextStyle(
                            color: cor,
                            fontFamily: 'Arvo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (faltantes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'A senha precisa de: ${faltantes.join(' • ')}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontFamily: 'Montserrat',
                                fontSize: 10.5,
                                height: 1.25,
                              ),
                            ),
                          )
                        else
                          const Text(
                            'Todos os requisitos foram atendidos.',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Montserrat',
                              fontSize: 10.5,
                              height: 1.25,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
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
                  fontFamily: 'Arvo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets areaSegura = MediaQuery.paddingOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.auth),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  // Decorações do fundo — iguais à tela de login.
                  Positioned(
                    left: -30,
                    top: 175,
                    child: _circulo(90, const Color(0xFFFFF261)),
                  ),
                  Positioned(
                    right: -58,
                    top: -75,
                    child: _circulo(160, const Color(0xFFFFFCE4)),
                  ),
                  Positioned(
                    right: -15,
                    top: 22,
                    child: _circulo(75, const Color(0xFFFFF261)),
                  ),

                  // Painel principal — mesma proporção e estilo da tela de login.
                  Positioned.fill(
                    top: 220,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFEF2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
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
                                  'Cadastrar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 40,
                                    fontFamily: 'Arvo',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // NOME
                              _rotulo('Nome'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: nomeController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                style: _estiloCampo,
                                decoration: _decoracao(
                                  hint: 'Digite o seu nome',
                                  icone: Icons.person_outline,
                                ),
                                validator: (valor) {
                                  final nome = valor?.trim() ?? '';

                                  if (nome.isEmpty) {
                                    return 'Digite seu nome';
                                  }

                                  if (nome.length < 2) {
                                    return 'Digite um nome válido';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

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
                                onFieldSubmitted: (_) => cadastrar(),
                                style: _estiloCampo,
                                onChanged: (_) {
                                  setState(() {});
                                },
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

                                  if (valor.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }

                                  if (!RegExp(r'[a-z]').hasMatch(valor)) {
                                    return 'A senha deve conter pelo menos uma letra minúscula';
                                  }

                                  if (!RegExp(r'[A-Z]').hasMatch(valor)) {
                                    return 'A senha deve conter pelo menos uma letra maiúscula';
                                  }

                                  if (!RegExp(r'\d').hasMatch(valor)) {
                                    return 'A senha deve conter pelo menos um número';
                                  }

                                  if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(valor)) {
                                    return 'A senha deve conter pelo menos um caractere especial';
                                  }

                                  return null;
                                },
                              ),

                              _indicadorForcaSenha(),

                              // TERMOS
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    aceitouTermos = !aceitouTermos;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: aceitouTermos,
                                          onChanged: (valor) {
                                            setState(() {
                                              aceitouTermos = valor ?? false;
                                            });
                                          },
                                          activeColor: const Color(0xFFFFF261),
                                          checkColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: Color(0xFFB8A77B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Eu concordo com os ',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 13,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'termos do Site!',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 13,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // BOTÃO CADASTRAR
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: carregando ? null : cadastrar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFF261),
                                    disabledBackgroundColor:
                                        const Color(0xFFE9D94A),
                                    foregroundColor: AppColors.primary,
                                    elevation: 4,
                                    shadowColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: carregando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : const Text(
                                          'Cadastrar',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Montserrat',
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
                                        fontFamily: 'Montserrat',
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
                                      aoTocar: cadastrarComGoogle,
                                      icone: Container(
                                        width: 23,
                                        height: 23,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
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
                                      aoTocar: cadastrarComFacebook,
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
                                              color: Colors.white,
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

                              // JÁ POSSUI CONTA
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Já possui uma conta? ',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/entrar',
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Entre agora!',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 13,
                                          fontFamily: 'Arvo',
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

                  // BOTÃO VOLTAR — mesma posição da tela de login.
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
                                  fontFamily: 'Arvo',
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
