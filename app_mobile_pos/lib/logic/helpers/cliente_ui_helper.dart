import 'package:flutter/material.dart';
import 'package:app_mobile_pos/data/models/cliente_model.dart';

class ClienteUiHelper {
  ClienteUiHelper._();

  /// Filtrado doble en memoria local basado en Razón Social o CI
  static List<ClienteModel> filtrar(List<ClienteModel> lista, String query) {
    final cleanQuery = query.toLowerCase().trim();
    return lista.where((cliente) {
      return cliente.razonSocial.toLowerCase().contains(cleanQuery) ||
          cliente.ci.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  /// Lanza barras de notificaciones flotantes estilizadas (SnackBars)
  static void notificar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Despliega el formulario modal interactivo para Crear o Editar un cliente
  static void verModalCliente({
    required BuildContext context,
    required TextEditingController nombreCtrl,
    required TextEditingController ciCtrl,
    required VoidCallback onConfirmar,
    ClienteModel? cliente,
  }) {
    if (cliente != null) {
      nombreCtrl.text = cliente.razonSocial;
      ciCtrl.text = cliente.ci;
    } else {
      nombreCtrl.clear();
      ciCtrl.clear();
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
              controller: ciCtrl,
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
              controller: nombreCtrl,
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
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onConfirmar,
            child: Text(cliente == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}
