import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget cardInicio(String titulo, String valor, IconData icono, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 40, color: color),

            const SizedBox(height: 10),

            Text(
              valor,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(titulo, textAlign: TextAlign.center),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

                cardInicio('Productos', '25', Icons.inventory, Colors.blue),

                cardInicio('Clientes', '10', Icons.people, Colors.orange),

                cardInicio('Órdenes', '18', Icons.receipt_long, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
