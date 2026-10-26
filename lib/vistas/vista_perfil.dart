import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/favoritos_provider.dart';
import '../providers/partidos_provider.dart';
import '../servicios/auth_service.dart';
import '../utils/validadores.dart';

class VistaPerfil extends StatefulWidget {
  const VistaPerfil({super.key});

  @override
  State<VistaPerfil> createState() => _VistaPerfilState();
}

class _VistaPerfilState extends State<VistaPerfil> {
  final _auth = AuthService();

  // Avatares disponibles; en Supabase se guarda solo la posición
  static const List<(IconData, Color)> _avatares = [
    (Icons.person, Colors.green),
    (Icons.face, Colors.blue),
    (Icons.sports_soccer, Colors.orange),
    (Icons.pets, Colors.purple),
    (Icons.star, Colors.amber),
  ];

  User? get _usuario => Supabase.instance.client.auth.currentUser;
  Map<String, dynamic> get _datos => _usuario?.userMetadata ?? {};

  String get _nombre {
    final n = _datos['nombre'] as String?;
    return (n == null || n.isEmpty) ? 'Jugador QuickMatch' : n;
  }

  String get _bio {
    final b = _datos['bio'] as String?;
    return (b == null || b.isEmpty) ? '¡Hola! Estoy usando QuickMatch.' : b;
  }

  int get _avatar {
    final a = _datos['avatar'];
    return (a is int && a >= 0 && a < _avatares.length) ? a : 0;
  }

  Future<void> _guardarEnPerfil(Map<String, dynamic> cambios, String ok) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _auth.actualizarPerfil(cambios);
      if (mounted) setState(() {});
      messenger.showSnackBar(SnackBar(content: Text(ok)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
    }
  }

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
              for (var i = 0; i < _avatares.length; i++)
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _guardarEnPerfil({'avatar': i}, 'Foto de perfil actualizada');
                  },
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: _avatares[i].$2,
                    child: Icon(_avatares[i].$1, size: 32, color: Colors.white),
                  ),
                ),
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

  void _mostrarDialogoEditarTexto() {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: _datos['nombre'] ?? '');
    final bioController = TextEditingController(text: _datos['bio'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Información'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    textCapitalization: TextCapitalization.words,
                    validator: validarObligatorio('tu nombre', minimo: 2),
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioController,
                    maxLines: 2,
                    maxLength: 120,
                    validator: (valor) => (valor?.length ?? 0) > 120
                        ? 'Máximo 120 caracteres'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Descripción / Biografía',
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext);
                _guardarEnPerfil(
                  {
                    'nombre': nombreController.text.trim(),
                    'bio': bioController.text.trim(),
                  },
                  'Información actualizada',
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cerrarSesion() async {
    final partidos = context.read<PartidosProvider>();
    final favoritos = context.read<FavoritosProvider>();
    await _auth.cerrarSesion();
    partidos.limpiar();
    favoritos.limpiar();
    // AuthGate vuelve solo al login
  }

  @override
  Widget build(BuildContext context) {
    final (icono, color) = _avatares[_avatar];
    final partidos = context.watch<PartidosProvider>();
    final favoritos = context.watch<FavoritosProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                // Al cambiar de avatar el color y el borde cambian con animación
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.35),
                      width: 6,
                    ),
                  ),
                  child: Icon(icono, size: 56, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                      tooltip: 'Cambiar foto',
                      padding: EdgeInsets.zero,
                      onPressed: _mostrarSelectorDeFoto,
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
              _usuario?.email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _bio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _Estadistica(
                  valor: '${partidos.partidos.length}',
                  etiqueta: 'Partidos',
                ),
                _Estadistica(
                  valor: '${partidos.proximos}',
                  etiqueta: 'Próximos',
                ),
                _Estadistica(
                  valor: '${favoritos.cantidad}',
                  etiqueta: 'Deportes fav.',
                ),
              ],
            ),
            if (favoritos.cantidad > 0) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final d in favoritos.favoritos)
                    Chip(
                      label: Text(d),
                      avatar: const Icon(Icons.favorite,
                          size: 16, color: Colors.red),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Editar Datos Personales'),
              onTap: _mostrarDialogoEditarTexto,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  final String valor;
  final String etiqueta;

  const _Estadistica({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(etiqueta, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
