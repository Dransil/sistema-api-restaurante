import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/producto_model.dart';
import 'package:app_mobile_pos/data/models/categoria_model.dart';
import 'package:app_mobile_pos/data/repositories/producto_repository.dart';
import 'package:app_mobile_pos/data/repositories/categoria_repository.dart';
import 'package:app_mobile_pos/logic/helpers/producto_ui_helper.dart';

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
    _cargarDatosIniciales();
  }

  // Lógica de carga delegada
  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final datos = await ProductoUiHelper.inicializarTodo(
        _productoRepository,
        _categoriaRepository,
      );
      if (mounted) {
        setState(() {
          categorias = datos['categorias'];
          productos = datos['productos'];
          mapaCategorias = datos['mapa'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ProductoUiHelper.notificar(context, 'Error: $e', Colors.red);
      }
    }
  }

  Future<void> _refrescarInventario() async {
    try {
      final lista = await _productoRepository.obtenerTodos();
      if (mounted) setState(() => productos = lista);
    } catch (e) {
      ProductoUiHelper.notificar(
        context,
        'Error al actualizar: $e',
        Colors.red,
      );
    }
  }

  Future<void> _procesarCambioEstado(int id, bool estado) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      final exito = await _productoRepository.cambiarEstado(id, !estado);
      if (exito && mounted) {
        ProductoUiHelper.notificar(
          context,
          !estado ? 'Producto activado' : 'Producto desactivado',
          Colors.green,
        );
        _refrescarInventario();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ProductoUiHelper.notificar(context, '$e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosFiltrados = ProductoUiHelper.filtrar(
      productos,
      idCategoriaSeleccionada,
      search,
    );

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

                // 2. Barra Horizonal de Categorías
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: categorias.length + 1,
                    itemBuilder: (context, index) {
                      final esPrimero = index == 0;
                      final catId = esPrimero ? null : categorias[index - 1].id;
                      final catNombre = esPrimero
                          ? 'Todos'
                          : categorias[index - 1].nombre;
                      final esSel = idCategoriaSeleccionada == catId;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(catNombre),
                          selected: esSel,
                          selectedColor: Colors.blueAccent,
                          labelStyle: TextStyle(
                            color: esSel ? Colors.white : Colors.black87,
                            fontWeight: esSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.grey.shade200,
                          onSelected: (_) =>
                              setState(() => idCategoriaSeleccionada = catId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Listado de productos
                Expanded(
                  child: productosFiltrados.isEmpty
                      ? const Center(
                          child: Text('No hay productos en esta categoría'),
                        )
                      : RefreshIndicator(
                          onRefresh: _refrescarInventario,
                          child: ListView.builder(
                            itemCount: productosFiltrados.length,
                            itemBuilder: (context, index) {
                              final prod = productosFiltrados[index];
                              final nomCat =
                                  mapaCategorias[prod.categoriaId] ??
                                  'Sin categoría';

                              return Card(
                                color: prod.activo
                                    ? null
                                    : Colors.grey.shade100,
                                child: ListTile(
                                  leading: ProductoUiHelper.construirMiniatura(
                                    prod.imagenUrl,
                                  ),
                                  title: Text(
                                    prod.nombre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: prod.activo
                                          ? Colors.black87
                                          : Colors.grey,
                                      decoration: prod.activo
                                          ? null
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Categoría: $nomCat',
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      Text('Precio: ${prod.precio} BOB'),
                                      Text('Stock: ${prod.stock}'),
                                      const SizedBox(height: 4),
                                      ProductoUiHelper.dibujarIndicadorStock(
                                        prod.stock,
                                      ), // Widget extraído
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
                                            ProductoUiHelper.verModalDetalle(
                                              context,
                                              prod,
                                              nomCat,
                                            ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (accion) =>
                                            ProductoUiHelper.verModalAccion(
                                              context,
                                              prod,
                                              accion,
                                              () => _procesarCambioEstado(
                                                prod.id,
                                                prod.activo,
                                              ),
                                            ),
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'activar',
                                            child: Text('Activar'),
                                          ),
                                          PopupMenuItem(
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
