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
      if (mounted) {
        setState(() => productos = lista);
      }
    } catch (e) {
      ProductoUiHelper.notificar(
        context,
        'Error al actualizar: $e',
        Colors.red,
      );
    }
  }

  Future<void> _procesarCambioEstado(int id, bool estado) async {
    Navigator.pop(context); // Este está ANTES del await, así que es seguro.
    setState(() => _isLoading = true);

    try {
      final exito = await _productoRepository.cambiarEstado(id, !estado);
      await _refrescarInventario();
      if (exito && mounted) {
        ProductoUiHelper.notificar(
          context,
          !estado ? 'Producto activado' : 'Producto desactivado',
          Colors.green,
        );
        setState(() {
          _isLoading = false;
        });
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Productos',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _construirBuscador(),
                  const SizedBox(height: 18),
                  _construirBarraCategorias(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: productosFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay productos disponibles',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refrescarInventario,
                            child: ListView.builder(
                              itemCount: productosFiltrados.length,
                              itemBuilder: (context, index) =>
                                  _construirTarjetaProducto(
                                    productosFiltrados[index],
                                  ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // WIDGET EXTRAÍDO: Buscador Estilizado
  Widget _construirBuscador() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar producto...',
          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
        onChanged: (value) => setState(() => search = value.toLowerCase()),
      ),
    );
  }

  // WIDGET EXTRAÍDO: Fila Deslizable de Chips de Categoría
  Widget _construirBarraCategorias() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length + 1,
        itemBuilder: (context, index) {
          final esPrimero = index == 0;
          final catId = esPrimero ? null : categorias[index - 1].id;
          final catNombre = esPrimero ? 'Todos' : categorias[index - 1].nombre;
          final esSeleccionado = idCategoriaSeleccionada == catId;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(catNombre),
              selected: esSeleccionado,
              selectedColor: const Color(0xFF6C4AB6),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: TextStyle(
                color: esSeleccionado ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) =>
                  setState(() => idCategoriaSeleccionada = catId),
            ),
          );
        },
      ),
    );
  }

  // WIDGET EXTRAÍDO: Tarjeta Detalle de cada Producto
  Widget _construirTarjetaProducto(ProductoModel prod) {
    final nomCat = mapaCategorias[prod.categoriaId] ?? 'Sin categoría';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 80,
                height: 80,
                child: ProductoUiHelper.construirMiniatura(prod.imagenUrl),
              ),
            ),
            const SizedBox(width: 14),
            // DATOS DEL PRODUCTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.nombre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: prod.activo ? Colors.black87 : Colors.grey,
                      decoration: prod.activo
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      nomCat,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${prod.precio} BOB',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.inventory_2,
                        size: 18,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text('Stock: ${prod.stock}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProductoUiHelper.dibujarIndicadorStock(prod.stock),
                ],
              ),
            ),
            // ACCIONES (VER / MENÚ VERTICAL)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () =>
                        ProductoUiHelper.verModalDetalle(context, prod, nomCat),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.deepPurple),
                    onSelected: (accion) {
                      ProductoUiHelper.verModalAccion(
                        context,
                        prod,
                        accion,
                        () => _procesarCambioEstado(prod.id, prod.activo),
                      );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'activar', child: Text('Activar')),
                      PopupMenuItem(
                        value: 'desactivar',
                        child: Text('Desactivar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
