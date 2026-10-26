import 'package:flutter/foundation.dart';
import '../modelos/partido.dart';
import '../servicios/partidos_service.dart';

// Lo usan el calendario, el formulario de partidos y el perfil,
// así cualquier cambio se ve al tiro en las tres pantallas.
class PartidosProvider extends ChangeNotifier {
  final PartidosService _service;

  PartidosProvider({PartidosService? service})
      : _service = service ?? PartidosService();

  List<Partido> _partidos = [];
  bool _cargando = false;
  String? _error;

  List<Partido> get partidos => List.unmodifiable(_partidos);
  bool get cargando => _cargando;
  String? get error => _error;

  int get proximos =>
      _partidos.where((p) => p.fecha.isAfter(DateTime.now())).length;

  List<Partido> delDia(DateTime dia) {
    return _partidos
        .where((p) =>
            p.fecha.year == dia.year &&
            p.fecha.month == dia.month &&
            p.fecha.day == dia.day)
        .toList();
  }

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _partidos = await _service.listar();
    } catch (e) {
      _error = 'No se pudieron cargar tus partidos';
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> crear(Partido partido) async {
    final nuevo = await _service.crear(partido);
    _partidos.add(nuevo);
    _ordenar();
    notifyListeners();
  }

  Future<void> editar(Partido partido) async {
    final actualizado = await _service.editar(partido);
    final i = _partidos.indexWhere((p) => p.id == actualizado.id);
    if (i != -1) _partidos[i] = actualizado;
    _ordenar();
    notifyListeners();
  }

  Future<void> borrar(int id) async {
    await _service.borrar(id);
    _partidos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Al cerrar sesión no deben quedar datos del usuario anterior
  void limpiar() {
    _partidos = [];
    _error = null;
    notifyListeners();
  }

  void _ordenar() => _partidos.sort((a, b) => a.fecha.compareTo(b.fecha));
}
