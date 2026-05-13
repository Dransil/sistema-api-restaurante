import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/pedido_model.dart';
import '../models/detalle_pedido_model.dart';

class PedidoRepository {
  final DioClient _apiClient = DioClient();

  // Obtener historial de pedidos (GET /pedidos)
  Future<List<PedidoModel>> obtenerHistorial() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.pedidos);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => PedidoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener el historial de ventas');
    }
  }

  // Registrar una nueva venta (POST /pedidos)
  Future<int> registrarVenta({
    required int usuarioId,
    int? clienteId,
    required double total,
    required List<DetallePedidoModel> detalles,
  }) async {
    try {
      final Map<String, dynamic> dataVenta = {
        "usuario_id": usuarioId,
        "cliente_id": clienteId,
        "total": total,
        "detalles": detalles.map((d) => d.toJson()).toList(),
      };

      final response = await _apiClient.dio.post(
        ApiConstants.pedidos,
        data: dataVenta,
      );

      if (response.statusCode == 201) {
        return response.data['pedido_id'];
      }

      throw Exception('No se pudo completar la venta');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
