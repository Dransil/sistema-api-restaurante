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

  // Controladores para los formularios de los Diálogos
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _ciCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  // Cargar clientes desde Node.js
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

  // Guardar nuevo cliente en PostgreSQL
  Future<void> _guardarNuevoCliente() async {
    final nombre = _nombreCtrl.text.trim();
    final ci = _ciCtrl.text.trim();

    if (nombre.isEmpty || ci.isEmpty) {
      _mostrarSnackBar('Por favor llena todos los campos', Colors.amber);
      return;
    }

    Navigator.pop(context); // Cierra el Modal/Dialog
    setState(() => _isLoading = true);

    try {
      final nuevoCliente = await _clienteRepository.agregarCliente(nombre, ci);

      if (mounted) {
        _mostrarSnackBar(
          '¡${nuevoCliente.razonSocial} registrado con éxito!',
          Colors.green,
        );
        _nombreCtrl.clear();
        _ciCtrl.clear();
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarSnackBar('$e', Colors.red);
      }
    }
  }

  // Enviar los datos editados al backend mediante PUT
  Future<void> _editarClienteExistente(int id) async {
    final nombre = _nombreCtrl.text.trim();
    final ci = _ciCtrl.text.trim();

    if (nombre.isEmpty || ci.isEmpty) {
      _mostrarSnackBar('Los campos no pueden quedar vacíos', Colors.amber);
      return;
    }

    Navigator.pop(context); // Cerramos el cuadro de diálogo
    setState(() => _isLoading = true);

    try {
      // Invocamos tu método PUT /clientes/:id
      final exito = await _clienteRepository.actualizarCliente(id, nombre, ci);

      if (exito && mounted) {
        _mostrarSnackBar('Cliente actualizado correctamente', Colors.green);
        _nombreCtrl.clear();
        _ciCtrl.clear();
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarSnackBar('$e', Colors.red);
      }
    }
  }

  // Levanta el modal precargando los datos correspondientes
  void _abrirModalEdicion(ClienteModel cliente) {
    // Seteamos los controllers con los valores actuales antes de mostrar el diálogo
    _nombreCtrl.text = cliente.razonSocial;
    _ciCtrl.text = cliente.ci;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                hintText: 'Nombre / Razón Social',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ciCtrl,
              decoration: const InputDecoration(hintText: 'CI o NIT'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            // Al presionar guardar, pasamos el ID único de la fila
            onPressed: () => _editarClienteExistente(cliente.id),
            child: const Text('Guardar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () {
              _nombreCtrl.clear();
              _ciCtrl.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
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
    // Filtro reactivo en memoria local basado en lo que escribes en la barra de búsqueda
    final clientesFiltrados = clientes.where((cliente) {
      return cliente.razonSocial.toLowerCase().contains(search) ||
          cliente.ci.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Barra de Búsqueda
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

          // Botón Crear Cliente
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                _nombreCtrl.clear();
                _ciCtrl.clear();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Crear Cliente'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _nombreCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Nombre / Razón Social',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _ciCtrl,
                          decoration: const InputDecoration(
                            hintText: 'CI o NIT',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: _guardarNuevoCliente,
                        child: const Text('Guardar'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                '+ Crear Cliente',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),

          // Contenedor dinámico principal
          // Contenedor dinámico principal
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : clientesFiltrados.isEmpty
                ? const Center(child: Text('No se encontraron clientes'))
                : RefreshIndicator(
                    onRefresh: _cargarClientes,
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
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent.withOpacity(
                                0.1,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.blueAccent,
                              ),
                            ),
                            title: Text(
                              cliente.razonSocial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('CI: ${cliente.ci}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  // CONECTADO: Llamamos a la función de apertura pasando el modelo completo
                                  onPressed: () => _abrirModalEdicion(cliente),
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Editar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
