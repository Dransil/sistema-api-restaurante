import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/producto_model.dart';

class ProductoRepository {
  final DioClient _apiClient = DioClient();

  // GET /productos (Todos)
  Future<List<ProductoModel>> obtenerTodos() async {
    return _fetchProductos(ApiConstants.productos);
  }

  // GET /productos/activos
  Future<List<ProductoModel>> obtenerActivos() async {
    return _fetchProductos('${ApiConstants.productos}/activos');
  }

  Future<List<ProductoModel>> _fetchProductos(String url) async {
    try {
      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ProductoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar productos');
    }
  }

  // POST /productos (Con imagen usando FormData)
  Future<ProductoModel> crearProducto(
    ProductoModel producto,
    File? imagen,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "nombre": producto.nombre,
        "precio": producto.precio,
        "stock": producto.stock,
        "categoria_id": producto.categoriaId,
        if (imagen != null)
          "imagen_url": await MultipartFile.fromFile(
            imagen.path,
            filename: imagen.path.split('/').last,
          ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.productos,
        data: formData,
      );
      return ProductoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear producto');
    }
  }

  // PATCH /productos/:id/estado
  Future<bool> cambiarEstado(int id, bool nuevoEstado) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.productos}/$id/estado',
        data: {'activo': nuevoEstado},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al cambiar estado del producto');
    }
  }
}
