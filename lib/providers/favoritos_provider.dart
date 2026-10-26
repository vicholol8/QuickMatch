import 'package:flutter/foundation.dart';

// Deportes marcados con corazón. Se comparte entre la lista,
// el detalle y el perfil.
class FavoritosProvider extends ChangeNotifier {
  final Set<String> _favoritos = {};

  Set<String> get favoritos => Set.unmodifiable(_favoritos);
  int get cantidad => _favoritos.length;

  bool esFavorito(String nombre) => _favoritos.contains(nombre);

  void alternar(String nombre) {
    if (!_favoritos.remove(nombre)) {
      _favoritos.add(nombre);
    }
    notifyListeners();
  }

  void limpiar() {
    _favoritos.clear();
    notifyListeners();
  }
}
