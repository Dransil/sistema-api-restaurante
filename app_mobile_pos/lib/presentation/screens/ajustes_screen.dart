import 'package:flutter/material.dart';
import '../../../data/repositories/config_repository.dart';
import '../../../logic/helpers/config_ui_helper.dart';

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
    setState(() => _isLoading = true);
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
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() => _isLoading = false);
        ConfigUiHelper.notificar(
          context,
          'Error al cargar datos: $e',
          Colors.red,
        );
      }
      ConfigUiHelper.registrarLog(
        'Fallo la lectura en ConfigRepository',
        error: e,
        stackTrace: stackTrace,
      );
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
            _construirEncabezado(),
            const SizedBox(height: 25),
            _construirFormulario(),
            const SizedBox(height: 25),
            const Text(
              'Vista previa del logo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _construirPreviewLogo(),
            const SizedBox(height: 30),
            _construirBotonesAccion(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // WIDGET EXTRAÍDO: Encabezado con Degradado
  Widget _construirEncabezado() {
    return Container(
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
            child: Icon(Icons.settings, size: 35, color: Color(0xff6C63FF)),
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
    );
  }

  // WIDGET EXTRAÍDO: Card con Inputs del Negocio
  Widget _construirFormulario() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // CORREGIDO: con precisión flotante
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: nombreController,
            decoration: ConfigUiHelper.mapearInputDecoration(
              'Nombre del establecimiento',
              Icons.store,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            decoration: ConfigUiHelper.mapearInputDecoration(
              'Teléfono',
              Icons.phone,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ciudadController,
            decoration: ConfigUiHelper.mapearInputDecoration(
              'Ciudad',
              Icons.location_city,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: monedaSeleccionada,
            decoration: ConfigUiHelper.mapearInputDecoration(
              'Moneda',
              Icons.attach_money,
            ),
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
          ),
          const SizedBox(height: 16),
          TextField(
            controller: logoController,
            decoration: ConfigUiHelper.mapearInputDecoration(
              'Logo URL',
              Icons.image,
            ),
            onChanged: (value) => setState(() => logoUrl = value.trim()),
          ),
        ],
      ),
    );
  }

  // WIDGET EXTRAÍDO: Cuadro de Vista Previa de Imagen
  Widget _construirPreviewLogo() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // CORREGIDO: precisión estable
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
                errorBuilder: (_, _, _) => const Center(
                  child: Text(
                    'Error al cargar imagen',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
    );
  }

  // WIDGET EXTRAÍDO: Botones Guardar y Restablecer
  Widget _construirBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ConfigUiHelper.registrarLog(
                'Petición de guardado para la configuración ID: $configId',
              );
              ConfigUiHelper.notificar(
                context,
                'Cambios guardados con éxito',
                Colors.green,
              );
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
            onPressed: _cargarDatos,
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
    );
  }
}
