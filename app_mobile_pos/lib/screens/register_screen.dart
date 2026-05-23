import 'package:flutter/material.dart';
import '../../data/repositories/usuario_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _selectedRolId = 2;
  bool _isLoading = false;

  Future<void> _registrar() async {
    final username = _userController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _mostrarMensaje("Por favor, llena todos los campos", Colors.amber);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nuevoUsuario = await _usuarioRepository.register(
        username: username,
        password: password,
        rolId: _selectedRolId,
      );

      if (mounted) {
        _mostrarMensaje(
          "¡Usuario ${nuevoUsuario.username} registrado con éxito!",
          Colors.green,
        );
        // Volvemos al Login de forma limpia
        Navigator.pop(context);
      }
    } catch (e) {
      // Captura los mensajes exactos de passSegura(password) lanzados por el repositorio (ej: statusCode 400)
      String mensajeError = e.toString().replaceAll("Exception: ", "");
      _mostrarMensaje(mensajeError, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Registro de Personal",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Input de Usuario
            TextField(
              controller: _userController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Nombre de Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_add),
              ),
            ),
            const SizedBox(height: 20),

            // Input de Contraseña
            TextField(
              controller: _passwordController,
              obscureText: true,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown de selección de Rol mapeando los IDs de PostgreSQL
            DropdownButtonFormField<int>(
              value: _selectedRolId,
              // REMOVEMOS: enabled: !_isLoading, <-- Esto causaba el error
              decoration: const InputDecoration(
                labelText: 'Rol asignado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              // SOLUCIÓN: Si está cargando, pasamos null a onChanged para deshabilitarlo
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedRolId = value!;
                      });
                    },
              items: const [
                DropdownMenuItem(value: 1, child: Text('Administrador')),
                DropdownMenuItem(value: 2, child: Text('Cajero / Mesero')),
              ],
            ),
            const SizedBox(height: 30),

            // Botón de Registro
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Registrar Usuario",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
