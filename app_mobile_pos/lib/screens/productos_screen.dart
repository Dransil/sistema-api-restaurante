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
        actions: const [
          Icon(Icons.search),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // 🔘 Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Todos',
                  'Activos',
                  'Inactivos',
                  'Categoría A',
                ]
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                filtro == e
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

            // 🟢 Agregar producto
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
                                  items: [
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
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: const Icon(Icons.image),
                      ),

                      title: Text(
                        'Producto ${String.fromCharCode(65 + index)}',
                      ),

                      subtitle: const Text('Categoría'),

                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('\$120.00'),
                          const SizedBox(height: 5),
                          const Icon(Icons.more_vert),
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