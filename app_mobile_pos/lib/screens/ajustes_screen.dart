import 'package:flutter/material.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  String monedaSeleccionada = 'BOB';
  String logoUrl = '';

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        actions: const [Icon(Icons.search)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Guardar datos');
                    },
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      nombreController.clear();
                      telefonoController.clear();
                      ciudadController.clear();
                      setState(() {
                        logoUrl = '';
                        monedaSeleccionada = 'BOB';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Ingrese nombre'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: ciudadController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: monedaSeleccionada,
              items: [
                'BOB',
                'USD',
                'EUR',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {
                setState(() {
                  monedaSeleccionada = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Moneda'),
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(labelText: 'Logo URL'),
              onChanged: (value) {
                setState(() {
                  logoUrl = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: logoUrl.isEmpty
                  ? const Center(child: Text('Preview Logo'))
                  : Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Error al cargar imagen'),
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
