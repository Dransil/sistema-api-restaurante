import 'package:flutter/material.dart';
import 'package:app_mobile_pos/core/constants/api_constants.dart';
import 'package:app_mobile_pos/data/models/producto_model.dart';
import 'package:app_mobile_pos/data/models/categoria_model.dart';
import 'package:app_mobile_pos/data/repositories/producto_repository.dart';
import 'package:app_mobile_pos/data/repositories/categoria_repository.dart';

class ProductoUiHelper {
  // Ejecuta la carga paralela inicial en la BD
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

  // Filtrado doble en memoria local (Reactivo e Instantáneo)
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

  // Lógica del semáforo de alertas para stock
  static Map<String, dynamic> analizarStock(int stock) {
    if (stock == 0) return {'txt': 'Sin stock', 'color': Colors.red};
    if (stock <= 5) return {'txt': 'Poco stock', 'color': Colors.orange};
    return {'txt': 'Disponible', 'color': Colors.green};
  }

  // Renderiza el indicador visual con la bolita de color
  static Widget dibujarIndicadorStock(int stock) {
    final info = analizarStock(stock);
    return Row(
      mainAxisSize: MainAxisSize.min,
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

  // Construye la miniatura acoplando la IP dinámica base de tu red
  static Widget construirMiniatura(String? url) {
    final String? urlCompleta = (url != null && url.isNotEmpty)
        ? '${ApiConstants.baseUrl}$url'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: urlCompleta != null
          ? Image.network(
              urlCompleta,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image, color: Colors.grey),
            )
          : const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  // Lanza barras de notificaciones personalizadas (SnackBars)
  static void notificar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior
            .floating, // Flota sobre el MainLayout de forma elegante
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Modal: Cuadro extendido de información del producto
  static void verModalDetalle(
    BuildContext context,
    ProductoModel p,
    String catNombre,
  ) {
    final String? urlCompleta = (p.imagenUrl != null && p.imagenUrl!.isNotEmpty)
        ? '${ApiConstants.baseUrl}${p.imagenUrl}'
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Detalle Producto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: urlCompleta != null
                    ? Image.network(
                        urlCompleta,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image, size: 50),
                      )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              p.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Categoría: $catNombre',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Text('Stock disponible: ${p.stock} unidades'),
            const SizedBox(height: 5),
            Text(
              'Precio: ${p.precio} BOB',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Modal: Confirmación Cambiar Estado (PATCH /productos/:id/estado)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          accion == 'activar' ? 'Activar Producto' : 'Desactivar Producto',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('¿Desea cambiar el estado de "${p.nombre}"?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accion == 'activar' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: onConfirmar,
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
