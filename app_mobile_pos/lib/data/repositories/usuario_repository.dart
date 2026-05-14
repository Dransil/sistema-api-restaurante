import '../../core/api/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class UsuarioRepository {
  final DioClient _apiClient = DioClient();

  // POST /usuarios/login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {"username": username, "password": password},
      );

      // Devuelve { "message": "...", "token": "...", "user": {...} }
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Contraseña incorrecta');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Cuenta desactivada por el administrador');
      }
      throw Exception('Error en el servidor: ${e.message}');
    }
  }

  // POST /usuarios/register
  Future<UserModel> register({
    required String username,
    required String password,
    required int rolId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.usuarios}/register',
        data: {"username": username, "password": password, "rol_id": rolId},
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      // Capturamos el error de passSegura(password)
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['error']);
      }
      throw Exception('Error al registrar usuario');
    }
  }

  // Obtener todos los usuarios (GET /usuarios)
  Future<List<UserModel>> obtenerTodos() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.usuarios);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener lista de usuarios');
    }
  }

  // Crear Usuario (POST /usuarios/create)
  Future<UserModel> crearUsuario(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.usuarios}/create',
        data: userData,
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear el usuario');
    }
  }

  // Actualizar Usuario (PUT /usuarios/:id)
  Future<bool> actualizarUsuario(
    int id,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.usuarios}/$id',
        data: updateData,
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar el usuario');
    }
  }

  // Cambiar Estado (PATCH /usuarios/:id/estado)
  Future<bool> cambiarEstado(int id, bool activo) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.usuarios}/$id/estado',
        data: {"activo": activo},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al cambiar estado del usuario');
    }
  }
}
