import 'package:flutter/material.dart';
import 'package:tcc_mobile/widget/entrar.dart';

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

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  // =========================================================
  // CADASTRO
  // =========================================================

  Future<void> cadastrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você precisa aceitar os termos do Site!',
          ),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    // -------------------------------------------------------
    // AQUI VOCÊ PODE CONECTAR FIREBASE / SUPABASE / API
    // -------------------------------------------------------

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      carregando = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado com sucesso!'),
      ),
    );

    // Depois do cadastro:
    //
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const TelaDeLogin(),
    //   ),
    // );
  }

  // =========================================================
  // GOOGLE
  // =========================================================

  Future<void> cadastrarComGoogle() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cadastro com Google selecionado.',
        ),
      ),
    );

    // Conecte aqui o Google Sign-In/Firebase.
  }

  // =========================================================
  // FACEBOOK
  // =========================================================

  Future<void> cadastrarComFacebook() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cadastro com Facebook selecionado.',
        ),
      ),
    );

    // Conecte aqui o Facebook Login/Firebase.
  }

  // =========================================================
  // CAMPO PADRÃO
  // =========================================================

  InputDecoration campoDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFFFABE),

      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xAD964800),
        fontSize: 13,
        fontFamily: 'Arvo',
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF964800),
        size: 18,
      ),

      suffixIcon: suffixIcon,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF964800),
          width: 1.2,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD929),

      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 390,
            height: 844,
            child: Stack(
              children: [

                // =================================================
                // FUNDO DEGRADÊ
                // =================================================

                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFF06A),
                          Color(0xFFFFD91A),
                          Color(0xFFFFBD00),
                        ],
                      ),
                    ),
                  ),
                ),

                // =================================================
                // CÍRCULO SUPERIOR DIREITO
                // =================================================

                Positioned(
                  right: -18,
                  top: -32,
                  child: Container(
                    width: 105,
                    height: 105,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFDE6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // =================================================
                // CÍRCULO AMARELO
                // =================================================

                Positioned(
                  right: 15,
                  top: 18,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF261),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // =================================================
                // CÍRCULO ESQUERDO
                // =================================================

                Positioned(
                  left: -28,
                  top: 82,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF261),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // =================================================
                // BOTÃO VOLTAR
                // =================================================

                Positioned(
                  left: 8,
                  top: 18,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: Color(0xFF964800),
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Voltar',
                            style: TextStyle(
                              color: Color(0xFF964800),
                              fontFamily: 'Arvo',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =================================================
                // PAINEL PRINCIPAL
                // =================================================

                Positioned(
                  left: 0,
                  right: 0,
                  top: 122,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFEF1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                  ),
                ),

                // =================================================
                // CONTEÚDO
                // =================================================

                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 127,
                      left: 23,
                      right: 23,
                      bottom: 15,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // =========================================
                          // TÍTULO
                          // =========================================

                          const Center(
                            child: Text(
                              'Cadastrar',
                              style: TextStyle(
                                color: Color(0xFF964800),
                                fontSize: 25,
                                fontFamily: 'Arvo',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          // =========================================
                          // NOME
                          // =========================================

                          const Text(
                            'Nome',
                            style: TextStyle(
                              color: Color(0xFF964800),
                              fontSize: 13,
                              fontFamily: 'Arvo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          TextFormField(
                            controller: nomeController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            style: const TextStyle(
                              color: Color(0xFF964800),
                              fontSize: 13,
                              fontFamily: 'Arvo',
                            ),
                            decoration: campoDecoration(
                              hint: 'Digite o seu nome',
                              icon: Icons.person,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Digite seu nome';
                              }

                              if (value.trim().length < 2) {
                                return 'Digite um nome válido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 9),

                          // =========================================
                          // EMAIL
                          // =========================================

                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF964800),
                              fontSize: 13,
                              fontFamily: 'Arvo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          TextFormField(
                            controller: emailController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Color(0xFF964800),
                              fontSize: 13,
                              fontFamily: 'Arvo',
                            ),
                            decoration: campoDecoration(
                              hint: 'Digite o seu email',
                              icon: Icons.email,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Digite seu email';
                              }

                              final email =
                                  value.trim();

                              final regex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );

                              if (!regex.hasMatch(email)) {
                                return 'Digite um email válido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 9),

                          // =========================================
                          // SENHA
                          // =========================================

                          const Text(
                            'Senha',
                            style: TextStyle(
                              color: Color(0xFF964800),
                              fontSize: 13,
                              fontFamily: 'Arvo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          TextFormField(
                            controller: senhaController,
                            obscureText: !mostrarSenha,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                              color: Color(0xFF964800),
                              fontSize: 13,
                              fontFamily: 'Arvo',
                            ),
                            decoration: campoDecoration(
                              hint: 'Digite sua senha',
                              icon: Icons.lock,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    mostrarSenha = !mostrarSenha;
                                  });
                                },
                                icon: Icon(
                                  mostrarSenha
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 18,
                                  color: const Color(0xFF964800),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Digite sua senha';
                              }

                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              cadastrar();
                            },
                          ),

                          // =========================================
                          // LINHAS DECORATIVAS
                          // =========================================

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD8C99E),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD8C99E),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD8C99E),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 17),

                          // =========================================
                          // TERMOS
                          // =========================================

                          InkWell(
                            onTap: () {
                              setState(() {
                                aceitouTermos =
                                    !aceitouTermos;
                              });
                            },
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: aceitouTermos,
                                    onChanged: (value) {
                                      setState(() {
                                        aceitouTermos =
                                            value ?? false;
                                      });
                                    },
                                    activeColor:
                                        const Color(0xFFFFC107),
                                    checkColor:
                                        const Color(0xFF964800),
                                    side: const BorderSide(
                                      color: Color(0xFFB8A77B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Eu concordo com os ',
                                          style: TextStyle(
                                            color:
                                                Color(0xFF694B28),
                                            fontSize: 11,
                                            fontFamily:
                                                'Montserrat',
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              'termos do Site!',
                                          style: TextStyle(
                                            color:
                                                Color(0xFF964800),
                                            fontSize: 11,
                                            fontFamily:
                                                'Montserrat',
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 11),

                          // =========================================
                          // BOTÃO CADASTRAR
                          // =========================================

                          Center(
                            child: SizedBox(
                              width: 145,
                              height: 38,
                              child: ElevatedButton(
                                onPressed:
                                    carregando
                                        ? null
                                        : cadastrar,
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                        0xFFFFF261,
                                      ),
                                  disabledBackgroundColor:
                                      const Color(
                                        0xFFE9D94A,
                                      ),
                                  foregroundColor:
                                      const Color(
                                        0xFF964800,
                                      ),
                                  elevation: 3,
                                  shadowColor:
                                      Colors.black26,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      22,
                                    ),
                                  ),
                                ),
                                child: carregando
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(
                                            0xFF964800,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Cadastrar',
                                        style:
                                            TextStyle(
                                          fontSize: 15,
                                          fontFamily:
                                              'Montserrat',
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =========================================
                          // OU CADASTRE COM
                          // =========================================

                          const Center(
                            child: Text(
                              'Ou Cadastre com',
                              style: TextStyle(
                                color: Color(0xFF964800),
                                fontSize: 11,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          // =========================================
                          // GOOGLE E FACEBOOK
                          // =========================================

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [

                              SizedBox(
                                width: 69,
                                height: 29,
                                child: OutlinedButton(
                                  onPressed:
                                      cadastrarComGoogle,
                                  style:
                                      OutlinedButton.styleFrom(
                                    padding:
                                        EdgeInsets.zero,
                                    backgroundColor:
                                        const Color(
                                      0xFFFFFEF1,
                                    ),
                                    side:
                                        const BorderSide(
                                      color:
                                          Color(0xFFC7B887),
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        8,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration:
                                            const BoxDecoration(
                                          color: Colors.white,
                                          shape:
                                              BoxShape.circle,
                                        ),
                                        child:
                                            const Center(
                                          child: Text(
                                            'G',
                                            style: TextStyle(
                                              color:
                                                  Color(
                                                0xFF4285F4,
                                              ),
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Google',
                                        style: TextStyle(
                                          color:
                                              Color(
                                            0xFF964800,
                                          ),
                                          fontSize: 10,
                                          fontFamily:
                                              'Arvo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 30),

                              SizedBox(
                                width: 78,
                                height: 29,
                                child: OutlinedButton(
                                  onPressed:
                                      cadastrarComFacebook,
                                  style:
                                      OutlinedButton.styleFrom(
                                    padding:
                                        EdgeInsets.zero,
                                    backgroundColor:
                                        const Color(
                                      0xFFFFFEF1,
                                    ),
                                    side:
                                        const BorderSide(
                                      color:
                                          Color(0xFFC7B887),
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        8,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration:
                                            const BoxDecoration(
                                          color:
                                              Color(
                                            0xFF1877F2,
                                          ),
                                          shape:
                                              BoxShape.circle,
                                        ),
                                        child:
                                            const Center(
                                          child: Text(
                                            'f',
                                            style: TextStyle(
                                              color:
                                                  Colors.white,
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Facebook',
                                        style: TextStyle(
                                          color:
                                              Color(
                                            0xFF964800,
                                          ),
                                          fontSize: 10,
                                          fontFamily:
                                              'Arvo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // =========================================
                          // JÁ POSSUI CONTA
                          // =========================================

                          const Center(
                            child: Text(
                              'Já possui uma conta?',
                              style: TextStyle(
                                color: Color(0xFF964800),
                                fontSize: 10,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),

                          const SizedBox(height: 1),

                          Center(
                            child: InkWell(
                              onTap: () {
                              
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const TelaDeLogin(),
                                   ),
                                 );

                                
                              },
                              child: const Text(
                                'Entre na agora!',
                                style: TextStyle(
                                  color:
                                      Color(0xFF964800),
                                  fontSize: 10,
                                  fontFamily: 'Arvo',
                                  fontWeight:
                                      FontWeight.w700,
                                  decoration:
                                      TextDecoration
                                          .underline,
                                ),
                              ),
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
    );
  }
}