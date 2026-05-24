import 'package:flutter/material.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() =>
      _ProductosScreenState();
}

class _ProductosScreenState
    extends State<ProductosScreen> {
  String filtro = 'Todos';
  String search = '';

  final List<Map<String, dynamic>> productos = [
    {
      'nombre': 'Pizza',
      'stock': 0,
      'precio': 50,
      'categoria': 'Comida',
    },
    {
      'nombre': 'Hamburguesa',
      'stock': 3,
      'precio': 35,
      'categoria': 'Comida',
    },
    {
      'nombre': 'Papas',
      'stock': 10,
      'precio': 20,
      'categoria': 'Snacks',
    },
  ];

  List<Map<String, dynamic>> get productosFiltrados {
    return productos.where((producto) {
      return producto['nombre']
          .toString()
          .toLowerCase()
          .contains(search);
    }).toList();
  }

  String obtenerEstadoStock(int stock) {
    if (stock == 0) {
      return 'Sin stock';
    }

    if (stock <= 5) {
      return 'Poco stock';
    }

    return 'Disponible';
  }

  Color obtenerColorStock(int stock) {
    if (stock == 0) {
      return Colors.red;
    }

    if (stock <= 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  void mostrarDetalleProducto(
    Map<String, dynamic> producto,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalle Producto'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: const Icon(
                  Icons.image,
                  size: 50,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                producto['nombre'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Categoría: ${producto['categoria']}',
              ),

              Text(
                'Stock: ${producto['stock']}',
              ),

              Text(
                'Precio: Bs ${producto['precio']}',
              ),
            ],
          ),

          actions: [
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

  void mostrarAccionProducto(String accion) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            accion == 'activar'
                ? 'Activar Producto'
                : 'Desactivar Producto',
          ),

          content: Text(
            accion == 'activar'
                ? '¿Desea activar este producto?'
                : '¿Desea desactivar este producto?',
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
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
  }

  Widget estadoStock(int stock) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: obtenerColorStock(stock),
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          obtenerEstadoStock(stock),
          style: TextStyle(
            color: obtenerColorStock(stock),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),

        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar producto',
                prefixIcon:
                    const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount:
                    productosFiltrados.length,

                itemBuilder: (
                  context,
                  index,
                ) {
                  final producto =
                      productosFiltrados[index];

                  return Card(
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: const Icon(
                          Icons.image,
                        ),
                      ),

                      title: Text(
                        producto['nombre'],
                      ),

                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            producto['categoria'],
                          ),

                          Text(
                            'Stock: ${producto['stock']}',
                          ),

                          const SizedBox(height: 5),

                          estadoStock(
                            producto['stock'],
                          ),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),

                            onPressed: () {
                              mostrarDetalleProducto(
                                producto,
                              );
                            },
                          ),

                          PopupMenuButton<String>(
                            onSelected: (
                              value,
                            ) {
                              mostrarAccionProducto(
                                value,
                              );
                            },

                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value:
                                        'activar',
                                    child: Text(
                                      'Activar',
                                    ),
                                  ),

                                  PopupMenuItem(
                                    value:
                                        'desactivar',
                                    child: Text(
                                      'Desactivar',
                                    ),
                                  ),
                                ],
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