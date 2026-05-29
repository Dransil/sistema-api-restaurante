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
  int? configId;
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

          if (['BOB', 'USD', 'EUR'].contains(config.moneda)) {
            monedaSeleccionada = config.moneda;
          }

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration customInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Ajustes',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6C63FF), Color(0xff8E85FF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.settings,
                      size: 35,
                      color: Color(0xff6C63FF),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Configuración del Negocio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Administra la información principal',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// CARD FORMULARIO
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: customInput(
                      'Nombre del establecimiento',
                      Icons.store,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: customInput('Teléfono', Icons.phone),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: ciudadController,
                    decoration: customInput('Ciudad', Icons.location_city),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: monedaSeleccionada,

                    decoration: customInput('Moneda', Icons.attach_money),

                    items: ['BOB', 'USD', 'EUR']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),

                    onChanged: (value) {
                      setState(() {
                        monedaSeleccionada = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: logoController,

                    decoration: customInput('Logo URL', Icons.image),

                    onChanged: (value) {
                      setState(() {
                        logoUrl = value.trim();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// PREVIEW LOGO
            const Text(
              'Vista previa del logo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              height: 180,
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),

              child: logoUrl.isEmpty
                  ? const Center(
                      child: Text(
                        'Sin logo registrado',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.contain,

                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Error al cargar imagen',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 30),

            /// BOTONES
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('Guardar datos con ID: $configId');
                    },

                    icon: const Icon(Icons.save),

                    label: const Text('Guardar'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _cargarDatos();
                    },

                    icon: const Icon(Icons.refresh),

                    label: const Text('Restablecer'),

                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
