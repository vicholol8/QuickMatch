import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/partido.dart';
import '../modelos/reglas_deporte.dart';
import '../providers/partidos_provider.dart';
import '../servicios/auth_service.dart';
import '../servicios/partidos_service.dart';
import '../utils/fechas.dart';

// Partido vinculado a un anuncio: muestra cuántos faltan y deja sumarse
class TarjetaPartidoFeed extends StatefulWidget {
  final Partido partido;
  final Future<void> Function() onCambio;

  const TarjetaPartidoFeed({
    super.key,
    required this.partido,
    required this.onCambio,
  });

  @override
  State<TarjetaPartidoFeed> createState() => _TarjetaPartidoFeedState();
}

class _TarjetaPartidoFeedState extends State<TarjetaPartidoFeed> {
  final _service = PartidosService();
  bool _ocupado = false;

  String? get _miId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> _alternarAsistencia() async {
    final partido = widget.partido;
    final yaEstoy = partido.sumado(_miId);
    final messenger = ScaffoldMessenger.of(context);
    final partidos = context.read<PartidosProvider>();

    setState(() => _ocupado = true);
    try {
      if (yaEstoy) {
        await _service.salirme(partido.id!);
      } else {
        await _service.sumarme(partido.id!, nombreDelUsuario());
      }
      // Primero calendario y chats: al recargar el feed esta tarjeta
      // se reconstruye y ya no se podría usar su context
      await partidos.cargar();
      await widget.onCambio();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            yaEstoy ? 'Te saliste del partido' : '¡Listo, te sumaste!',
          ),
        ),
      );
    } on PostgrestException catch (e) {
      // RLS rechaza el insert cuando alguien tomó el último cupo antes
      final texto = e.code == '42501'
          ? 'Ya no quedan cupos en este partido'
          : mensajeDeError(e);
      messenger.showSnackBar(SnackBar(content: Text(texto)));
      await widget.onCambio();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partido = widget.partido;
    final colores = Theme.of(context).colorScheme;
    final (deporte, _) = buscarModalidad(partido.deporte);
    final esMio = partido.userId == _miId;
    final yaEstoy = partido.sumado(_miId);
    final yaPaso = partido.fecha.isBefore(DateTime.now());
    final ocupados = partido.asistentes.length;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colores.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: colores.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colores.primaryContainer,
                child: Icon(deporte.icono, color: colores.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partido.deporte,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${partido.lugar}\n${fechaCorta(partido.fecha)} hrs',
                      style: TextStyle(
                        fontSize: 13,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: partido.cupos == 0 ? 1 : ocupados / partido.cupos,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            partido.completo
                ? 'Completo · ${partido.cupos} de ${partido.cupos} cupos tomados'
                : partido.faltan == 1
                ? 'Falta 1 jugador'
                : 'Faltan ${partido.faltan} de ${partido.cupos} jugadores',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (partido.asistentes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in partido.asistentes)
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: colorDePersona(a.nombre),
                      child: Text(
                        a.nombre.characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    label: Text(
                      a.userId == _miId ? 'Tú' : a.nombre,
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _boton(esMio, yaEstoy, yaPaso),
          ),
        ],
      ),
    );
  }

  Widget _boton(bool esMio, bool yaEstoy, bool yaPaso) {
    if (yaPaso) {
      return const OutlinedButton(onPressed: null, child: Text('Ya se jugó'));
    }
    if (esMio) {
      return const OutlinedButton(
        onPressed: null,
        child: Text('Es tu partido'),
      );
    }
    if (yaEstoy) {
      return OutlinedButton.icon(
        onPressed: _ocupado ? null : _alternarAsistencia,
        icon: const Icon(Icons.check),
        label: const Text('Estás dentro · Salirme'),
      );
    }
    if (widget.partido.completo) {
      return const FilledButton(onPressed: null, child: Text('Completo'));
    }
    return FilledButton.icon(
      onPressed: _ocupado ? null : _alternarAsistencia,
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Me sumo'),
    );
  }
}

// Mismo color para la misma persona en el feed y en el chat
Color colorDePersona(String nombre) {
  const paleta = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
  ];
  final suma = nombre.codeUnits.fold<int>(0, (a, b) => a + b);
  return paleta[suma % paleta.length].shade700;
}
