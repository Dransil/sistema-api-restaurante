class DetallePedidoModel {
  final int id;
  final int pedidoId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetallePedidoModel({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetallePedidoModel.fromJson(Map<String, dynamic> json) {
    return DetallePedidoModel(
      id: json['id'],
      pedidoId: json['pedido_id'],
      productoId: json['producto_id'],
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
