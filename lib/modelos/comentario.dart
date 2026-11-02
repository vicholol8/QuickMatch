class Comentario {
  final int? id;
  final int anuncioId;
  final String? userId;
  final String autor;
  final String texto;
  final DateTime? creado;

  Comentario({
    this.id,
    required this.anuncioId,
    this.userId,
    required this.autor,
    required this.texto,
    this.creado,
  });

  factory Comentario.fromMap(Map<String, dynamic> map) {
    return Comentario(
      id: map['id'] as int?,
      anuncioId: map['anuncio_id'] as int,
      userId: map['user_id'],
      autor: map['autor'] ?? 'Anónimo',
      texto: map['texto'] ?? '',
      creado: map['created_at'] != null
          ? DateTime.parse(map['created_at']).toLocal()
          : null,
    );
  }

  // user_id no se manda: Supabase lo completa con auth.uid()
  Map<String, dynamic> toMap() {
    return {'anuncio_id': anuncioId, 'autor': autor, 'texto': texto};
  }
}
