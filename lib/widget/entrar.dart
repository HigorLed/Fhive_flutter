import 'package:flutter/material.dart';
import 'package:tcc_mobile/widget/home.dart';

class TelaDeLogin extends StatefulWidget {
  const TelaDeLogin({super.key});

  @override
  State<TelaDeLogin> createState() => _TelaDeLoginState();
}

class _TelaDeLoginState extends State<TelaDeLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool mostrarSenha = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void entrar() {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o e-mail e a senha.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login realizado!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF59D),
                Color(0xFFFFE44D),
                Color(0xFFFFC107),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ==========================================
              // DECORAÇÕES DO FUNDO
              // ==========================================

              Positioned(
                left: -30,
                top: 175,
                child: Container(
                  width: 105,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF261),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                left: 288,
                top: -75,
                child: Container(
                  width: 160,
                  height: 165,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFCE4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                left: 330,
                top: 22,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF261),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // ==========================================
              // ÁREA BRANCA DO LOGIN
              // ==========================================

              Positioned(
                left: 0,
                right: 0,
                top: 220,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFEF2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
              ),

              // ==========================================
              // BOTÃO VOLTAR
              // ==========================================

              Positioned(
                left: 18,
                top: 30,
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
                          color: Color(0xFF964800),
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            color: Color(0xFF964800),
                            fontSize: 14,
                            fontFamily: 'Arvo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================
              // TÍTULO
              // ==========================================

              const Positioned(
                top: 240,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Entrar',
                    style: TextStyle(
                      color: Color(0xFF964800),
                      fontSize: 40,
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // ==========================================
              // LABEL EMAIL
              // ==========================================

              const Positioned(
                left: 42,
                top: 345,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFF964800),
                    fontSize: 18,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // ==========================================
              // CAMPO EMAIL
              // ==========================================

              Positioned(
                left: 37,
                top: 375,
                width: 316,
                height: 52,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: Color(0xFF964800),
                    fontFamily: 'Arvo',
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFFABE),
                    hintText: 'Digite o seu email',
                    hintStyle: const TextStyle(
                      color: Color(0xAD964800),
                      fontFamily: 'Arvo',
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF964800),
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF964800),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              // ==========================================
              // LABEL SENHA
              // ==========================================

              const Positioned(
                left: 42,
                top: 445,
                child: Text(
                  'Senha',
                  style: TextStyle(
                    color: Color(0xFF964800),
                    fontSize: 18,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // ==========================================
              // CAMPO SENHA
              // ==========================================

              Positioned(
                left: 37,
                top: 475,
                width: 316,
                height: 52,
                child: TextField(
                  controller: senhaController,
                  obscureText: !mostrarSenha,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => entrar(),
                  style: const TextStyle(
                    color: Color(0xFF964800),
                    fontFamily: 'Arvo',
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFFABE),
                    hintText: 'Digite sua senha',
                    hintStyle: const TextStyle(
                      color: Color(0xAD964800),
                      fontFamily: 'Arvo',
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF964800),
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          mostrarSenha = !mostrarSenha;
                        });
                      },
                      icon: Icon(
                        mostrarSenha
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF964800),
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF964800),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              // ==========================================
              // ESQUECI MINHA SENHA
              // ==========================================

              Positioned(
                right: 40,
                top: 540,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Recuperação de senha selecionada.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(
                      color: Color(0xFF964800),
                      fontSize: 13,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // ==========================================
              // BOTÃO ENTRAR
              // ==========================================

              Positioned(
  left: 36,
  top: 585,
  width: 318,
  height: 52,
  child: ElevatedButton(
    onPressed: () {
      // Primeiro verifica os campos
      final email = emailController.text.trim();
      final senha = senhaController.text.trim();

      if (email.isEmpty || senha.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preencha o e-mail e a senha.'),
          ),
        );
        return;
      }

      // Vai para a Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TelaHome(),
        ),
      );
    },

    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFF261),
      foregroundColor: const Color(0xFF964800),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),

    child: const Text(
      'Entrar',
      style: TextStyle(
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

              // ==========================================
              // DIVISÃO
              // ==========================================

              const Positioned(
                left: 35,
                top: 660,
                width: 130,
                child: Divider(
                  color: Color(0xFF964800),
                  thickness: 1,
                ),
              ),

              const Positioned(
                left: 170,
                top: 649,
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Color(0xFF964800),
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),

              const Positioned(
                right: 35,
                top: 660,
                width: 130,
                child: Divider(
                  color: Color(0xFF964800),
                  thickness: 1,
                ),
              ),

              // ==========================================
              // BOTÃO GOOGLE
              // ==========================================

              Positioned(
                left: 26,
                top: 705,
                width: 142,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login com Google selecionado.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xCCFFF9BE),
                    side: const BorderSide(
                      color: Color(0x5F000000),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
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
                      const SizedBox(width: 8),
                      const Text(
                        'Google',
                        style: TextStyle(
                          color: Color(0xFF964800),
                          fontSize: 14,
                          fontFamily: 'Arvo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // BOTÃO FACEBOOK
              // ==========================================

              Positioned(
                right: 26,
                top: 705,
                width: 137,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Login com Facebook selecionado.',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xCCFFF9BE),
                    side: const BorderSide(
                      color: Color(0x5F000000),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
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
                      const SizedBox(width: 7),
                      const Text(
                        'Facebook',
                        style: TextStyle(
                          color: Color(0xFF964800),
                          fontSize: 14,
                          fontFamily: 'Arvo',
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
    );
  }
}