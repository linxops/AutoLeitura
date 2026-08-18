class User {
  final int id;
  final String local;
  final String nome;
  final String celular;
  final String email;
  final String role;

  User(this.id, this.local, this.nome, this.celular, this.email, this.role);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'] as int,
      json['local'] as String? ?? '',
      json['nome'] as String? ?? '',
      json['celular'] as String? ?? '',
      json['email'] as String? ?? '',
      json['role'] as String? ?? 'usuario',
    );
  }
}

class Conta {
  final String nome;
  final int id;
  final String local;
  final String mesReferencia;
  final String dataEmissao;
  final String dataVencimento;
  final double valorConta;
  final double valorMetroCubico;
  final int leituraAtual;
  final int leituraAnterior;
  final String mensagem;

  const Conta({
    required this.nome,
    required this.id,
    required this.local,
    required this.mesReferencia,
    required this.dataEmissao,
    required this.dataVencimento,
    required this.valorConta,
    required this.valorMetroCubico,
    required this.leituraAtual,
    required this.leituraAnterior,
    required this.mensagem,
  });

  factory Conta.fromJson(Map<String, dynamic> json) {
    return Conta(
      nome: json['nome'] as String? ?? '',
      id: json['id'] as int,
      local: json['local'] as String? ?? '',
      mesReferencia: json['mesreferencia'] as String? ?? '',
      dataEmissao: json['dataemissao'] as String? ?? '',
      dataVencimento: json['datavencimento'] as String? ?? '',
      valorConta: double.tryParse('${json['valorconta']}') ?? 0,
      valorMetroCubico: double.tryParse('${json['valormetrocubico']}') ?? 0,
      leituraAtual: int.tryParse('${json['leituraatual']}') ?? 0,
      leituraAnterior: int.tryParse('${json['leituraanterior']}') ?? 0,
      mensagem: json['mensagem'] as String? ?? '',
    );
  }
}