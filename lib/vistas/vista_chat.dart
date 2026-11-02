import 'package:flutter/material.dart';
import 'feed_partido.dart';

// autor == null significa que el mensaje es mío
class Mensaje {
  final String? autor;
  final String texto;
  final String hora;

  const Mensaje(this.autor, this.texto, this.hora);

  bool get esMio => autor == null;
}

class ResumenChat {
  final String nombre;
  final bool esGrupo;
  final List<String> participantes;
  final List<Mensaje> mensajes;

  ResumenChat({
    required this.nombre,
    required this.esGrupo,
    required this.participantes,
    required this.mensajes,
  });

  Mensaje get ultimo => mensajes.last;

  // En los grupos se antepone quién escribió el último mensaje
  String get vistaPrevia {
    final m = ultimo;
    if (m.esMio) return 'Tú: ${m.texto}';
    if (esGrupo) return '${m.autor!.split(' ').first}: ${m.texto}';
    return m.texto;
  }
}

// Por ahora los chats son de ejemplo y viven solo en memoria
final List<ResumenChat> _chats = [
  ResumenChat(
    nombre: 'Baby fútbol martes',
    esGrupo: true,
    participantes: ['Diego Muñoz', 'Tomás Lagos', 'Camila Rojas'],
    mensajes: [
      Mensaje(
        'Diego Muñoz',
        'Cabros, reservé la cancha 2 para el martes',
        '09:12',
      ),
      Mensaje('Diego Muñoz', 'Somos 7, faltan 3', '09:12'),
      Mensaje('Tomás Lagos', 'Voy fijo 🙌', '09:20'),
      Mensaje('Camila Rojas', 'Yo también, llevo a una amiga', '09:41'),
      Mensaje(null, 'Cuenten conmigo', '10:02'),
      Mensaje('Diego Muñoz', '¿Quién lleva pelota?', '10:30'),
    ],
  ),
  ResumenChat(
    nombre: 'Vóley Ñuñoa',
    esGrupo: true,
    participantes: ['Camila Rojas', 'Valentina Soto'],
    mensajes: [
      Mensaje('Camila Rojas', 'Mañana a las 19:00 en el polideportivo', 'Ayer'),
      Mensaje('Valentina Soto', '¿Hay que llevar rodilleras?', 'Ayer'),
      Mensaje('Camila Rojas', 'Sí, el piso es duro', 'Ayer'),
      Mensaje(null, 'Perfecto, nos vemos allá', 'Ayer'),
    ],
  ),
  ResumenChat(
    nombre: 'Valentina Soto',
    esGrupo: false,
    participantes: ['Valentina Soto'],
    mensajes: [
      Mensaje('Valentina Soto', '¡Hola! Vi que juegas tenis', 'Lun'),
      Mensaje(null, 'Sí, nivel intermedio', 'Lun'),
      Mensaje('Valentina Soto', '¿Te tinca un dobles el miércoles?', 'Lun'),
    ],
  ),
];

class VistaChat extends StatelessWidget {
  const VistaChat({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];

        return ListTile(
          leading: _AvatarChat(chat: chat),
          title: Text(
            chat.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            chat.vistaPrevia,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(chat.ultimo.hora),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VistaConversacion(chat: chat)),
            );
          },
        );
      },
    );
  }
}

class _AvatarChat extends StatelessWidget {
  final ResumenChat chat;

  const _AvatarChat({required this.chat});

  @override
  Widget build(BuildContext context) {
    if (chat.esGrupo) {
      return const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.group, color: Colors.white),
      );
    }
    return _Inicial(nombre: chat.nombre);
  }
}

class _Inicial extends StatelessWidget {
  final String nombre;
  final double radio;

  const _Inicial({required this.nombre, this.radio = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radio,
      backgroundColor: colorDePersona(nombre),
      child: Text(
        nombre.characters.first.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: radio * 0.8),
      ),
    );
  }
}

class VistaConversacion extends StatefulWidget {
  final ResumenChat chat;

  const VistaConversacion({super.key, required this.chat});

  @override
  State<VistaConversacion> createState() => _VistaConversacionState();
}

class _VistaConversacionState extends State<VistaConversacion> {
  final _mensajeController = TextEditingController();
  final _scrollController = ScrollController();

  List<Mensaje> get _mensajes => widget.chat.mensajes;

  void _enviar() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;
    final ahora = TimeOfDay.now();
    final hora =
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
    setState(() => _mensajes.add(Mensaje(null, texto, hora)));
    _mensajeController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chat.nombre),
            if (chat.esGrupo)
              Text(
                '${chat.participantes.join(', ')} y tú',
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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final m = _mensajes[index];
                final anterior = index > 0 ? _mensajes[index - 1] : null;
                final siguiente = index < _mensajes.length - 1
                    ? _mensajes[index + 1]
                    : null;
                return _Burbuja(
                  mensaje: m,
                  enGrupo: chat.esGrupo,
                  // Varios mensajes seguidos de la misma persona se agrupan:
                  // el nombre va en el primero y el avatar en el último
                  mostrarNombre: anterior?.autor != m.autor,
                  mostrarAvatar: siguiente?.autor != m.autor,
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
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _enviar),
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
  final bool enGrupo;
  final bool mostrarNombre;
  final bool mostrarAvatar;

  const _Burbuja({
    required this.mensaje,
    required this.enGrupo,
    required this.mostrarNombre,
    required this.mostrarAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esMio = mensaje.esMio;
    final conAutor = enGrupo && !esMio;

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
          if (conAutor && mostrarNombre)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                mensaje.autor!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorDePersona(mensaje.autor!),
                ),
              ),
            ),
          Text(mensaje.texto),
          const SizedBox(height: 2),
          Text(
            mensaje.hora,
            style: TextStyle(fontSize: 10, color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );

    if (!conAutor) {
      return Align(
        alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
        child: burbuja,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Se deja el espacio aunque no haya avatar para que las burbujas se alineen
        SizedBox(
          width: 36,
          child: mostrarAvatar
              ? _Inicial(nombre: mensaje.autor!, radio: 14)
              : null,
        ),
        burbuja,
      ],
    );
  }
}
