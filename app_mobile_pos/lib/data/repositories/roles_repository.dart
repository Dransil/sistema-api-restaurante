import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/rol_model.dart';

class RolRepository {
  final DioClient _apiClient = DioClient();

  // Obtener todos los roles (GET /roles)
  Future<List<RolModel>> obtenerRoles() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.roles);

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => RolModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar los roles de usuario: $e');
    }
  }
}
