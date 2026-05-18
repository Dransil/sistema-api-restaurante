import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/configuracion_local_model.dart';

class ConfigRepository {
  final DioClient _apiClient = DioClient();

  // Obtener la configuración (GET /configloc)
  Future<ConfiguracionLocalModel?> obtenerConfiguracion() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.configLocal);

      // 1. Verificamos que la respuesta sea 200 y que la lista no venga vacía
      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        // 2. CORRECCIÓN: Accedemos al índice (el primer y único objeto de la configuración)
        final Map<String, dynamic> primerRegistro = response.data;

        // 3. Ahora sí, pasamos el Map al modelo sin romper el tipado de Dart
        return ConfiguracionLocalModel.fromJson(primerRegistro);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener la configuración del negocio: $e');
    }
  }

  // Guardar o actualizar configuración (POST /configloc)
  Future<bool> guardarConfiguracion(ConfiguracionLocalModel config) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.configLocal,
        data: config.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al guardar: $e');
    }
  }
}
