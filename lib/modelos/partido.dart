// Alguien que se sumó a un partido publicado en el feed
class Asistente {
  final String userId;
  final String nombre;

  Asistente({required this.userId, required this.nombre});

  factory Asistente.fromMap(Map<String, dynamic> map) {
    return Asistente(userId: map['user_id'], nombre: map['nombre'] ?? '');
  }
}

class Partido {
  final int? id;
  final String? userId;
  final String deporte;
  final String lugar;
  final DateTime fecha;
  final int cupos;
  final String? notas;
  final List<Asistente> asistentes;

  Partido({
    this.id,
    this.userId,
    required this.deporte,
    required this.lugar,
    required this.fecha,
    required this.cupos,
    this.notas,
    this.asistentes = const [],
  });

  factory Partido.fromMap(Map<String, dynamic> map) {
    return Partido(
      id: map['id'] as int?,
      userId: map['user_id'],
      deporte: map['deporte'] ?? '',
      lugar: map['lugar'] ?? '',
      fecha: DateTime.parse(map['fecha']).toLocal(),
      cupos: map['cupos'] ?? 1,
      notas: map['notas'],
      asistentes: [
        for (final a in (map['asistentes'] as List? ?? []))
          Asistente.fromMap(a),
      ],
    );
  }

  // user_id no se manda: Supabase lo completa con auth.uid()
  Map<String, dynamic> toMap() {
    return {
      'deporte': deporte,
      'lugar': lugar,
      'fecha': fecha.toUtc().toIso8601String(),
      'cupos': cupos,
      'notas': notas,
    };
  }

  // Los cupos son los que faltaban al crearlo; cada asistente ocupa uno
  int get faltan => (cupos - asistentes.length).clamp(0, cupos);
  bool get completo => faltan == 0;
  bool sumado(String? userId) => asistentes.any((a) => a.userId == userId);

  String get hora =>
      '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
}
