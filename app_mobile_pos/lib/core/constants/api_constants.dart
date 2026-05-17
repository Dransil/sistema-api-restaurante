import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Cambiar IP para tests
  static String baseUrl = dotenv.get(
    'BASE_URL',
    fallback: 'http://192.168.1.1:3000',
  );
  static String? token;
  // Endpoint para testear
  static const String test = '/test';
  // Endpoints basados en el backend
  static const String productos = '/productos';
  static const String categorias = '/categorias';
  static const String roles = '/roles';
  static const String usuarios = '/usuarios';
  static const String pedidos = '/pedidos';
  static const String detallePedido = '/detallepedido';
  static const String clientes = '/clientes';
  static const String configLocal = '/configloc';
  static const String reportes = '/reportes';
  // Endpoint de imágenes
  static const String uploads = '/uploads';
  // Endpoint de login necesario para la verificación JWT
  static const String login = '/usuarios/login';
}
