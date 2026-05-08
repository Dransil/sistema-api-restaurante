import 'package:app_mobile_pos/data/models/categoria_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debe parsear CategoriaModel correctamente', () {
    final json = {"id": 1, "nombre": "Pollo frito"};
    final rol = CategoriaModel.fromJson(json);

    expect(rol.id, 1);
    expect(rol.nombre, "ADMINISTRADOR");
  });
}
