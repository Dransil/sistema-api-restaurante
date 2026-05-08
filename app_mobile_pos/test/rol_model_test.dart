import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile_pos/data/models/rol_model.dart';

void main() {
  test('Debe parsear RolModel correctamente', () {
    final json = {"id": 1, "nombre": "ADMINISTRADOR"};
    final rol = RolModel.fromJson(json);

    expect(rol.id, 1);
    expect(rol.nombre, "ADMINISTRADOR");
  });
}
