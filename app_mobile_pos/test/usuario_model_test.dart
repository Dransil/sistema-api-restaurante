import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile_pos/data/models/user_model.dart';

void main() {
  test('Debe parsear UsuarioModel desde JSON de PostgreSQL', () {
    final json = {
      "id": 5,
      "username": "etaquichiri",
      "rol_id": 1,
      "activo": true,
      "name": "Emanuel",
      "fecha_nac": "1998-05-20",
    };

    final user = UserModel.fromJson(json);

    expect(user.username, "etaquichiri");
    expect(user.rolId, 1);
    expect(user.fechaNac, isA<DateTime>());
    expect(user.fechaNac?.year, 1998);
  });
}
