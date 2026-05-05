class PedidoModel {
  final int id;
  final DateTime fechaHora;
  final int? usuarioId;
  final double total;
  final String estado;
  final int? clienteId;

  PedidoModel({
    required this.id,
    required this.fechaHora,
    this.usuarioId,
    required this.total,
    required this.estado,
    this.clienteId,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      usuarioId: json['usuario_id'],
      total: double.parse(json['total'].toString()),
      estado: json['estado'],
      clienteId: json['cliente_id'],
    );
  }
}
