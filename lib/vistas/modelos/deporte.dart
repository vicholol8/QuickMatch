class Deporte {
  final String id;
  final String nombre;
  final String formato;
  final String imagen;
  final String descripcion;

  Deporte({
    required this.id,
    required this.nombre,
    required this.formato,
    required this.imagen,
    required this.descripcion,
  });

  factory Deporte.fromJson(Map<String, dynamic> json) {
    return Deporte(id: json["idSport"] ?? '', nombre: json['strSport'] ?? 'Sin nombre', formato: json['strFormat'] ?? '', imagen: json['strSportThumb'] ?? '', descripcion: json['strSportDescription'] ?? 'Sin descripción',);
  }
}