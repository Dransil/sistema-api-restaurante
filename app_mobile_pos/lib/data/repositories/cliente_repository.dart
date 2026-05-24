import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/cliente_model.dart';

class ClienteRepository {
  final DioClient _apiClient = DioClient();

  // Obtener todos los clientes (GET /clientes)
  Future<List<ClienteModel>> obtenerClientes() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.clientes);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ClienteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener lista de clientes');
    }
  }
  // Future<List<ClienteModel>> obtenerClientes() async {
  //   try {
  //     final response = await _apiClient.dio.get(ApiConstants.clientes);

  //     if (response.statusCode == 200 && response.data is List) {
  //       final List<dynamic> lista = response.data;
  //       // Mapeamos el array JSON directo a una lista de objetos ClienteModel
  //       return lista.map((json) => ClienteModel.fromJson(json as Map<String, dynamic>)).toList();
  //     }
  //     return [];
  //   } catch (e) {
  //     throw Exception('Error al obtener el listado de clientes: $e');
  //   }
  // }

  // Buscar por CI (GET /clientes/:ci)
  Future<ClienteModel?> buscarPorCI(String ci) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.clientes}/$ci');
      if (response.statusCode == 200) {
        return ClienteModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      // Si el controlador devuelve 404, Dio lanzará una excepción aquí
      return null;
    }
  }

  // Agregar cliente (POST /clientes)
  Future<ClienteModel> agregarCliente(String razonSocial, String ci) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.clientes,
        data: {'razon_social': razonSocial, 'ci': ci},
      );
      return ClienteModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al registrar cliente: $e');
    }
  }

  // Actualizar cliente (PUT /clientes/:id)
  Future<bool> actualizarCliente(int id, String razonSocial, String ci) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.clientes}/$id',
        data: {'razon_social': razonSocial, 'ci': ci},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar cliente');
    }
  }
}
