import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/partido.dart';

// Todas las consultas pasan por RLS, así que cada usuario
// solo recibe y modifica sus propios partidos.
class PartidosService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Partido>> listar() async {
    final datos = await _db.from('partidos').select().order('fecha');
    return datos.map((fila) => Partido.fromMap(fila)).toList();
  }

  Future<Partido> crear(Partido partido) async {
    final fila =
        await _db.from('partidos').insert(partido.toMap()).select().single();
    return Partido.fromMap(fila);
  }

  Future<Partido> editar(Partido partido) async {
    final fila = await _db
        .from('partidos')
        .update(partido.toMap())
        .eq('id', partido.id!)
        .select()
        .single();
    return Partido.fromMap(fila);
  }

  Future<void> borrar(int id) async {
    await _db.from('partidos').delete().eq('id', id);
  }
}
