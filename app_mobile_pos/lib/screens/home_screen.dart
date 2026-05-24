import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget cardInicio(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 40,
              color: color,
            ),

            const SizedBox(height: 10),

<<<<<<< HEAD
            Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
=======
  final List<Widget> _screens = const [
    const ProductosScreen(),
    const OrdenesScreen(),
    const Center(child: Text('Inicio')),
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
>>>>>>> 0d9b4990ded7261c34379b407dd767845f520ee5

            const SizedBox(height: 5),

            Text(
              titulo,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido al Sistema POS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,

              children: [
                cardInicio(
                  'Ventas Hoy',
                  'Bs 1500',
                  Icons.attach_money,
                  Colors.green,
                ),

                cardInicio(
                  'Productos',
                  '25',
                  Icons.inventory,
                  Colors.blue,
                ),

                cardInicio(
                  'Clientes',
                  '10',
                  Icons.people,
                  Colors.orange,
                ),

                cardInicio(
                  'Órdenes',
                  '18',
                  Icons.receipt_long,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
<<<<<<< HEAD
=======
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        elevation: 15,
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
>>>>>>> 0d9b4990ded7261c34379b407dd767845f520ee5
    );
  }
}