import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile_pos/data/models/cliente_model.dart';

void main() {
  test('Debe parsear ClienteModel incluyendo el timestamp de creación', () {
    final json = {
      "id": 1,
      "razon_social": "Cliente Test",
      "ci": "1234567",
      "pedidos_realizados": 10,
      "created_at": "2026-04-30T22:23:17Z",
    };

    final cliente = ClienteModel.fromJson(json);

    expect(cliente.razonSocial, "Cliente Test");
    expect(cliente.ci, "1234567");
    expect(cliente.createdAt.month, 4);
  });
}
