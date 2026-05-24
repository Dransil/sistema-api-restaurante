import 'package:flutter/material.dart';
import 'package:app_mobile_pos/screens/clientes_screen.dart';
import 'package:app_mobile_pos/screens/ajustes_screen.dart';
import 'package:app_mobile_pos/screens/productos_screen.dart';
import 'package:app_mobile_pos/screens/ordenes_screen.dart';
import 'package:app_mobile_pos/screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_mobile_pos/screens/home_screen.dart';
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [
    const ProductosScreen(),
    const OrdenesScreen(),
    const HomeScreen(),
    const ClientesScreen(),
    const AjustesScreen(),
  ];
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // Títulos dinámicos según la pantalla actual
  final List<String> _titles = [
    'Inventario de productos',
    'Historial de órdenes',
    'Punto de venta (Inicio)',
    'Gestión de clientes',
    'Ajustes del sistema',
  ];

  void _logout() async {
    // 1. Borramos físicamente el token del almacenamiento encriptado
    await _storage.delete(key: 'jwt_token');

    if (mounted) {
      // 2. Redirección blindada destruyendo el historial de navegación
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Agregamos el AppBar global para contener el botón de Logout
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // Mostramos un diálogo de confirmación rápido antes de salir
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text(
                    '¿Estás seguro de que deseas salir del sistema?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cierra el diálogo
                        _logout(); // Ejecuta el logout
                      },
                      child: const Text(
                        'Salir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Órdenes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
