class ClienteModel {
  final int id;
  final String razonSocial;
  final String ci;
  final int pedidosRealizados;
  final DateTime createdAt;

  ClienteModel({
    required this.id,
    required this.razonSocial,
    required this.ci,
    required this.pedidosRealizados,
    required this.createdAt,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'],
      razonSocial: json['razon_social'],
      ci: json['ci'],
      pedidosRealizados: json['pedidos_realizados'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
