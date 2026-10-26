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
      nombre: json['strSport'] ?? 'Sin nombre',
      formato: json['strFormat'] ?? '',
      imagen: json['strSportThumb'] ?? '',
      icono: json['strSportIconGreen'] ?? '',
      descripcion: json['strSportDescription'] ?? 'Sin descripción',
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
