class ProductoModel {
  final int id;
  final String nombre;
  final double precio;
  final int stock;
  final int? categoriaId;
  final String? imagenUrl;
  final bool activo;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    this.categoriaId,
    this.imagenUrl,
    this.activo = true,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'],
      nombre: json['nombre'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      categoriaId: json['categoria_id'],
      imagenUrl: json['imagen_url'],
      activo: json['activo'] ?? true,
    );
  }
}
