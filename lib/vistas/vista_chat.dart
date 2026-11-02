import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/mensaje.dart';
import '../modelos/partido.dart';
import '../modelos/reglas_deporte.dart';
import '../providers/partidos_provider.dart';
import '../servicios/auth_service.dart';
import '../servicios/chat_service.dart';
import '../utils/fechas.dart';
import 'feed_partido.dart';

String? get _miId => Supabase.instance.client.auth.currentUser?.id;

// Cada partido con al menos otra persona tiene su chat grupal
bool tieneChat(Partido p, String? miId) =>
    !p.esDe(miId) || p.asistentes.isNotEmpty;

// "Tú: ...", o el primer nombre de quien escribió
String vistaPrevia(Mensaje? m, String? miId) {
  if (m == null) return 'Sin mensajes todavía. ¡Saluda!';
  if (m.userId == miId) return 'Tú: ${m.texto}';
  return '${m.autor.split(' ').first}: ${m.texto}';
}

// Integrantes del chat sin contarme a mí
List<String> integrantes(Partido p, String? miId) => [
  if (!p.esDe(miId)) p.organizador ?? 'Organizador',
  for (final a in p.asistentes)
    if (a.userId != miId) a.nombre,
];

class VistaChat extends StatefulWidget {
  const VistaChat({super.key});

  @override
  State<VistaChat> createState() => _VistaChatState();
}

class _VistaChatState extends State<VistaChat> {
  final _service = ChatService();
  Future<Map<int, Mensaje>>? _futuroUltimos;
  String _idsCargados = '';

  void _cargarUltimos(List<Partido> chats, {bool forzar = false}) {
    final ids = chats.map((p) => p.id!).toList();
    final clave = ids.join(',');
    if (!forzar && clave == _idsCargados) return;
    _idsCargados = clave;
    _futuroUltimos = _service.ultimos(ids);
  }

  Future<void> _recargar() async {
    final provider = context.read<PartidosProvider>();
    await provider.cargar();
    setState(() {
      _cargarUltimos(_chatsDe(provider), forzar: true);
    });
    await _futuroUltimos;
  }

  List<Partido> _chatsDe(PartidosProvider provider) =>
      provider.partidos.where((p) => tieneChat(p, _miId)).toList();

  Future<void> _abrir(Partido partido) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VistaConversacion(partido: partido)),
    );
    // Al volver se actualizan las vistas previas
    if (!mounted) return;
    setState(() {
      _cargarUltimos(_chatsDe(context.read<PartidosProvider>()), forzar: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chats = _chatsDe(context.watch<PartidosProvider>());
    _cargarUltimos(chats);

    if (chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: _recargar,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Icon(Icons.forum_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Aún no tienes chats.\nCuando te sumes a un partido del feed,\n'
              'o alguien se sume al tuyo, aquí aparece su grupo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return FutureBuilder<Map<int, Mensaje>>(
      future: _futuroUltimos,
      builder: (context, snapshot) {
        final ultimos = snapshot.data ?? {};
        // Primero los chats con actividad más reciente
        final ordenados = [...chats]
          ..sort((a, b) {
            final fa = ultimos[a.id]?.creado ?? DateTime(2000);
            final fb = ultimos[b.id]?.creado ?? DateTime(2000);
            return fb.compareTo(fa);
          });

        return RefreshIndicator(
          onRefresh: _recargar,
          child: ListView.separated(
            itemCount: ordenados.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final p = ordenados[index];
              final ultimo = ultimos[p.id];
              final colores = Theme.of(context).colorScheme;
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: colores.primaryContainer,
                  child: Icon(
                    buscarModalidad(p.deporte).$1.icono,
                    color: colores.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  '${p.deporte} · ${fechaCorta(p.fecha)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  snapshot.connectionState == ConnectionState.waiting
                      ? 'Cargando…'
                      : vistaPrevia(ultimo, _miId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ultimo == null
                    ? null
                    : Text(
                        horaMensaje(ultimo.creado),
                        style: const TextStyle(fontSize: 12),
                      ),
                onTap: () => _abrir(p),
              );
            },
          ),
        );
      },
    );
  }
}

class VistaConversacion extends StatefulWidget {
  final Partido partido;

  const VistaConversacion({super.key, required this.partido});

  @override
  State<VistaConversacion> createState() => _VistaConversacionState();
}

class _VistaConversacionState extends State<VistaConversacion> {
  final _service = ChatService();
  final _mensajeController = TextEditingController();
  late final Stream<List<Mensaje>> _mensajes = _service.escuchar(
    widget.partido.id!,
  );
  bool _enviando = false;

  Future<void> _enviar() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty || _enviando) return;
    setState(() => _enviando = true);
    try {
      await _service.enviar(widget.partido.id!, texto);
      _mensajeController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partido = widget.partido;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${partido.deporte} · ${partido.lugar}'),
            Text(
              '${integrantes(partido, _miId).join(', ')} y tú',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Mensaje>>(
              stream: _mensajes,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('No se pudieron cargar los mensajes'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final mensajes = snapshot.data!;
                if (mensajes.isEmpty) {
                  return const Center(
                    child: Text('Escribe el primer mensaje del grupo 👋'),
                  );
                }
                // Lista invertida: lo más nuevo queda abajo sin hacer scroll a mano
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: mensajes.length,
                  itemBuilder: (context, i) {
                    final index = mensajes.length - 1 - i;
                    final m = mensajes[index];
                    final anterior = index > 0 ? mensajes[index - 1] : null;
                    final siguiente = index < mensajes.length - 1
                        ? mensajes[index + 1]
                        : null;
                    return _Burbuja(
                      mensaje: m,
                      esMio: m.userId == _miId,
                      // Varios mensajes seguidos de la misma persona se agrupan:
                      // el nombre va en el primero y el avatar en el último
                      mostrarNombre: anterior?.userId != m.userId,
                      mostrarAvatar: siguiente?.userId != m.userId,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 500,
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje',
                        border: OutlineInputBorder(),
                        isDense: true,
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _enviando ? null : _enviar,
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

class _Burbuja extends StatelessWidget {
  final Mensaje mensaje;
  final bool esMio;
  final bool mostrarNombre;
  final bool mostrarAvatar;

  const _Burbuja({
    required this.mensaje,
    required this.esMio,
    required this.mostrarNombre,
    required this.mostrarAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    final burbuja = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      margin: EdgeInsets.only(top: mostrarNombre ? 8 : 2),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        color: esMio
            ? colores.primaryContainer
            : colores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!esMio && mostrarNombre)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                mensaje.autor,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorDePersona(mensaje.autor),
                ),
              ),
            ),
          Text(mensaje.texto),
          const SizedBox(height: 2),
          Text(
            horaMensaje(mensaje.creado),
            style: TextStyle(fontSize: 10, color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );

    if (esMio) {
      return Align(alignment: Alignment.centerRight, child: burbuja);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Se deja el espacio aunque no haya avatar para que las burbujas se alineen
        SizedBox(
          width: 36,
          child: mostrarAvatar
              ? CircleAvatar(
                  radius: 14,
                  backgroundColor: colorDePersona(mensaje.autor),
                  child: Text(
                    mensaje.autor.characters.first.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                )
              : null,
        ),
        burbuja,
      ],
    );
  }
}
