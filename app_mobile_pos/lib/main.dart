import 'package:app_mobile_pos/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    developer.log(
      'Variables de entorno cargadas correctamente',
      name: 'app.bootstrap',
    );
  } catch (e, stackTrace) {
    developer.log(
      'Error crítico al cargar el archivo .env. Asegúrate de que esté declarado en los assets.',
      name: 'app.bootstrap',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Mobile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LoginScreen(),
    );
  }
}
