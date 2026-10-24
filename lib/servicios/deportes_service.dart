import 'package:dio/dio.dart';
import '../modelo/deporte.dart';

class DeportesService {
  final Dio _dio = Dio();

  Future<List<Deporte>> obtenerDeportes() async {
    final response = await _dio.get(
      'https://www.thesportsdb.com/api/v1/json/3/all_sports.php',
    );

    if (response.statusCode == 200) {
      final List sportsJson = response.data['sports'] ?? [];
      return sportsJson.map((s) => Deporte.fromJson(s)).toList();
    } else {
      throw Exception('Error al cargar deportes desde la API');
    }
  }
}