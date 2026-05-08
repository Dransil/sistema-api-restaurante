import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/cliente_model.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  bool isCI = true;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: const [
          Icon(Icons.search),
        ],
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCI ? Colors.blue : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() {
                        isCI = true;
                      });
                    },
                    child: const Text('CI'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isCI ? Colors.blue : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() {
                        isCI = false;
                      });
                    },
                    child: const Text('Razón Social'),
                  ),
                ),
              ],
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
              child: const Text('+ Crear Cliente'),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(cliente.razonSocial),
                    subtitle: Text(
                      isCI ? cliente.ci : cliente.razonSocial,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                return AlertDialog(
                                  title: const Text('Editar Cliente'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                          hintText: 'Nombre Cliente',
                                        ),
                                        controller: TextEditingController(
                                          text: cliente.razonSocial,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      TextField(
                                        decoration: const InputDecoration(
                                          hintText: 'CI',
                                        ),
                                        controller: TextEditingController(
                                          text: cliente.ci,
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

                        const SizedBox(width: 5),

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
    );
  }
}