import '../utils/fechas.dart' as fechas;
import 'partido.dart';

class Anuncio {
  final int? id;
  final String? userId;
  final String autor;
  final String titulo;
  final String descripcion;
  final DateTime? creado;
  final int? partidoId;
  final Partido? partido;
  final int totalComentarios;

  Anuncio({
    this.id,
    this.userId,
    required this.autor,
    required this.titulo,
    required this.descripcion,
    this.creado,
    this.partidoId,
    this.partido,
    this.totalComentarios = 0,
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
      partidoId: map['partido_id'] as int?,
      partido: map['partido'] != null ? Partido.fromMap(map['partido']) : null,
      // PostgREST devuelve el conteo como [{count: n}]
      totalComentarios:
          (map['comentarios'] as List?)?.firstOrNull?['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autor': autor,
      'titulo': titulo,
      'descripcion': descripcion,
      'partido_id': partidoId,
    };
  }

  String get haceCuanto => fechas.haceCuanto(creado);
}
