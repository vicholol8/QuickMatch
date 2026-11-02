import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/partido.dart';

// Todas las consultas pasan por RLS: cada usuario solo modifica sus
// propios partidos. Los que están publicados en el feed los pueden
// ver todos, por eso el calendario filtra por dueño.
class PartidosService {
  final SupabaseClient _db = Supabase.instance.client;

  static const _conAsistentes = '*, asistentes(user_id, nombre)';

  Future<List<Partido>> listar() async {
    final datos = await _db
        .from('partidos')
        .select(_conAsistentes)
        .eq('user_id', _db.auth.currentUser!.id)
        .order('fecha');
    return datos.map((fila) => Partido.fromMap(fila)).toList();
  }

  Future<Partido> crear(Partido partido) async {
    final fila =
        await _db.from('partidos').insert(partido.toMap()).select(_conAsistentes).single();
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
