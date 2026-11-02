import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/shared/widgets/logo_fhive.dart';
import 'package:tcc_mobile/shared/state/auth_store.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

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

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    FocusScope.of(context).unfocus();
    if (carregando || !_formKey.currentState!.validate()) return;

    if (!aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa aceitar os termos de uso do aplicativo!')),
      );
      return;
    }

    setState(() => carregando = true);
    try {
      final erro = await AuthStore.iniciarCadastro(
        nome: nomeController.text,
        email: emailController.text,
        senha: senhaController.text,
      );
      if (!mounted) return;
      if (erro != null) {
        _mensagem(erro);
        return;
      }

      _mensagem('Enviamos um código para confirmar seu e-mail.');
      final codigo = await _pedirCodigoConfirmacao();
      if (!mounted || codigo == null) return;

      final erroConfirmacao = await AuthStore.confirmarCadastro(
        email: emailController.text,
        codigo: codigo,
      );
      if (!mounted) return;
      if (erroConfirmacao != null) {
        _mensagem(erroConfirmacao);
        return;
      }

      final erroLogin = await AuthStore.entrar(
        email: emailController.text,
        senha: senhaController.text,
      );
      if (!mounted) return;
      if (erroLogin != null) {
        _mensagem('Cadastro confirmado. Entre para iniciar a sessão. $erroLogin');
        Navigator.pushReplacementNamed(context, '/entrar');
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
        _mensagem('Conta criada. Alguns dados não puderam ser sincronizados.');
      }
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<String?> _pedirCodigoConfirmacao() async {
    final codigoController = TextEditingController();
    final key = GlobalKey<FormState>();
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirme seu e-mail'),
        content: Form(
          key: key,
          child: TextFormField(
            controller: codigoController,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Código de confirmação',
              helperText: 'Digite o código enviado para seu e-mail.',
            ),
            validator: (valor) => (valor == null || valor.trim().isEmpty)
                ? 'Informe o código recebido.'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                Navigator.pop(dialogContext, codigoController.text.trim());
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    codigoController.dispose();
    return codigo;
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

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
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icone, size: 20),
      suffixIcon: sufixo,
    );
  }

  int get _pontuacaoSenha {
    final senha = senhaController.text;

    if (senha.isEmpty) return 0;

    var pontos = 0;

    // Cada requisito atendido vale 1 ponto.
    if (senha.length >= 8) pontos++;
    if (RegExp(r'[a-z]').hasMatch(senha)) pontos++;
    if (RegExp(r'[A-Z]').hasMatch(senha)) pontos++;
    if (RegExp(r'\d').hasMatch(senha)) pontos++;
    if (RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha)) pontos++;

    return pontos;
  }

  List<String> get _requisitosFaltantes {
    final senha = senhaController.text;
    final faltantes = <String>[];

    if (senha.length < 8) {
      faltantes.add('8 caracteres');
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
        return AppColors.warning;
      case 2:
      case 3:
      case 4:
        return AppColors.backgroundBottom;
      case 5:
        return AppColors.success;
      default:
        return AppColors.track;
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
                      color: preenchida ? cor : AppColors.track,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
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
                                fontSize: 10,
                                height: 1.25,
                              ),
                            ),
                          )
                        else
                          const Text(
                            'Todos os requisitos foram atendidos.',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
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

  @override
  Widget build(BuildContext context) {
    final EdgeInsets areaSegura = MediaQuery.paddingOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  // Decorações do fundo — iguais à tela de login.
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
                                child: Text('Cadastrar', style: AppTextStyles.display),
                              ),

                              const SizedBox(height: 40),

                              // NOME
                              _rotulo('Nome'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: nomeController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
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

                                  if (valor.length < 8) {
                                    return 'A senha deve ter pelo menos 8 caracteres';
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

                                  if (!RegExp(
                                    r'[^A-Za-z0-9\s]',
                                  ).hasMatch(valor)) {
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
                                          activeColor: AppColors.highlight,
                                          checkColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: AppColors.track,
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
                                                  fontSize: 14,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'termos do Site!',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 14,
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
                                  child: carregando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.white,
                                          ),
                                        )
                                      : const Text('Cadastrar'),
                                ),
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
                                      fontSize: 14,
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

                  // BOTÃO VOLTAR — mesma posição da tela de login.
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
