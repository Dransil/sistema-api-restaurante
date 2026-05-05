import 'package:app_mobile_pos/data/models/producto_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('El modelo Producto debe parsear correctamente los tipos de datos', () {
    final json = {"id": 10, "nombre": "Arroz", "precio": "8.50", "stock": 100};

    final producto = ProductoModel.fromJson(json);

    expect(producto.id, 10);
    expect(producto.precio, 8.5); // Verificamos que se convirtió a double
    expect(producto.nombre, "Arroz");
  });
}
