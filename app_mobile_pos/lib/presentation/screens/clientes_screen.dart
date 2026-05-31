import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/cliente_model.dart';
import 'package:app_mobile_pos/data/repositories/cliente_repository.dart';
import 'package:app_mobile_pos/logic/helpers/cliente_ui_helper.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteRepository _clienteRepository = ClienteRepository();

  List<ClienteModel> clientes = [];
  String search = '';
  bool _isLoading = true;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _ciCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() => _isLoading = true);
    try {
      final lista = await _clienteRepository.obtenerClientes();
      if (mounted) {
        setState(() {
          clientes = lista;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ClienteUiHelper.notificar(
          context,
          'Error al cargar clientes: $e',
          Colors.red,
        );
      }
    }
  }

  Future<void> _guardarNuevoCliente() async {
    final nombre = _nombreCtrl.text.trim();
    final ci = _ciCtrl.text.trim();

    if (nombre.isEmpty || ci.isEmpty) {
      ClienteUiHelper.notificar(
        context,
        'Por favor llena todos los campos',
        Colors.orange,
      );
      return;
    }

    Navigator.pop(context);

    try {
      await _clienteRepository.agregarCliente(nombre, ci);

      if (mounted) {
        ClienteUiHelper.notificar(
          context,
          'Cliente registrado correctamente',
          Colors.green,
        );
        _nombreCtrl.clear();
        _ciCtrl.clear();
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) ClienteUiHelper.notificar(context, '$e', Colors.red);
    }
  }

  Future<void> _editarClienteExistente(int id) async {
    final nombre = _nombreCtrl.text.trim();
    final ci = _ciCtrl.text.trim();

    if (nombre.isEmpty || ci.isEmpty) {
      ClienteUiHelper.notificar(
        context,
        'Los campos no pueden quedar vacíos',
        Colors.orange,
      );
      return;
    }

    Navigator.pop(context);

    try {
      await _clienteRepository.actualizarCliente(id, nombre, ci);

      if (mounted) {
        ClienteUiHelper.notificar(
          context,
          'Cliente actualizado correctamente',
          Colors.green,
        );
        _nombreCtrl.clear();
        _ciCtrl.clear();
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) ClienteUiHelper.notificar(context, '$e', Colors.red);
    }
  }

  void _desplegarFormulario({ClienteModel? cliente}) {
    ClienteUiHelper.verModalCliente(
      context: context,
      nombreCtrl: _nombreCtrl,
      ciCtrl: _ciCtrl,
      cliente: cliente,
      onConfirmar: () {
        if (cliente == null) {
          _guardarNuevoCliente();
        } else {
          _editarClienteExistente(cliente.id);
        }
      },
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ciCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesFiltrados = ClienteUiHelper.filtrar(clientes, search);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF24124D),
        title: const Text(
          'Clientes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C5CE7),
        onPressed: _desplegarFormulario,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _construirBuscador(),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clientesFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron clientes'))
                  : RefreshIndicator(
                      onRefresh: _cargarClientes,
                      child: ListView.builder(
                        itemCount: clientesFiltrados.length,
                        itemBuilder: (context, index) =>
                            _construirTarjetaCliente(clientesFiltrados[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET EXTRAÍDO: Buscador superior con elevación sutil
  Widget _construirBuscador() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar por nombre o CI...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) => setState(() => search = value),
      ),
    );
  }

  // WIDGET EXTRAÍDO: Tarjeta contenedora de datos del cliente
  Widget _construirTarjetaCliente(ClienteModel cliente) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
          child: const Icon(Icons.person, color: Color(0xFF6C5CE7)),
        ),
        title: Text(
          cliente.razonSocial,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'CI: ${cliente.ci}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D4059),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _desplegarFormulario(cliente: cliente),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Editar'),
        ),
      ),
    );
  }
}
