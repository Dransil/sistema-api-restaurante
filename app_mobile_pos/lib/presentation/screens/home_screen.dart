import 'package:flutter/material.dart';

// Aqui tienes que importar las pantallas que haras
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Iniciamos en 2 para que "Inicio" sea la pantalla principal
  int _selectedIndex = 2;

  // Lista de tus pantallas
  final List<Widget> _screens = [
    const Center(child: Text('Productos')), // Index 0
    const Center(child: Text('Órdenes')), // Index 1
    const Center(child: Text('Inicio')), // Index 2 (Principal)
    const Center(child: Text('Clientes')), // Index 3
    const Center(child: Text('Ajustes')), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Obligatorio para más de 3 items
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
