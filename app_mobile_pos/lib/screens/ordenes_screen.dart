import 'package:flutter/material.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  List<Map<String, dynamic>> carrito = [];

  String busqueda = '';

  final List<Map<String, dynamic>> productos = [
    {'nombre': 'Pizza', 'precio': 50, 'stock': 5},
    {'nombre': 'Hamburguesa', 'precio': 35, 'stock': 0},
    {'nombre': 'Papas', 'precio': 20, 'stock': 2},
    {'nombre': 'Pollo', 'precio': 45, 'stock': 8},
    {'nombre': 'Coca Cola', 'precio': 15, 'stock': 1},
    {'nombre': 'Helado', 'precio': 18, 'stock': 0},
  ];

  double get total {
    double suma = 0;

    for (var item in carrito) {
      suma += item['precio'] * item['cantidad'];
    }

    return suma;
  }

  int get cantidadTotalCarrito {
    int totalCantidad = 0;

    for (var item in carrito) {
      totalCantidad += item['cantidad'] as int;
    }

    return totalCantidad;
  }

  List<Map<String, dynamic>> get productosFiltrados {
    return productos.where((producto) {
      final nombre = producto['nombre'].toString().toLowerCase();

      return nombre.contains(busqueda.toLowerCase());
    }).toList();
  }

  void abrirModalProducto(Map<String, dynamic> producto) {
    if (producto['stock'] <= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sin stock'),
            content: const Text('No hay producto disponible.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );

      return;
    }

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
                    child: const Icon(Icons.image, size: 60),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'Precio: Bs ${producto['precio']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text('Stock disponible: ${producto['stock']}'),

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
                          if (cantidad < producto['stock']) {
                            setModalState(() {
                              cantidad++;
                            });
                          }
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

                      producto['stock'] = producto['stock'] - cantidad;
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Agregar'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total: Bs ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Pago realizado'),

                              content: Text(
                                'Se realizó el pago de Bs ${total.toStringAsFixed(2)} correctamente.',
                              ),

                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      carrito.clear();
                                    });

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Pagar'),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ],
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

                if (cantidadTotalCarrito > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cantidadTotalCarrito.toString(),
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
              onChanged: (value) {
                setState(() {
                  busqueda = value;
                });
              },

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
              child: productosFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron productos'))
                  : GridView.builder(
                      itemCount: productosFiltrados.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),

                      itemBuilder: (context, index) {
                        final producto = productosFiltrados[index];

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
                                const Icon(Icons.fastfood, size: 50),

                                const SizedBox(height: 10),

                                Text(
                                  '${producto['nombre']} (${producto['stock']})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 5),

                                Text('Bs ${producto['precio']}'),

                                const SizedBox(height: 5),

                                Text(
                                  producto['stock'] == 0
                                      ? 'Sin stock'
                                      : 'Disponible',
                                  style: TextStyle(
                                    color: producto['stock'] == 0
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
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
