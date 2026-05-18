import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/configuracion_local_model.dart';

class ConfigRepository {
  final DioClient _apiClient = DioClient();

  Future<ConfiguracionLocalModel?> obtenerConfiguracion() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.configLocal);

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> lista = response.data;

        if (lista.isNotEmpty) {
          final Map<String, dynamic> primerRegistro =
              lista[0] as Map<String, dynamic>;

          return ConfiguracionLocalModel.fromJson(primerRegistro);
        }
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
