class Partido {
  final int? id;
  final String deporte;
  final String lugar;
  final DateTime fecha;
  final int cupos;
  final String? notas;

  Partido({
    this.id,
    required this.deporte,
    required this.lugar,
    required this.fecha,
    required this.cupos,
    this.notas,
  });

  factory Partido.fromMap(Map<String, dynamic> map) {
    return Partido(
      id: map['id'] as int?,
      deporte: map['deporte'] ?? '',
      lugar: map['lugar'] ?? '',
      fecha: DateTime.parse(map['fecha']).toLocal(),
      cupos: map['cupos'] ?? 1,
      notas: map['notas'],
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

  String get hora =>
      '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
}
