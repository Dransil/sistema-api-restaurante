import 'package:flutter/material.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  int selectedIndex = -1;

  List<Map<String, dynamic>> carrito = [];

  final List<Map<String, dynamic>> productos = [
    {
      'nombre': 'Pizza',
      'precio': 50,
    },
    {
      'nombre': 'Hamburguesa',
      'precio': 35,
    },
    {
      'nombre': 'Papas',
      'precio': 20,
    },
    {
      'nombre': 'Pollo',
      'precio': 45,
    },
    {
      'nombre': 'Coca Cola',
      'precio': 15,
    },
    {
      'nombre': 'Helado',
      'precio': 18,
    },
  ];

  double get total {
    double suma = 0;

    for (var item in carrito) {
      suma += item['precio'] * item['cantidad'];
    }

    return suma;
  }

  void abrirModalProducto(Map<String, dynamic> producto) {
    int cantidad = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(producto['nombre']),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'Precio: Bs ${producto['precio']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (cantidad > 1) {
                            setModalState(() {
                              cantidad--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle),
                      ),

                      Text(
                        cantidad.toString(),
                        style: const TextStyle(fontSize: 20),
                      ),

                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            cantidad++;
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                ],
              ),

              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      carrito.add({
                        'nombre': producto['nombre'],
                        'precio': producto['precio'],
                        'cantidad': cantidad,
                      });
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Agregar'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void abrirCarrito() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Carrito'),

          content: SizedBox(
            width: double.maxFinite,
            child: carrito.isEmpty
                ? const Text('No hay productos')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: carrito.length,
                    itemBuilder: (context, index) {
                      final item = carrito[index];

                      return ListTile(
                        title: Text(item['nombre']),
                        subtitle: Text(
                          '${item['cantidad']} x Bs ${item['precio']}',
                        ),
                        trailing: Text(
                          'Bs ${item['cantidad'] * item['precio']}',
                        ),
                      );
                    },
                  ),
          ),

          actions: [
            Text(
              'Total: Bs ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            onPressed: abrirCarrito,
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),

                if (carrito.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        carrito.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: GridView.builder(
                itemCount: productos.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),

                itemBuilder: (context, index) {
                  final producto = productos[index];

                  return GestureDetector(
                    onTap: () {
                      abrirModalProducto(producto);
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fastfood,
                            size: 50,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            producto['nombre'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Bs ${producto['precio']}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}