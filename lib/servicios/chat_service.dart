import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/mensaje.dart';
import 'auth_service.dart';

// RLS deja leer y escribir solo al organizador y a quienes se sumaron
class ChatService {
  final SupabaseClient _db = Supabase.instance.client;

  // Realtime: el stream se actualiza solo cuando alguien escribe
  Stream<List<Mensaje>> escuchar(int partidoId) {
    return _db
        .from('mensajes')
        .stream(primaryKey: ['id'])
        .eq('partido_id', partidoId)
        .order('created_at')
        .map((filas) => filas.map(Mensaje.fromMap).toList());
  }

  Future<void> enviar(int partidoId, String texto) async {
    await _db.from('mensajes').insert({
      'partido_id': partidoId,
      'autor': nombreDelUsuario(),
      'texto': texto,
    });
  }

  // Último mensaje de cada chat, para la vista previa de la lista
  Future<Map<int, Mensaje>> ultimos(List<int> partidoIds) async {
    if (partidoIds.isEmpty) return {};
    final filas = await _db
        .from('mensajes')
        .select()
        .inFilter('partido_id', partidoIds)
        .order('created_at', ascending: false)
        .limit(500);
    final ultimos = <int, Mensaje>{};
    for (final fila in filas) {
      final m = Mensaje.fromMap(fila);
      ultimos.putIfAbsent(m.partidoId, () => m);
    }
    return ultimos;
  }
}
