import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/cliente_model.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  String search = '';

  final List<ClienteModel> clientes = [
    ClienteModel(
      id: 1,
      razonSocial: 'Juan Pérez',
      ci: '123456',
      pedidosRealizados: 5,
      createdAt: DateTime.now(),
    ),
    ClienteModel(
      id: 2,
      razonSocial: 'Empresa SRL',
      ci: '7891011',
      pedidosRealizados: 10,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final clientesFiltrados = clientes.where((cliente) {
      return cliente.razonSocial.toLowerCase().contains(search) ||
          cliente.ci.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o CI',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Crear Cliente'),

                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Nombre Cliente',
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            decoration: const InputDecoration(hintText: 'CI'),
                          ),
                        ],
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
              child: const Text('+ Crear Cliente'),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: clientesFiltrados.length,
              itemBuilder: (context, index) {
                final cliente = clientesFiltrados[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  child: ListTile(
                    title: Text(cliente.razonSocial),

                    subtitle: Text('CI: ${cliente.ci}'),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),

                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Editar Cliente'),

                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: TextEditingController(
                                          text: cliente.razonSocial,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Nombre Cliente',
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      TextField(
                                        controller: TextEditingController(
                                          text: cliente.ci,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'CI',
                                        ),
                                      ),
                                    ],
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
