class Pedido {
  final int id;
  final DateTime fechaHora;
  final int? usuarioId;
  final double total;
  final String estado;
  final int? clienteId;

  Pedido({
    required this.id,
    required this.fechaHora,
    this.usuarioId,
    required this.total,
    required this.estado,
    this.clienteId,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      usuarioId: json['usuario_id'],
      total: double.parse(json['total'].toString()),
      estado: json['estado'],
      clienteId: json['cliente_id'],
    );
  }
}
