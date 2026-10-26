import 'package:flutter/material.dart';

class ResumenChat {
  final String nombre;
  final String ultimoMsj;
  final String hora;

  ResumenChat({
    required this.nombre,
    required this.ultimoMsj,
    required this.hora,
  });
}

class VistaChat extends StatelessWidget {
  const VistaChat({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ResumenChat> listaChats = [
      ResumenChat(nombre: 'Partido jueves 18:00', ultimoMsj: '¿Quién lleva pelota?', hora: '10:30'),
      ResumenChat(nombre: 'Torneo sábado', ultimoMsj: 'Inscripción lista', hora: 'Ayer'),
    ];
    return ListView.builder(
      itemCount: listaChats.length,
      itemBuilder: (context, index) {
        final chat = listaChats[index];

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.group, color: Colors.white),
          ),
          title: Text(chat.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chat.ultimoMsj),
          trailing: Text(chat.hora),
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

// Por ahora los mensajes viven solo en memoria
class VistaConversacion extends StatefulWidget {
  final ResumenChat chat;

  const VistaConversacion({super.key, required this.chat});

  @override
  State<VistaConversacion> createState() => _VistaConversacionState();
}

class _VistaConversacionState extends State<VistaConversacion> {
  final _mensajeController = TextEditingController();
  late final List<(String, bool)> _mensajes = [
    (widget.chat.ultimoMsj, false),
  ];

  void _enviar() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;
    setState(() => _mensajes.add((texto, true)));
    _mensajeController.clear();
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.nombre)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final (texto, esMio) = _mensajes[index];
                return Align(
                  alignment:
                      esMio ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: esMio
                          ? colores.primaryContainer
                          : colores.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(texto),
                  ),
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
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _enviar,
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
