import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/producto_model.dart';
import 'package:app_mobile_pos/data/models/categoria_model.dart';
import 'package:app_mobile_pos/data/repositories/producto_repository.dart';
import 'package:app_mobile_pos/data/repositories/categoria_repository.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoRepository _productoRepository = ProductoRepository();
  final CategoriaRepository _categoriaRepository = CategoriaRepository();

  List<ProductoModel> productos = [];
  List<CategoriaModel> categorias = [];

  Map<int, String> mapaCategorias = {};

  int? idCategoriaSeleccionada;
  String search = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  // Cargamos categorías y productos en paralelo para optimizar el tiempo
  Future<void> _inicializarDatos() async {
    setState(() => _isLoading = true);
    try {
      final respuestas = await Future.wait([
        _categoriaRepository.obtenerCategorias(),
        _productoRepository.obtenerTodos(),
      ]);

      // ✅ Accedes por índice, no casteas la lista entera
      final listaCategorias = respuestas[0] as List<CategoriaModel>;
      final listaProductos = respuestas[1] as List<ProductoModel>;

      if (mounted) {
        setState(() {
          categorias = listaCategorias;
          productos = listaProductos;
          mapaCategorias = {
            for (var cat in listaCategorias) cat.id: cat.nombre,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarSnackBar('Error al inicializar datos: $e', Colors.red);
      }
    }
  }

  Future<void> _recargarProductos() async {
    try {
      final lista = await _productoRepository.obtenerTodos();
      if (mounted) {
        setState(() {
          productos = lista;
        });
      }
    } catch (e) {
      _mostrarSnackBar('Error al actualizar inventario: $e', Colors.red);
    }
  }

  Future<void> _alternarEstadoProducto(int id, bool estadoActual) async {
    final nuevoEstado = !estadoActual;
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final exito = await _productoRepository.cambiarEstado(id, nuevoEstado);
      if (exito && mounted) {
        _mostrarSnackBar(
          nuevoEstado ? 'Producto activado' : 'Producto desactivado',
          Colors.green,
        );
        _recargarProductos();
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
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void mostrarDetalleProducto(ProductoModel producto) {
    final nombreCategoria =
        mapaCategorias[producto.categoriaId] ?? 'Sin categoría';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalle Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Categoría: $nombreCategoria',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
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
      ),
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
    // FILTRADO DOUBLE: Filtra primero por categoría seleccionada y luego por texto del buscador
    final productosFiltrados = productos.where((producto) {
      final cumpleCategoria =
          idCategoriaSeleccionada == null ||
          producto.categoriaId == idCategoriaSeleccionada;
      final cumpleBusqueda = producto.nombre.toLowerCase().contains(search);
      return cumpleCategoria && cumpleBusqueda;
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Buscador
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => search = value.toLowerCase()),
                  ),
                ),

                // 2. NUEVA BARRA DE CATEGORÍAS HORIZONTAL
                // 2. BARRA DE CATEGORÍAS HORIZONTAL CON DETECTOR DE CARGA
                SizedBox(
                  height: 40,
                  child: _isLoading && categorias.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: LinearProgressIndicator(
                            color: Colors.blueAccent,
                          ), // <-- Barra de carga para categorías
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: categorias.length + 1, // +1 para "Todos"
                          itemBuilder: (context, index) {
                            final esPrimero = index == 0;
                            final catId = esPrimero
                                ? null
                                : categorias[index - 1].id;
                            final catNombre = esPrimero
                                ? 'Todos'
                                : categorias[index - 1].nombre;
                            final esSeleccionado =
                                idCategoriaSeleccionada == catId;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(catNombre),
                                selected: esSeleccionado,
                                selectedColor: Colors.blueAccent,
                                labelStyle: TextStyle(
                                  color: esSeleccionado
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: esSeleccionado
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                backgroundColor: Colors.grey.shade200,
                                onSelected: (_) {
                                  setState(() {
                                    idCategoriaSeleccionada = catId;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),

                // 3. Lista de Productos
                Expanded(
                  child: productosFiltrados.isEmpty
                      ? const Center(
                          child: Text('No hay productos en esta categoría'),
                        )
                      : RefreshIndicator(
                          onRefresh: _recargarProductos,
                          child: ListView.builder(
                            itemCount: productosFiltrados.length,
                            itemBuilder: (context, index) {
                              final producto = productosFiltrados[index];
                              // Traducimos el ID de la fila a su nombre real
                              final nombreCategoria =
                                  mapaCategorias[producto.categoriaId] ??
                                  'Sin categoría';

                              return Card(
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
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            child: Image.network(
                                              producto.imagenUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Categoría: $nombreCategoria',
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                        ),
                                      ), // <-- ¡MUESTRA NOMBRE EN VEZ DE ID!
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
                                            mostrarAccionProducto(
                                              producto,
                                              value,
                                            ),
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
    );
  }
}
