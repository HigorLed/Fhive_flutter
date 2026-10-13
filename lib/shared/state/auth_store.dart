import 'package:flutter/foundation.dart';

class ContaLocal {
  final String nome;
  final String email;
  final String senha;

  const ContaLocal({
    required this.nome,
    required this.email,
    required this.senha,
  });

  ContaLocal copyWith({String? nome, String? email, String? senha}) {
    return ContaLocal(
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
    );
  }
}

/// Autenticação de demonstração local. Não substitui Firebase, Supabase ou API:
/// as contas ficam apenas na memória do processo e a senha não deve ser usada
/// assim em produção.
class AuthStore {
  AuthStore._();

  static const String emailDemonstracao = 'teste@fhive.com';
  static const String senhaDemonstracao = '123456';

  static Map<String, ContaLocal> _contasIniciais() => <String, ContaLocal>{
    emailDemonstracao: const ContaLocal(
      nome: 'Usuário Fhive',
      email: emailDemonstracao,
      senha: senhaDemonstracao,
    ),
  };

  static Map<String, ContaLocal> _contas = _contasIniciais();
  static final ValueNotifier<ContaLocal?> usuarioAtual =
      ValueNotifier<ContaLocal?>(null);

  static String normalizarEmail(String email) => email.trim().toLowerCase();

  static String? entrar({required String email, required String senha}) {
    final emailLimpo = normalizarEmail(email);
    if (emailLimpo.isEmpty || senha.isEmpty) {
      return 'Informe seu e-mail e sua senha.';
    }
    final conta = _contas[emailLimpo];
    if (conta == null || conta.senha != senha) {
      return 'E-mail ou senha incorretos.';
    }
    usuarioAtual.value = conta;
    return null;
  }

  /// Retorna null se o cadastro for concluído; caso contrário, retorna o erro.
  static String? cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) {
    final nomeLimpo = nome.trim();
    final emailLimpo = normalizarEmail(email);
    if (nomeLimpo.isEmpty || emailLimpo.isEmpty || senha.isEmpty) {
      return 'Preencha todos os campos obrigatórios.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(emailLimpo)) {
      return 'Digite um e-mail válido.';
    }
    if (_contas.containsKey(emailLimpo)) {
      return 'Já existe uma conta cadastrada com esse e-mail.';
    }
    if (!_senhaForte(senha)) {
      return 'A senha ainda não atende a todos os requisitos.';
    }
    _contas[emailLimpo] = ContaLocal(
      nome: nomeLimpo,
      email: emailLimpo,
      senha: senha,
    );
    return null;
  }

  static bool redefinirSenha({
    required String email,
    required String novaSenha,
  }) {
    final emailLimpo = normalizarEmail(email);
    final conta = _contas[emailLimpo];
    if (conta == null || !_senhaForte(novaSenha)) return false;
    _contas[emailLimpo] = conta.copyWith(senha: novaSenha);
    if (usuarioAtual.value?.email == emailLimpo) {
      usuarioAtual.value = _contas[emailLimpo];
    }
    return true;
  }

  static bool atualizarNome(String nome) {
    final atual = usuarioAtual.value;
    final nomeLimpo = nome.trim();
    if (atual == null || nomeLimpo.isEmpty) return false;
    final alterada = atual.copyWith(nome: nomeLimpo);
    _contas[normalizarEmail(atual.email)] = alterada;
    usuarioAtual.value = alterada;
    return true;
  }

  /// Atualiza nome e e-mail no armazenamento local da demonstração.
  /// Retorna null em caso de sucesso ou uma mensagem para a interface.
  static String? atualizarPerfil({
    required String nome,
    required String email,
  }) {
    final atual = usuarioAtual.value;
    final nomeLimpo = nome.trim();
    final emailLimpo = normalizarEmail(email);

    if (atual == null) return 'Entre na sua conta para editar o perfil.';
    if (nomeLimpo.length < 2) {
      return 'Informe um nome com pelo menos 2 caracteres.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(emailLimpo)) {
      return 'Digite um e-mail válido.';
    }

    final emailAnterior = normalizarEmail(atual.email);
    if (emailLimpo != emailAnterior && _contas.containsKey(emailLimpo)) {
      return 'Este e-mail já está vinculado a outra conta.';
    }

    final alterada = atual.copyWith(nome: nomeLimpo, email: emailLimpo);
    _contas.remove(emailAnterior);
    _contas[emailLimpo] = alterada;
    usuarioAtual.value = alterada;
    return null;
  }

  /// Altera a senha local após validar a senha atual e os requisitos de força.
  static String? atualizarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) {
    final atual = usuarioAtual.value;
    if (atual == null) return 'Entre na sua conta para alterar a senha.';
    if (atual.senha != senhaAtual) return 'A senha atual não confere.';
    if (senhaAtual == novaSenha) return 'Escolha uma senha diferente da atual.';
    if (!_senhaForte(novaSenha)) {
      return 'A nova senha precisa ter 6 caracteres, maiúscula, minúscula, número e caractere especial.';
    }

    final alterada = atual.copyWith(senha: novaSenha);
    _contas[normalizarEmail(atual.email)] = alterada;
    usuarioAtual.value = alterada;
    return null;
  }

  static void sair() => usuarioAtual.value = null;

  static void apagarTodasContas() {
    _contas.clear();
    usuarioAtual.value = null;
  }

  /// Reinicia o estado para testes sem remover a conta de demonstração.
  static void resetSessao() => usuarioAtual.value = null;

  /// Reinicia toda a autenticação local, incluindo as contas criadas na sessão.
  static void reset() {
    _contas = _contasIniciais();
    usuarioAtual.value = null;
  }

  static bool _senhaForte(String senha) {
    return senha.length >= 6 &&
        RegExp(r'[a-z]').hasMatch(senha) &&
        RegExp(r'[A-Z]').hasMatch(senha) &&
        RegExp(r'\d').hasMatch(senha) &&
        RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha);
  }
}
