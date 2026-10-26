import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/deporte.dart';
import '../providers/favoritos_provider.dart';
import '../servicios/deportes_service.dart';
import 'vista_detalle_deporte.dart';

class VistaDeportes extends StatefulWidget {
  const VistaDeportes({super.key});

  @override
  State<VistaDeportes> createState() => _VistaDeportesState();
}

class _VistaDeportesState extends State<VistaDeportes> {
  final _service = DeportesService();
  late Future<List<Deporte>> _futuroDeportes;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    // El Future se crea una sola vez; si se creara en build()
    // la API se llamaría en cada redibujo.
    _futuroDeportes = _service.obtenerDeportes();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroDeportes = _service.obtenerDeportes();
    });
    await _futuroDeportes.catchError((_) => <Deporte>[]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Deporte>>(
      future: _futuroDeportes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'No pudimos traer los deportes.\nRevisa tu conexión.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _recargar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final deportes = (snapshot.data ?? [])
            .where((d) =>
                d.nombre.toLowerCase().contains(_busqueda.toLowerCase()))
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                onChanged: (texto) => setState(() => _busqueda = texto),
                decoration: const InputDecoration(
                  hintText: 'Buscar deporte',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recargar,
                child: deportes.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No hay deportes con ese nombre')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: deportes.length,
                        itemBuilder: (context, index) =>
                            _TarjetaDeporte(deporte: deportes[index]),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TarjetaDeporte extends StatelessWidget {
  final Deporte deporte;

  const _TarjetaDeporte({required this.deporte});

  @override
  Widget build(BuildContext context) {
    final esFavorito = context.select<FavoritosProvider, bool>(
      (f) => f.esFavorito(deporte.nombre),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VistaDetalleDeporte(deporte: deporte),
            ),
          );
        },
        child: Row(
          children: [
            Hero(
              tag: 'deporte-${deporte.id}',
              child: SizedBox(
                width: 110,
                height: 80,
                child: ImagenDeporte(url: deporte.imagen),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deporte.nombre,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deporte.formatoLegible,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (esFavorito)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.favorite, color: Colors.red, size: 20),
              ),
            const Icon(Icons.chevron_right),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// Imagen de red con un respaldo por si la API no trae foto o falla la carga
class ImagenDeporte extends StatelessWidget {
  final String url;

  const ImagenDeporte({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final respaldo = Container(
      color: Colors.green.shade100,
      child: const Icon(Icons.sports, size: 40, color: Colors.green),
    );

    if (url.isEmpty) return respaldo;

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => respaldo,
    );
  }
}
