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
      ResumenChat(nombre: 'Partido jueves 18:00', ultimoMsj: 'Quien lleva pelota?', hora: '10:30',),
      ResumenChat(nombre: 'Torneo Sabado', ultimoMsj: 'Inscripcion lista', hora: 'Ayer'),
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
            print('Abriendo el chat de: ${chat.nombre}');
          },
        );
      },
    );
  }
}