class UserModel {
  final int id;
  final String username;
  final int? rolId;
  final bool activo;
  final String? name;
  final String? firstName;
  final String? secondName;
  final DateTime? fechaNac;
  final int? celular;
  final String? email;

  UserModel({
    required this.id,
    required this.username,
    this.rolId,
    this.activo = true,
    this.name,
    this.firstName,
    this.secondName,
    this.fechaNac,
    this.celular,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      rolId: json['rol_id'],
      activo: json['activo'] ?? true,
      name: json['name'],
      firstName: json['first_name'],
      secondName: json['second_name'],
      fechaNac: json['fecha_nac'] != null
          ? DateTime.tryParse(json['fecha_nac'].toString())
          : null,
      celular: json['celular'],
      email: json['email'],
    );
  }
}
