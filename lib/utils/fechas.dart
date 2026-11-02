import 'package:intl/intl.dart';

// "Hace 5 min", "Ayer", etc. para el feed y los comentarios
String haceCuanto(DateTime? fecha) {
  if (fecha == null) return '';
  final diferencia = DateTime.now().difference(fecha);
  if (diferencia.inMinutes < 1) return 'Justo ahora';
  if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
  if (diferencia.inDays < 1) return 'Hace ${diferencia.inHours} h';
  if (diferencia.inDays == 1) return 'Ayer';
  return 'Hace ${diferencia.inDays} días';
}

// "lun 3 nov · 20:00"
String fechaCorta(DateTime fecha) =>
    DateFormat("EEE d MMM '·' HH:mm", 'es_ES').format(fecha);
