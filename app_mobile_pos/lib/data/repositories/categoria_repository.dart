import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/categoria_model.dart';
import '../models/producto_model.dart';

class CategoriaRepository {
  final DioClient _apiClient = DioClient();

  // Obtener todas las categorías (GET /categorias)
  Future<List<CategoriaModel>> obtenerCategorias() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.categorias);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => CategoriaModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener categorías');
    }
  }

  // Obtener productos filtrados por categoría (GET /categorias/productos/:id_categoria)
  Future<List<ProductoModel>> obtenerProductosPorCategoria(
    int idCategoria,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.categorias}/productos/$idCategoria',
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ProductoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Si el controlador devuelve 404 porque no hay productos activos
      return [];
    }
  }

  // Agregar categoría - Solo Admin (verificarRol())
  Future<CategoriaModel> agregarCategoria(String nombre) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.categorias,
        data: {'nombre': nombre},
      );
      return CategoriaModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear categoría');
    }
  }

  // Actualizar categoría (PUT /categorias/:id)
  Future<bool> actualizarCategoria(int id, String nombre) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.categorias}/$id',
        data: {'nombre': nombre},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar categoría');
    }
  }
}
