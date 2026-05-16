import 'package:flutter/material.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  String filtro = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: const [Icon(Icons.search)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Activos', 'Inactivos', 'Categoría A']
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filtro == e
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                          onPressed: () {
                            setState(() {
                              filtro = e;
                            });
                          },
                          child: Text(e),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String categoria = 'Categoría A';

                    return AlertDialog(
                      title: const Text('Agregar Producto'),

                      content: StatefulBuilder(
                        builder: (context, setModalState) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Nombre producto',
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Stock',
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Imagen',
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.camera_alt),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                DropdownButtonFormField<String>(
                                  value: categoria,
                                  items:
                                      [
                                            'Categoría A',
                                            'Categoría B',
                                            'Categoría C',
                                          ]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setModalState(() {
                                      categoria = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Guardar'),
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
              child: const Text('+ Agregar Producto'),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),

                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(border: Border.all()),
                        child: const Icon(Icons.image),
                      ),

                      title: Text(
                        'Producto ${String.fromCharCode(65 + index)}',
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Categoría'),

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? Colors.red
                                      : index == 1
                                      ? Colors.amber
                                      : Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                index == 0
                                    ? 'Sin stock'
                                    : index == 1
                                    ? 'Poco stock'
                                    : 'Disponible',
                                style: TextStyle(
                                  color: index == 0
                                      ? Colors.red
                                      : index == 1
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 👁 Ver detalle
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () {
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
                                          'Producto ${String.fromCharCode(65 + index)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        const Text('Categoría: Categoría A'),
                                        const Text('Stock: 20'),
                                        const Text('Precio: \$120.00'),
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
                            },
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String categoria = 'Categoría A';

                                  return AlertDialog(
                                    title: const Text('Editar Producto'),

                                    content: StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: TextEditingController(
                                                  text:
                                                      'Producto ${String.fromCharCode(65 + index)}',
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          'Nombre producto',
                                                    ),
                                              ),

                                              const SizedBox(height: 10),

                                              TextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                      hintText: 'Stock',
                                                    ),
                                              ),

                                              const SizedBox(height: 10),

                                              TextField(
                                                decoration: InputDecoration(
                                                  hintText: 'Imagen',
                                                  suffixIcon: IconButton(
                                                    icon: const Icon(
                                                      Icons.camera_alt,
                                                    ),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              DropdownButtonFormField<String>(
                                                value: categoria,
                                                items:
                                                    [
                                                          'Categoría A',
                                                          'Categoría B',
                                                          'Categoría C',
                                                        ]
                                                        .map(
                                                          (e) =>
                                                              DropdownMenuItem(
                                                                value: e,
                                                                child: Text(e),
                                                              ),
                                                        )
                                                        .toList(),
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    categoria = value!;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Guardar'),
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
                            child: const Text('Editar'),
                          ),

                          const SizedBox(width: 5),

                          PopupMenuButton<String>(
                            onSelected: (value) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      value == 'activar'
                                          ? 'Activar Producto'
                                          : 'Desactivar Producto',
                                    ),

                                    content: Text(
                                      value == 'activar'
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
                            },

                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'activar',
                                child: Text('Activar'),
                              ),

                              PopupMenuItem(
                                value: 'desactivar',
                                child: Text('Desactivar'),
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
