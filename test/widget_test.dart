import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quickmatch/modelos/deporte.dart';
import 'package:quickmatch/modelos/partido.dart';
import 'package:quickmatch/modelos/reglas_deporte.dart';
import 'package:quickmatch/providers/favoritos_provider.dart';
import 'package:quickmatch/servicios/deportes_respaldo.dart';
import 'package:quickmatch/servicios/deportes_service.dart';
import 'package:quickmatch/utils/validadores.dart';

void main() {
  group('Validadores', () {
    test('email', () {
      expect(validarEmail(''), isNotNull);
      expect(validarEmail('hola'), isNotNull);
      expect(validarEmail('jugador@udd.cl'), isNull);
    });

    test('contraseña', () {
      expect(validarPassword(''), isNotNull);
      expect(validarPassword('123'), isNotNull);
      expect(validarPassword('123456'), isNull);
    });

    test('campo obligatorio con mínimo', () {
      final validar = validarObligatorio('el lugar', minimo: 3);
      expect(validar('  '), isNotNull);
      expect(validar('ab'), isNotNull);
      expect(validar('Cancha 1'), isNull);
    });
  });

  test('Partido ida y vuelta desde Supabase', () {
    final original = Partido(
      deporte: 'Fútbol',
      lugar: 'Cancha Central',
      fecha: DateTime(2026, 11, 3, 19, 30),
      cupos: 2,
    );
    final mapa = original.toMap()..['id'] = 7;
    final leido = Partido.fromMap(mapa);

    expect(leido.id, 7);
    expect(leido.deporte, 'Fútbol');
    expect(leido.fecha, original.fecha);
    expect(leido.hora, '19:30');
  });

  test('Deporte desde la API', () {
    final d = Deporte.fromJson({
      'idSport': '102',
      'strSport': 'Soccer',
      'strFormat': 'TeamvsTeam',
    });
    expect(d.nombre, 'Fútbol');
    expect(d.formatoLegible, 'Equipo contra equipo');
    expect(d.imagen, '');
  });

  test('El respaldo completa los deportes sin repetir los de la API', () {
    final deApi = [
      Deporte.fromJson({'idSport': '102', 'strSport': 'Soccer'}),
    ];
    final todos = completarConRespaldo(deApi);
    expect(todos.first.id, '102');
    expect(todos.where((d) => d.nombre == 'Fútbol').length, 1);
    expect(todos.first.descripcion, startsWith('Dos equipos'));
    expect(todos.length, deportesRespaldo.length);
  });

  group('Reglas por deporte', () {
    test('cada modalidad descuenta al organizador', () {
      final (_, f7) = buscarModalidad('Fútbol 7');
      expect(f7!.maximoFaltantes, 13);
      final (_, single) = buscarModalidad('Tenis single');
      expect(single!.maximoFaltantes, 1);
    });

    test('un deporte sin modalidad toma la primera', () {
      final (deporte, modalidad) = buscarModalidad('básquetbol');
      expect(deporte.nombre, 'Básquetbol');
      expect(modalidad!.nombre, 'Básquetbol 5x5');
    });

    test('lo que no está en el catálogo queda como Otro', () {
      final (deporte, modalidad) = buscarModalidad('Ultimate');
      expect(deporte.esOtro, isTrue);
      expect(modalidad, isNull);
    });

    test('ninguna modalidad supera el tope de la base de datos', () {
      for (final d in catalogoDeportes) {
        for (final m in d.modalidades) {
          expect(m.maximoFaltantes, inInclusiveRange(1, 50), reason: m.nombre);
        }
      }
    });
  });

  test('FavoritosProvider avisa a quien escucha', () {
    final favoritos = FavoritosProvider();
    var avisos = 0;
    favoritos.addListener(() => avisos++);

    favoritos.alternar('Soccer');
    expect(favoritos.esFavorito('Soccer'), isTrue);

    favoritos.alternar('Soccer');
    expect(favoritos.esFavorito('Soccer'), isFalse);
    expect(avisos, 2);
  });

  testWidgets('El formulario de registro valida antes de enviar', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFormField(validator: validarEmail),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Ingresa tu correo'), findsOneWidget);
  });
}
