import 'package:flutter/foundation.dart';
import 'package:tcc_mobile/core/network/api_client.dart';
import 'package:tcc_mobile/features/auth/data/auth_api.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/shared/state/rotinas_store.dart';

class ContaLocal {
  final String id;
  final String nome;
  final String email;
  final String? fotoPerfil;

  const ContaLocal({
    required this.id,
    required this.nome,
    required this.email,
    this.fotoPerfil,
  });

  ContaLocal copyWith({
    String? id,
    String? nome,
    String? email,
    String? fotoPerfil,
    bool limparFotoPerfil = false,
  }) {
    return ContaLocal(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      fotoPerfil: limparFotoPerfil ? null : (fotoPerfil ?? this.fotoPerfil),
    );
  }
}

/// Estado da sessão autenticada no backend Fhive.
/// O token é mantido em memória; ele não é persistido ao fechar o aplicativo.
class AuthStore {
  AuthStore._();

  static final ValueNotifier<ContaLocal?> usuarioAtual =
      ValueNotifier<ContaLocal?>(null);

  static String normalizarEmail(String email) => email.trim().toLowerCase();

  static Future<String?> entrar({
    required String email,
    required String senha,
  }) async {
    final emailLimpo = normalizarEmail(email);
    if (emailLimpo.isEmpty || senha.isEmpty) {
      return 'Informe seu e-mail e sua senha.';
    }
    if (!_emailValido(emailLimpo)) return 'Digite um e-mail válido.';

    // A tela de login representa uma sessão nova; não preserve token antigo em falha.
    ApiClient.limparToken();
    usuarioAtual.value = null;
    try {
      final resposta = await AuthApi.entrar(email: emailLimpo, senha: senha);
      final token = resposta['token'];
      final usuario = _map(resposta['usuario']);
      if (token is! String || token.isEmpty) {
        return 'O backend não retornou um token de autenticação.';
      }
      ApiClient.definirToken(token);
      usuarioAtual.value = _conta(usuario);
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  /// Inicia o cadastro; o backend envia um código para o e-mail informado.
  static Future<String?> iniciarCadastro({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final nomeLimpo = nome.trim();
    final emailLimpo = normalizarEmail(email);
    if (nomeLimpo.length < 2) return 'Informe um nome válido.';
    if (!_emailValido(emailLimpo)) return 'Digite um e-mail válido.';
    if (!_senhaForte(senha)) {
      return 'A senha precisa ter 8 caracteres, maiúscula, minúscula, número e caractere especial.';
    }
    try {
      await AuthApi.cadastrar(
        nome: nomeLimpo,
        email: emailLimpo,
        senha: senha,
      );
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static Future<String?> confirmarCadastro({
    required String email,
    required String codigo,
  }) async {
    try {
      await AuthApi.confirmarCadastro(email: email, codigo: codigo);
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static Future<String?> solicitarRecuperacao({required String email}) async {
    final emailLimpo = normalizarEmail(email);
    if (!_emailValido(emailLimpo)) return 'Digite um e-mail válido.';
    try {
      await AuthApi.solicitarRecuperacao(email: emailLimpo);
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static Future<String?> verificarCodigoRecuperacao({
    required String email,
    required String codigo,
  }) async {
    try {
      await AuthApi.verificarCodigoRecuperacao(email: email, codigo: codigo);
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static Future<String?> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    if (!_senhaForte(novaSenha)) {
      return 'A nova senha precisa ter 8 caracteres, maiúscula, minúscula, número e caractere especial.';
    }
    try {
      await AuthApi.redefinirSenha(
        email: email,
        codigo: codigo,
        novaSenha: novaSenha,
      );
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static Future<String?> carregarPerfil() async {
    try {
      final resposta = await AuthApi.perfil();
      usuarioAtual.value = _conta(_map(resposta['usuario']));
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static Future<String?> atualizarPerfil({
    required String nome,
    required String email,
    String? fotoPerfil,
  }) async {
    final nomeLimpo = nome.trim();
    final emailLimpo = normalizarEmail(email);
    if (nomeLimpo.length < 2) return 'Informe um nome com pelo menos 2 caracteres.';
    if (!_emailValido(emailLimpo)) return 'Digite um e-mail válido.';
    if (usuarioAtual.value == null) return 'Entre na sua conta para editar o perfil.';

    try {
      final resposta = await AuthApi.atualizarPerfil(
        nome: nomeLimpo,
        email: emailLimpo,
        fotoPerfil: fotoPerfil,
      );
      usuarioAtual.value = _conta(_map(resposta['usuario']));
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static Future<String?> atualizarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    if (usuarioAtual.value == null) return 'Entre na sua conta para alterar a senha.';
    if (senhaAtual == novaSenha) return 'Escolha uma senha diferente da atual.';
    if (!_senhaForte(novaSenha)) {
      return 'A nova senha precisa ter 8 caracteres, maiúscula, minúscula, número e caractere especial.';
    }
    try {
      final atual = usuarioAtual.value!;
      final resposta = await AuthApi.atualizarPerfil(
        nome: atual.nome,
        email: atual.email,
        senhaAtual: senhaAtual,
        novaSenha: novaSenha,
      );
      usuarioAtual.value = _conta(_map(resposta['usuario']));
      return null;
    } catch (error) {
      return _mensagemErro(error);
    }
  }

  static void sair() {
    ApiClient.limparToken();
    usuarioAtual.value = null;
    // Evita que os dados em memória de uma conta apareçam para outra sessão.
    AparelhosStore.reset();
    RotinasStore.reset();
  }

  /// Mantido para o botão de sair já existente nas configurações.
  static void reset() => sair();

  static void resetSessao() => sair();

  static bool _emailValido(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  static bool _senhaForte(String senha) {
    return senha.length >= 8 &&
        RegExp(r'[a-z]').hasMatch(senha) &&
        RegExp(r'[A-Z]').hasMatch(senha) &&
        RegExp(r'\d').hasMatch(senha) &&
        RegExp(r'[^A-Za-z0-9\s]').hasMatch(senha);
  }

  static ContaLocal _conta(Map<String, dynamic> dados) => ContaLocal(
    id: '${dados['id'] ?? ''}',
    nome: '${dados['nome'] ?? ''}',
    email: '${dados['email'] ?? ''}',
    fotoPerfil: dados['fotoPerfil'] is String
        ? dados['fotoPerfil'] as String
        : null,
  );

  static Map<String, dynamic> _map(dynamic valor) {
    if (valor is Map<String, dynamic>) return valor;
    if (valor is Map) return valor.map((key, value) => MapEntry('$key', value));
    return <String, dynamic>{};
  }

  static String _mensagemErro(Object error) {
    if (error is ApiException) return error.message;
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}
