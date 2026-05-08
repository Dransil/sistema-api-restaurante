import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile_pos/data/models/configuracion_local_model.dart';

void main() {
  test(
    'Debe parsear ConfiguracionLocalModel y manejar valores por defecto',
    () {
      final json = {
        "id": 1,
        "nombre_restaurante": "Mi POS Cochabamba",
        "nit": "12345678",
        "ciudad": "Cochabamba",
        "moneda": "Bs",
        "plan_actual": "BASICO",
      };

      final config = ConfiguracionLocalModel.fromJson(json);

      expect(config.nombreRestaurante, "Mi POS Cochabamba");
      expect(config.moneda, "Bs");
      expect(config.planActual, "BASICO");
    },
  );
}
