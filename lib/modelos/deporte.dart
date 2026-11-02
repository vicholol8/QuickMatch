class Deporte {
  final String id;
  final String nombre;
  final String formato;
  final String imagen;
  final String icono;
  final String descripcion;

  Deporte({
    required this.id,
    required this.nombre,
    required this.formato,
    required this.imagen,
    required this.icono,
    required this.descripcion,
  });

  factory Deporte.fromJson(Map<String, dynamic> json) {
    return Deporte(
      id: json['idSport'] ?? '',
      nombre: traducirDeporte(json['strSport'] ?? 'Sin nombre'),
      formato: json['strFormat'] ?? '',
      imagen: json['strSportThumb'] ?? '',
      icono: json['strSportIconGreen'] ?? '',
      descripcion: json['strSportDescription'] ?? 'Sin descripción',
    );
  }

  Deporte conDescripcion(String nueva) {
    return Deporte(
      id: id,
      nombre: nombre,
      formato: formato,
      imagen: imagen,
      icono: icono,
      descripcion: nueva,
    );
  }

  // TheSportsDB entrega "TeamvsTeam" o "EventSport", lo dejamos legible
  String get formatoLegible {
    switch (formato) {
      case 'TeamvsTeam':
        return 'Equipo contra equipo';
      case 'EventSport':
        return 'Evento / competencia';
      default:
        return formato.isEmpty ? 'Sin formato' : formato;
    }
  }
}

// TheSportsDB entrega los nombres en inglés
const Map<String, String> _nombresEnEspanol = {
  'Soccer': 'Fútbol',
  'Basketball': 'Básquetbol',
  'Tennis': 'Tenis',
  'Volleyball': 'Vóleibol',
  'Handball': 'Handball',
  'Rugby': 'Rugby',
  'Baseball': 'Béisbol',
  'Ice Hockey': 'Hockey sobre hielo',
  'American Football': 'Fútbol americano',
  'Cricket': 'Críquet',
  'Golf': 'Golf',
  'Cycling': 'Ciclismo',
  'Athletics': 'Atletismo',
  'Fighting': 'Deportes de combate',
  'Motorsport': 'Automovilismo',
  'ESports': 'eSports',
};

String traducirDeporte(String nombre) => _nombresEnEspanol[nombre] ?? nombre;
