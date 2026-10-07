class Usuario {
  const Usuario({required this.id, required this.nome, required this.email});

  final String id;
  final String nome;
  final String email;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'email': email};
  }
}
