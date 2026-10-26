import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/deporte.dart';
import '../providers/favoritos_provider.dart';
import 'formulario_partido.dart';
import 'vista_deportes.dart';

// Recibe el deporte por el constructor desde la lista
class VistaDetalleDeporte extends StatefulWidget {
  final Deporte deporte;

  const VistaDetalleDeporte({super.key, required this.deporte});

  @override
  State<VistaDetalleDeporte> createState() => _VistaDetalleDeporteState();
}

class _VistaDetalleDeporteState extends State<VistaDetalleDeporte> {
  bool _mostrarTexto = false;
  bool _expandido = false;

  @override
  void initState() {
    super.initState();
    // Se espera a que termine el Hero antes de mostrar el texto
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _mostrarTexto = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deporte = widget.deporte;
    final favoritos = context.watch<FavoritosProvider>();
    final esFavorito = favoritos.esFavorito(deporte.nombre);

    return Scaffold(
      appBar: AppBar(
        title: Text(deporte.nombre),
        actions: [
          IconButton(
            tooltip: esFavorito ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: () => favoritos.alternar(deporte.nombre),
            icon: AnimatedScale(
              scale: esFavorito ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: esFavorito ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormularioPartido(deporteInicial: deporte.nombre),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Armar partido'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          Hero(
            tag: 'deporte-${deporte.id}',
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: ImagenDeporte(url: deporte.imagen),
            ),
          ),
          AnimatedOpacity(
            opacity: _mostrarTexto ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deporte.nombre,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.groups, size: 18),
                    label: Text(deporte.formatoLegible),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  // Se puede expandir; la API trae textos bastante largos
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.topCenter,
                    child: Text(
                      deporte.descripcion,
                      maxLines: _expandido ? null : 6,
                      overflow: _expandido
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _expandido = !_expandido),
                    child: Text(_expandido ? 'Ver menos' : 'Leer más'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
