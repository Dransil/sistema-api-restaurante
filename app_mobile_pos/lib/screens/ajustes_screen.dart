import 'package:flutter/material.dart';
import '../../data/repositories/config_repository.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final ConfigRepository _configRepository = ConfigRepository();

  String monedaSeleccionada = 'BOB';
  String logoUrl = '';
  int?
  configId; // Guardamos el ID para cuando toque hacer el UPDATE mas adelante
  bool _isLoading = true;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController logoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Método para traer la configuración desde PostgreSQL
  Future<void> _cargarDatos() async {
    try {
      final config = await _configRepository.obtenerConfiguracion();

      if (config != null && mounted) {
        setState(() {
          configId = config.id;
          nombreController.text = config.nombreRestaurante;
          telefonoController.text = config.telefono ?? '';
          ciudadController.text = config.ciudad;
          logoController.text = config.logoUrl ?? '';
          logoUrl = config.logoUrl ?? '';

          // Validamos que la moneda exista en los items del Dropdown
          if (['BOB', 'USD', 'EUR'].contains(config.moneda)) {
            monedaSeleccionada = config.moneda;
          }
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    ciudadController.dispose();
    logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si los datos se están descargando de tu red local, mostramos un loader
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Guardar datos con ID: $configId');
                    },
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _cargarDatos(); // Al cancelar, volvemos a traer el estado original de la BD
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Restablecer'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Establecimiento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: ciudadController,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Moneda',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: logoController,
              decoration: const InputDecoration(
                labelText: 'Logo URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  logoUrl = value.trim();
                });
              },
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Vista previa del Logo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),

            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: logoUrl.isEmpty
                  ? const Center(child: Text('Sin Logo registrado'))
                  : Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Error al cargar la imagen',
                            style: TextStyle(color: Colors.red),
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
