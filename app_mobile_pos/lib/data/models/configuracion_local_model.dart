class ConfiguracionLocalModel {
  final int id;
  final String nombreRestaurante;
  final String? nit;
  final String? direccion;
  final String? telefono;
  final String ciudad;
  final String moneda;
  final String? logoUrl;
  final String planActual;

  ConfiguracionLocalModel({
    required this.id,
    required this.nombreRestaurante,
    this.nit,
    this.direccion,
    this.telefono,
    required this.ciudad,
    required this.moneda,
    this.logoUrl,
    required this.planActual,
  });

  factory ConfiguracionLocalModel.fromJson(Map<String, dynamic> json) {
    return ConfiguracionLocalModel(
      id: json['id'],
      nombreRestaurante: json['nombre_restaurante'],
      nit: json['nit'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      ciudad: json['ciudad'] ?? 'Cochabamba',
      moneda: json['moneda'] ?? 'Bs',
      logoUrl: json['logo_url'],
      planActual: json['plan_actual'] ?? 'BASICO',
    );
  }
}
