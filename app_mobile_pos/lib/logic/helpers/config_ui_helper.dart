import 'dart:developer' as developer;
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
}
