import 'package:dio/dio.dart';
import '../modelos/deporte.dart';
import 'deportes_respaldo.dart';

class DeportesService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<Deporte>> obtenerDeportes() async {
    final response = await _dio.get(
      'https://www.thesportsdb.com/api/v1/json/123/all_sports.php',
    );

    if (response.statusCode == 200) {
      final List sportsJson = response.data['sports'] ?? [];
      final deportes = sportsJson.map((s) => Deporte.fromJson(s)).toList();
      return completarConRespaldo(deportes);
    } else {
      throw Exception('Error al cargar deportes desde la API');
    }
  }
}

// Lo que trae la API va primero; el respaldo solo agrega los que faltan.
// La API describe en inglés, así que se usa la descripción en español si existe.
List<Deporte> completarConRespaldo(List<Deporte> deApi) {
  final respaldo = {
    for (final d in deportesRespaldo) d.nombre.toLowerCase(): d,
  };
  final nombres = deApi.map((d) => d.nombre.toLowerCase()).toSet();
  return [
    for (final d in deApi)
      respaldo[d.nombre.toLowerCase()] != null
          ? d.conDescripcion(respaldo[d.nombre.toLowerCase()]!.descripcion)
          : d,
    ...deportesRespaldo.where((d) => !nombres.contains(d.nombre.toLowerCase())),
  ];
}
