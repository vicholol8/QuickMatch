import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/anuncio.dart';

class AnunciosService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Anuncio>> listar() async {
    final datos = await _db
        .from('anuncios')
        .select()
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
}
