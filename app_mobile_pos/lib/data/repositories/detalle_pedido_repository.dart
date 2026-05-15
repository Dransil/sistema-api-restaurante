import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/detalle_pedido_model.dart';

class DetallePedidoRepository {
  final DioClient _apiClient = DioClient();

  // Obtener absolutamente todos los detalles (Solo Admin)
  Future<List<DetallePedidoModel>> obtenerTodos() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.detallePedido);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => DetallePedidoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener el historial detallado');
    }
  }

  // Obtener los productos de un pedido específico (GET /detallepedido/:id_pedido)
  Future<List<DetallePedidoModel>> obtenerPorPedido(int idPedido) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.detallePedido}/$idPedido',
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => DetallePedidoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
