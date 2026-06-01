import 'dart:developer' as developer;
import 'package:app_mobile_pos/data/models/configuracion_local_model.dart';
import 'package:flutter/material.dart';

class ConfigUiHelper {
  ConfigUiHelper._();

  /// Lanza barras de notificaciones flotantes y estilizadas (SnackBars)
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

  /// Procesa de forma segura los registros en la consola de depuración
  static void registrarLog(
    String mensaje, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      mensaje,
      name: 'app.config',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Plantilla base de decoración para los campos de texto del formulario
  static InputDecoration mapearInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }

  /// Lógica de validación y armado de modelo extraída de la UI
  static ConfiguracionLocalModel? crearModeloValidado({
    required BuildContext context,
    required int? id,
    required String nombre,
    required String telefono,
    required String ciudad,
    required String moneda,
    required String logo,
  }) {
    if (nombre.isEmpty || ciudad.isEmpty) {
      notificar(
        context,
        'Establecimiento y Ciudad son obligatorios',
        Colors.orange,
      );
      return null;
    }

    return ConfiguracionLocalModel(
      id: id ?? 0,
      nombreRestaurante: nombre,
      telefono: telefono.isEmpty ? null : telefono,
      ciudad: ciudad,
      moneda: moneda,
      logoUrl: logo.isEmpty ? null : logo,
    );
  }
}
