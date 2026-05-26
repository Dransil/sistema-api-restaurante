import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/producto_model.dart';
import 'package:app_mobile_pos/data/repositories/producto_repository.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoRepository _productoRepository = ProductoRepository();

  List<ProductoModel> productos = [];
  String search = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  // Carga de productos desde PostgreSQL
  Future<void> _cargarProductos() async {
    setState(() => _isLoading = true);
    try {
      final lista = await _productoRepository.obtenerTodos();
      if (mounted) {
        setState(() {
          productos = lista;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarSnackBar('Error al cargar inventario: $e', Colors.red);
      }
    }
  }

  // Cambiar el estado del producto usando tu método PATCH
  Future<void> _alternarEstadoProducto(int id, bool estadoActual) async {
    final nuevoEstado = !estadoActual;
    Navigator.pop(context); // Cierra el diálogo de confirmación
    setState(() => _isLoading = true);

    try {
      final exito = await _productoRepository.cambiarEstado(id, nuevoEstado);
      if (exito && mounted) {
        _mostrarSnackBar(
          nuevoEstado ? 'Producto activado' : 'Producto desactivado',
          Colors.green,
        );
        _cargarProductos(); // Recargamos el listado fresco
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarSnackBar('$e', Colors.red);
      }
    }
  }

  String obtenerEstadoStock(int stock) {
    if (stock == 0) return 'Sin stock';
    if (stock <= 5) return 'Poco stock';
    return 'Disponible';
  }

  Color obtenerColorStock(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
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

  // Diálogo para activar/desactivar producto
  void mostrarAccionProducto(ProductoModel producto, String accion) {
    if ((accion == 'activar' && producto.activo) ||
        (accion == 'desactivar' && !producto.activo)) {
      _mostrarSnackBar(
        'El producto ya se encuentra en ese estado',
        Colors.amber,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            accion == 'activar' ? 'Activar Producto' : 'Desactivar Producto',
          ),
          content: Text('¿Desea cambiar el estado de "${producto.nombre}"?'),
          actions: [
            ElevatedButton(
              onPressed: () =>
                  _alternarEstadoProducto(producto.id, producto.activo),
              child: const Text('Aceptar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Modal con el detalle extendido del producto
  void mostrarDetalleProducto(ProductoModel producto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalle Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Carga dinámica de la imagen
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                    ? Image.network(
                        producto.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Text(
                producto.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text('ID Categoría: ${producto.categoriaId ?? "Sin categoría"}'),
              Text('Stock: ${producto.stock} unidades'),
              Text(
                'Precio: ${producto.precio} BOB',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget estadoStock(int stock) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: obtenerColorStock(stock),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          obtenerEstadoStock(stock),
          style: TextStyle(
            color: obtenerColorStock(stock),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtro en memoria usando tu propiedad exacta 'nombre'
    final productosFiltrados = productos.where((producto) {
      return producto.nombre.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Buscador
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
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
            const SizedBox(height: 10),

            // Lista o Loader
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productosFiltrados.isEmpty
                  ? const Center(child: Text('No hay productos registrados'))
                  : RefreshIndicator(
                      onRefresh: _cargarProductos,
                      child: ListView.builder(
                        itemCount: productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];

                          return Card(
                            // Opaca la tarjeta si el producto está inactivo en la BD (activo == false)
                            color: producto.activo
                                ? null
                                : Colors.grey.shade100,
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child:
                                    producto.imagenUrl != null &&
                                        producto.imagenUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                          producto.imagenUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                  ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.fastfood,
                                        color: Colors.grey,
                                      ),
                              ),
                              title: Text(
                                producto.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: producto.activo
                                      ? Colors.black87
                                      : Colors.grey,
                                  decoration: producto.activo
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Precio: ${producto.precio} BOB'),
                                  Text('Stock: ${producto.stock}'),
                                  const SizedBox(height: 4),
                                  estadoStock(producto.stock),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        mostrarDetalleProducto(producto),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) =>
                                        mostrarAccionProducto(producto, value),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'activar',
                                        child: Text('Activar'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'desactivar',
                                        child: Text('Desactivar'),
                                      ),
                                    ],
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
      ),
    );
  }
}
