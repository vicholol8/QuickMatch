// Mensaje del chat grupal de un partido
class Mensaje {
  final int? id;
  final int partidoId;
  final String? userId;
  final String autor;
  final String texto;
  final DateTime creado;

  Mensaje({
    this.id,
    required this.partidoId,
    this.userId,
    required this.autor,
    required this.texto,
    required this.creado,
  });

  factory Mensaje.fromMap(Map<String, dynamic> map) {
    return Mensaje(
      id: map['id'] as int?,
      partidoId: map['partido_id'] as int,
      userId: map['user_id'],
      autor: map['autor'] ?? 'Anónimo',
      texto: map['texto'] ?? '',
      creado: DateTime.parse(map['created_at']).toLocal(),
    );
  }
}
