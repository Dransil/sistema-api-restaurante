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
    this.planActual = 'Gratuito',
  });

  factory ConfiguracionLocalModel.fromJson(Map<String, dynamic> json) {
    return ConfiguracionLocalModel(
      id: json['id'],
      nombreRestaurante: json['nombre_restaurante'],
      nit: json['nit'],
      direccion: json['direccion'],
      telefono: json['telefono']?.toString(),
      ciudad: json['ciudad'],
      moneda: json['moneda'],
      logoUrl: json['logo_url'],
      planActual: json['plan_actual'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_restaurante': nombreRestaurante,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      'ciudad': ciudad,
      'moneda': moneda,
      'logo_url': logoUrl,
      'plan_actual': planActual,
    };
  }
}
