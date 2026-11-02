import 'package:flutter/material.dart';

// Una forma de jugar un deporte, con la cantidad de jugadores que necesita.
// [nombre] es lo que se guarda en la columna "deporte" del partido.
class Modalidad {
  final String nombre;
  final String formato;
  final int jugadores;
  final bool esGrupal;

  const Modalidad(
    this.nombre,
    this.formato,
    this.jugadores, {
    this.esGrupal = false,
  });

  // Quien organiza ya cuenta como jugador
  int get maximoFaltantes => jugadores - 1;

  String get resumen => esGrupal
      ? '$formato · hasta $jugadores personas'
      : '$formato · $jugadores jugadores en total';
}

class ReglasDeporte {
  final String nombre;
  final IconData icono;
  final List<Modalidad> modalidades;

  const ReglasDeporte(this.nombre, this.icono, this.modalidades);

  bool get esOtro => modalidades.isEmpty;
}

const List<ReglasDeporte> catalogoDeportes = [
  ReglasDeporte('Fútbol', Icons.sports_soccer, [
    Modalidad('Fútbol 11', '11 vs 11', 22),
    Modalidad('Fútbol 7', '7 vs 7', 14),
    Modalidad('Baby fútbol', '5 vs 5', 10),
  ]),
  ReglasDeporte('Básquetbol', Icons.sports_basketball, [
    Modalidad('Básquetbol 5x5', '5 vs 5', 10),
    Modalidad('Básquetbol 3x3', '3 vs 3', 6),
  ]),
  ReglasDeporte('Vóleibol', Icons.sports_volleyball, [
    Modalidad('Vóleibol', '6 vs 6', 12),
    Modalidad('Vóleibol playa', '2 vs 2', 4),
  ]),
  ReglasDeporte('Tenis', Icons.sports_tennis, [
    Modalidad('Tenis single', '1 vs 1', 2),
    Modalidad('Tenis dobles', '2 vs 2', 4),
  ]),
  ReglasDeporte('Pádel', Icons.sports_tennis, [
    Modalidad('Pádel', '2 vs 2', 4),
  ]),
  ReglasDeporte('Handball', Icons.sports_handball, [
    Modalidad('Handball', '7 vs 7', 14),
  ]),
  ReglasDeporte('Rugby', Icons.sports_rugby, [
    Modalidad('Rugby 15', '15 vs 15', 30),
    Modalidad('Rugby 7', '7 vs 7', 14),
  ]),
  ReglasDeporte('Béisbol', Icons.sports_baseball, [
    Modalidad('Béisbol', '9 vs 9', 18),
  ]),
  ReglasDeporte('Hockey sobre hielo', Icons.sports_hockey, [
    Modalidad('Hockey sobre hielo', '6 vs 6', 12),
  ]),
  ReglasDeporte('Fútbol americano', Icons.sports_football, [
    Modalidad('Fútbol americano', '11 vs 11', 22),
  ]),
  ReglasDeporte('Críquet', Icons.sports_cricket, [
    Modalidad('Críquet', '11 vs 11', 22),
  ]),
  ReglasDeporte('Golf', Icons.sports_golf, [
    Modalidad('Golf', 'Grupo de salida', 4, esGrupal: true),
  ]),
  ReglasDeporte('Ciclismo', Icons.directions_bike, [
    Modalidad('Ciclismo grupal', 'Salida en grupo', 20, esGrupal: true),
  ]),
  ReglasDeporte('Running', Icons.directions_run, [
    Modalidad('Running grupal', 'Salida en grupo', 30, esGrupal: true),
  ]),
  ReglasDeporte('Deportes de combate', Icons.sports_mma, [
    Modalidad('Sparring', '1 vs 1', 2),
  ]),
  ReglasDeporte('eSports', Icons.sports_esports, [
    Modalidad('eSports 5v5', '5 vs 5', 10),
    Modalidad('eSports 1v1', '1 vs 1', 2),
  ]),
  ReglasDeporte('Otro', Icons.sports, []),
];

ReglasDeporte get deporteOtro => catalogoDeportes.last;

// Encuentra el deporte y la modalidad a partir del texto guardado.
// Acepta el nombre de una modalidad ("Fútbol 7") o de un deporte ("Fútbol");
// si no calza con nada, es un deporte escrito a mano ("Otro").
(ReglasDeporte, Modalidad?) buscarModalidad(String? texto) {
  final t = texto?.trim().toLowerCase() ?? '';
  for (final d in catalogoDeportes) {
    for (final m in d.modalidades) {
      if (m.nombre.toLowerCase() == t) return (d, m);
    }
  }
  for (final d in catalogoDeportes) {
    if (!d.esOtro && d.nombre.toLowerCase() == t) {
      return (d, d.modalidades.first);
    }
  }
  return (deporteOtro, null);
}
