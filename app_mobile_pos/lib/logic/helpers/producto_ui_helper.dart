import 'package:app_mobile_pos/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/producto_model.dart';
import 'package:app_mobile_pos/data/models/categoria_model.dart';
import 'package:app_mobile_pos/data/repositories/producto_repository.dart';
import 'package:app_mobile_pos/data/repositories/categoria_repository.dart';

class ProductoUiHelper {
  // Ejecuta la carga paralela inicial
  static Future<Map<String, dynamic>> inicializarTodo(
    ProductoRepository prodRepo,
    CategoriaRepository catRepo,
  ) async {
    final respuestas = await Future.wait([
      catRepo.obtenerCategorias(),
      prodRepo.obtenerTodos(),
    ]);

    final listaCategorias = respuestas[0] as List<CategoriaModel>;
    final listaProductos = respuestas[1] as List<ProductoModel>;

    return {
      'categorias': listaCategorias,
      'productos': listaProductos,
      'mapa': {for (var cat in listaCategorias) cat.id: cat.nombre},
    };
  }

  // Filtrado doble en memoria
  static List<ProductoModel> filtrar(
    List<ProductoModel> lista,
    int? catId,
    String query,
  ) {
    return lista.where((p) {
      final matchCat = catId == null || p.categoriaId == catId;
      final matchQuery = p.nombre.toLowerCase().contains(query);
      return matchCat && matchQuery;
    }).toList();
  }

  // Lógica del semáforo de stock
  static Map<String, dynamic> analizarStock(int stock) {
    if (stock == 0) return {'txt': 'Sin stock', 'color': Colors.red};
    if (stock <= 5) return {'txt': 'Poco stock', 'color': Colors.orange};
    return {'txt': 'Disponible', 'color': Colors.green};
  }

  // Renderiza el indicador con la bolita de color
  static Widget dibujarIndicadorStock(int stock) {
    final info = analizarStock(stock);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: info['color'],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          info['txt'],
          style: TextStyle(
            color: info['color'],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // Construye el avatar o miniatura de la imagen
  static Widget construirMiniatura(String? url) {
    final String? urlCompleta = (url != null && url.isNotEmpty)
        ? '${ApiConstants.baseUrl}$url'
        : null;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: urlCompleta != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                urlCompleta,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            )
          : const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  // Muestra notificaciones rápidas
  static void notificar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Modal: Ver Detalle
  static void verModalDetalle(
    BuildContext context,
    ProductoModel p,
    String catNombre,
  ) {
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
              child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                  ? Image.network(
                      p.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 50),
                    )
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Text(
              p.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Categoría: $catNombre',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text('Stock: ${p.stock} unidades'),
            Text(
              'Precio: ${p.precio} BOB',
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

  // Modal: Confirmación Cambiar Estado
  static void verModalAccion(
    BuildContext context,
    ProductoModel p,
    String accion,
    VoidCallback onConfirmar,
  ) {
    if ((accion == 'activar' && p.activo) ||
        (accion == 'desactivar' && !p.activo)) {
      notificar(
        context,
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
        content: Text('¿Desea cambiar el estado de "${p.nombre}"?'),
        actions: [
          ElevatedButton(onPressed: onConfirmar, child: const Text('Aceptar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
