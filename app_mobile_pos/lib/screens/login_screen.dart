import 'package:app_mobile_pos/screens/main_layout.dart';
import 'package:app_mobile_pos/screens/register_screen.dart';
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

  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  bool _isLoading = false;

  Future<void> _login() async {
    if (_userController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _mostrarMensaje("Por favor, llena todos los campos", Colors.amber);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resultado = await _usuarioRepository.login(
        _userController.text.trim(),
        _passwordController.text,
      );

      final String token = resultado['token'];

      await _storage.write(key: 'jwt_token', value: token);

      if (mounted) {
        _mostrarMensaje("¡Bienvenido al sistema!", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
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

            // Input Usuario
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

            // Input Contraseña
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

            // BOTÓN ÚNICO DE INGRESO
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

            const SizedBox(height: 20),

            // TEXTBUTTON PARA IR AL REGISTRO (Este sí abre la pantalla correcta)
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
              child: const Text(
                "¿No tienes cuenta? Registra nuevo personal aquí",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
