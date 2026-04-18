import 'package:app_mobile_pos/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Función utilizando tus constantes
  Future<void> probarConexion() async {
    final dio = Dio();
    try {
      // Concatenamos la base con el endpoint de test
      final url = '${ApiConstants.baseUrl}${ApiConstants.test}';
      print('Conectando a: $url');

      final response = await dio.get(url);
      print('Respuesta del servidor: ${response.data}');
    } catch (e) {
      print('Error conectando al backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Conexión POS'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_sync, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: probarConexion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Probar Conexión (ApiConstants)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
