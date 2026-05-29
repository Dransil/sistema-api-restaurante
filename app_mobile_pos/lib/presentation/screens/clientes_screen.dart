import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/cliente_model.dart';
import 'package:app_mobile_pos/data/repositories/cliente_repository.dart';

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
        _mostrarSnackBar('Error al cargar clientes: $e', Colors.red);
      }
    }
  }

  Future<void> _guardarNuevoCliente() async {
    final nombre = _nombreCtrl.text.trim();
    final ci = _ciCtrl.text.trim();

    if (nombre.isEmpty || ci.isEmpty) {
      _mostrarSnackBar('Por favor llena todos los campos', Colors.orange);
      return;
    }

    Navigator.pop(context);

    try {
      await _clienteRepository.agregarCliente(nombre, ci);

      _mostrarSnackBar('Cliente registrado correctamente', Colors.green);

      _nombreCtrl.clear();
      _ciCtrl.clear();

      _cargarClientes();
    } catch (e) {
      _mostrarSnackBar('$e', Colors.red);
    }
  }

  Future<void> _editarClienteExistente(int id) async {
    final nombre = _nombreCtrl.text.trim();
    final ci = _ciCtrl.text.trim();

    if (nombre.isEmpty || ci.isEmpty) {
      _mostrarSnackBar('Los campos no pueden quedar vacíos', Colors.orange);
      return;
    }

    Navigator.pop(context);

    try {
      await _clienteRepository.actualizarCliente(id, nombre, ci);

      _mostrarSnackBar('Cliente actualizado correctamente', Colors.green);

      _nombreCtrl.clear();
      _ciCtrl.clear();

      _cargarClientes();
    } catch (e) {
      _mostrarSnackBar('$e', Colors.red);
    }
  }

  void _abrirModalCliente({ClienteModel? cliente}) {
    if (cliente != null) {
      _nombreCtrl.text = cliente.razonSocial;
      _ciCtrl.text = cliente.ci;
    } else {
      _nombreCtrl.clear();
      _ciCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          cliente == null ? 'Crear Cliente' : 'Editar Cliente',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ciCtrl,
              decoration: InputDecoration(
                hintText: 'CI o NIT',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                hintText: 'Razón Social',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (cliente == null) {
                _guardarNuevoCliente();
              } else {
                _editarClienteExistente(cliente.id);
              }
            },
            child: Text(cliente == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ciCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesFiltrados = clientes.where((cliente) {
      return cliente.razonSocial.toLowerCase().contains(search.toLowerCase()) ||
          cliente.ci.toLowerCase().contains(search.toLowerCase());
    }).toList();

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
        onPressed: () => _abrirModalCliente(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Buscador
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o CI',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clientesFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron clientes'))
                  : ListView.builder(
                      itemCount: clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final cliente = clientesFiltrados[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
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
                              backgroundColor: const Color(
                                0xFF6C5CE7,
                              ).withOpacity(0.15),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                            title: Text(
                              cliente.razonSocial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
                              onPressed: () =>
                                  _abrirModalCliente(cliente: cliente),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Editar'),
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
