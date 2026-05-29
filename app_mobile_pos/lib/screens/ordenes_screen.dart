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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                producto['nombre'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      size: 60,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'Precio: Bs ${producto['precio']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 18,
                    ),
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
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),

                      Text(
                        cantidad.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          if (cantidad < producto['stock']) {
                            setModalState(() {
                              cantidad++;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  child: const Text(
                    'Agregar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Carrito',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(item['nombre']),
                        subtitle: Text(
                          '${item['cantidad']} x Bs ${item['precio']}',
                        ),
                        trailing: Text(
                          'Bs ${item['cantidad'] * item['precio']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
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
                    fontSize: 18,
                    color: Colors.deepPurple,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
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
                      child: const Text(
                        'Pagar',
                        style: TextStyle(color: Colors.white),
                      ),
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
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Pedidos',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: abrirCarrito,
              icon: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.deepPurple,
                    size: 28,
                  ),

                  if (cantidadTotalCarrito > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cantidadTotalCarrito.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // BUSCADOR
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    busqueda = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.deepPurple,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // GRID PRODUCTOS
            Expanded(
              child: productosFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron productos'))
                  : GridView.builder(
                      itemCount: productosFiltrados.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),

                      itemBuilder: (context, index) {
                        final producto = productosFiltrados[index];

                        final bool sinStock = producto['stock'] == 0;

                        return GestureDetector(
                          onTap: () {
                            abrirModalProducto(producto);
                          },

                          child: Container(
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(20),

                              border: Border.all(
                                color: sinStock
                                    ? Colors.red.shade100
                                    : Colors.deepPurple.shade100,
                                width: 1.2,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),

                                  decoration: BoxDecoration(
                                    color: sinStock
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.deepPurple.withOpacity(0.1),

                                    shape: BoxShape.circle,
                                  ),

                                  child: Icon(
                                    Icons.fastfood,
                                    size: 50,
                                    color: sinStock
                                        ? Colors.red
                                        : Colors.deepPurple,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  producto['nombre'],

                                  textAlign: TextAlign.center,

                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Bs ${producto['precio']}',

                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),

                                  decoration: BoxDecoration(
                                    color: sinStock
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    sinStock
                                        ? 'Sin stock'
                                        : 'Stock: ${producto['stock']}',

                                    style: TextStyle(
                                      color: sinStock
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
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
