import 'package:app_mobile_pos/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Mobile',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
