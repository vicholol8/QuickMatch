class Anuncio {
  final int? id;
  final String? userId;
  final String autor;
  final String titulo;
  final String descripcion;
  final DateTime? creado;

  Anuncio({
    this.id,
    this.userId,
    required this.autor,
    required this.titulo,
    required this.descripcion,
    this.creado,
  });

  factory Anuncio.fromMap(Map<String, dynamic> map) {
    return Anuncio(
      id: map['id'] as int?,
      userId: map['user_id'],
      autor: map['autor'] ?? 'Anónimo',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      creado: map['created_at'] != null
          ? DateTime.parse(map['created_at']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autor': autor,
      'titulo': titulo,
      'descripcion': descripcion,
    };
  }

  String get haceCuanto {
    if (creado == null) return '';
    final diferencia = DateTime.now().difference(creado!);
    if (diferencia.inMinutes < 1) return 'Justo ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) return 'Hace ${diferencia.inHours} h';
    if (diferencia.inDays == 1) return 'Ayer';
    return 'Hace ${diferencia.inDays} días';
  }
}
