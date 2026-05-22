import 'package:app_mobile_pos/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../../data/repositories/usuario_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instanciamos nuestro repositorio y el almacenamiento seguro
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(); // Exclusivo para el botón de prueba de red

  bool _isLoading = false;

  Future<void> _login() async {
    if (_userController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _mostrarMensaje("Por favor, llena todos los campos", Colors.amber);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Llamamos al repositorio que procesa el login
      final resultado = await _usuarioRepository.login(
        _userController.text.trim(),
        _passwordController.text,
      );

      // 2. Extraemos el token y la info que tu controlador de Node envía
      final String token = resultado['token'];

      // 3. Guardamos el token en el almacenamiento seguro
      await _storage.write(key: 'jwt_token', value: token);

      if (mounted) {
        _mostrarMensaje("¡Bienvenido al sistema!", Colors.green);

        // 4. Navegación limpia al menú principal (Reemplazando el login)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      }
    } catch (e) {
      // Captura los mensajes personalizados lanzados por el repositorio (Usuario no encontrado, etc.)
      String mensajeError = e.toString().replaceAll("Exception: ", "");
      _mostrarMensaje(mensajeError, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _probarConexion() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.test}';
      final response = await _dio.get(url).timeout(const Duration(seconds: 2));

      if (mounted) {
        _mostrarMensaje('Conexión Exitosa: ${response.data}', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(
          'Error de conexión: Verificar IP o Servidor',
          Colors.red,
        );
      }
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _probarConexion,
        label: const Text('Test IP'),
        icon: const Icon(Icons.network_check),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "POS Sistema",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _userController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Ingresar", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
