import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/partido.dart';

// Todas las consultas pasan por RLS: cada usuario solo modifica sus
// propios partidos. Los que están publicados en el feed los pueden
// ver todos, por eso el calendario filtra por dueño.
class PartidosService {
  final SupabaseClient _db = Supabase.instance.client;

  static const _conAsistentes = '*, asistentes(user_id, nombre)';

  // Los míos más los de otros a los que me sumé (con el nombre de quien
  // organiza, que sale del anuncio que lo publicó)
  Future<List<Partido>> listar() async {
    final miId = _db.auth.currentUser!.id;
    final (propios, sumados) = await (
      _db.from('partidos').select(_conAsistentes).eq('user_id', miId),
      _db
          .from('asistentes')
          .select('partido:partidos($_conAsistentes, anuncios(autor))')
          .eq('user_id', miId),
    ).wait;
    return [
      ...propios.map(Partido.fromMap),
      for (final fila in sumados)
        if (fila['partido'] != null) Partido.fromMap(fila['partido']),
    ]..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  Future<Partido> crear(Partido partido) async {
    final fila = await _db
        .from('partidos')
        .insert(partido.toMap())
        .select(_conAsistentes)
        .single();
    return Partido.fromMap(fila);
  }

  Future<Partido> editar(Partido partido) async {
    final fila = await _db
        .from('partidos')
        .update(partido.toMap())
        .eq('id', partido.id!)
        .select(_conAsistentes)
        .single();
    return Partido.fromMap(fila);
  }

  Future<void> borrar(int id) async {
    await _db.from('partidos').delete().eq('id', id);
  }

  // Sumarse a un partido de otra persona publicado en el feed.
  // La base de datos rechaza el insert si ya no quedan cupos.
  Future<void> sumarme(int partidoId, String nombre) async {
    await _db.from('asistentes').insert({
      'partido_id': partidoId,
      'nombre': nombre,
    });
  }

  Future<void> salirme(int partidoId) async {
    await _db
        .from('asistentes')
        .delete()
        .eq('partido_id', partidoId)
        .eq('user_id', _db.auth.currentUser!.id);
  }
}
