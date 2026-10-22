import 'package:flutter/material.dart';

class VistaPerfil extends StatefulWidget {
  const VistaPerfil({super.key});

  @override
  State<VistaPerfil> createState() => _VistaPerfilState();
}

class _VistaPerfilState extends State<VistaPerfil> {
  // Datos del perfil
  String _nombre = 'Usuario QuickMatch';
  String _email = 'usuario@ejemplo.com';
  String _bio = '¡Hola! Estoy usando QuickMatch.';

  // Icono o imagen actual del avatar
  IconData _iconoPerfil = Icons.person;

  // Controladores para el diálogo de texto
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: _nombre);
    _emailController = TextEditingController(text: _email);
    _bioController = TextEditingController(text: _bio);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Diálogo exclusivo para cambiar la foto/icono de perfil
  void _mostrarSelectorDeFoto() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Seleccionar Avatar'),
          content: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _opcionAvatar(Icons.person, Colors.green),
              _opcionAvatar(Icons.face, Colors.blue),
              _opcionAvatar(Icons.sports_soccer, Colors.orange),
              _opcionAvatar(Icons.pets, Colors.purple),
              _opcionAvatar(Icons.star, Colors.amber),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _opcionAvatar(IconData icono, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _iconoPerfil = icono;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      },
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icono, size: 32, color: Colors.white),
      ),
    );
  }

  // Diálogo para editar solo los textos (nombre, correo, biografía)
  void _mostrarDialogoEditarTexto() {
    _nombreController.text = _nombre;
    _emailController.text = _email;
    _bioController.text = _bio;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Información'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bioController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción / Biografía',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _nombre = _nombreController.text;
                  _email = _emailController.text;
                  _bio = _bioController.text;
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Información actualizada')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  child: Icon(_iconoPerfil, size: 60, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      tooltip: 'Cambiar foto',
                      padding: EdgeInsets.zero,
                      onPressed: _mostrarSelectorDeFoto, // Abre la selección de foto
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _bio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Editar Datos Personales'),
              onTap: _mostrarDialogoEditarTexto, // Abre la edición de textos
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
