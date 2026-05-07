import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile_pos/data/models/pedido_model.dart';

void main() {
  test('Debe parsear PedidoModel y convertir el total numeric a double', () {
    final json = {
      "id": 100,
      "fecha_hora": "2026-05-06T12:00:00Z",
      "total": "250.75",
      "estado": "PAGADO",
      "cliente_id": 1,
    };

    final pedido = PedidoModel.fromJson(json);

    expect(pedido.total, 250.75);
    expect(pedido.estado, "PAGADO");
    expect(pedido.fechaHora.hour, isNotNull);
  });
}
