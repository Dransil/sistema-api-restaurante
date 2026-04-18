import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar el texto
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();
  Future<void> _login() async {
    final dio = Dio();
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.login}';

      final response = await dio.post(
        url,
        data: {
          "username": _userController.text,
          "password": _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        print("Login exitoso: ${response.data}");
        // Navegacion al menú
      }
    } catch (e) {
      print("Error en login: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error de autenticación")));
    }
  }

  Future<void> _probarConexion() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.test}';
      final response = await _dio.get(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conexión Exitosa: ${response.data}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: Verificar IP o Servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _probarConexion,
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
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text("Ingresar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
