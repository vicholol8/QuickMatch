import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/anuncio.dart';
import '../modelos/comentario.dart';

class AnunciosService {
  final SupabaseClient _db = Supabase.instance.client;

  // Cada anuncio trae su partido vinculado (con quienes se sumaron)
  // y la cantidad de comentarios, todo en una sola consulta.
  Future<List<Anuncio>> listar() async {
    final datos = await _db
        .from('anuncios')
        .select(
          '*, partido:partidos(*, asistentes(user_id, nombre)), comentarios(count)',
        )
        .order('created_at', ascending: false);
    return datos.map((fila) => Anuncio.fromMap(fila)).toList();
  }

  Future<void> crear(Anuncio anuncio) async {
    await _db.from('anuncios').insert(anuncio.toMap());
  }

  Future<void> editar(Anuncio anuncio) async {
    await _db.from('anuncios').update(anuncio.toMap()).eq('id', anuncio.id!);
  }

  Future<void> borrar(int id) async {
    await _db.from('anuncios').delete().eq('id', id);
  }

  Future<List<Comentario>> listarComentarios(int anuncioId) async {
    final datos = await _db
        .from('comentarios')
        .select()
        .eq('anuncio_id', anuncioId)
        .order('created_at');
    return datos.map((fila) => Comentario.fromMap(fila)).toList();
  }

  Future<Comentario> comentar(Comentario comentario) async {
    final fila = await _db
        .from('comentarios')
        .insert(comentario.toMap())
        .select()
        .single();
    return Comentario.fromMap(fila);
  }

  Future<void> borrarComentario(int id) async {
    await _db.from('comentarios').delete().eq('id', id);
  }
}
