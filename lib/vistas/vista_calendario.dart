import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../modelos/partido.dart';
import '../modelos/reglas_deporte.dart';
import '../providers/partidos_provider.dart';
import '../servicios/auth_service.dart';
import 'formulario_partido.dart';
import 'vista_chat.dart';

class VistaCalendario extends StatefulWidget {
  const VistaCalendario({super.key});

  @override
  State<VistaCalendario> createState() => _VistaCalendarioState();
}

class _VistaCalendarioState extends State<VistaCalendario> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void _abrirFormulario({Partido? partido}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FormularioPartido(partido: partido, diaInicial: _selectedDay),
      ),
    );
  }

  Future<void> _confirmarBorrado(Partido partido) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar partido'),
        content: Text(
          '¿Seguro que quieres borrar ${partido.deporte} en ${partido.lugar}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PartidosProvider>().borrar(partido.id!);
      messenger.showSnackBar(const SnackBar(content: Text('Partido borrado')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
    }
  }

  Future<void> _confirmarSalida(Partido partido) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Salirme del partido'),
        content: Text(
          'Dejarás tu cupo libre en ${partido.deporte} y saldrás del chat del grupo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Salirme'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PartidosProvider>().salirme(partido.id!);
      messenger.showSnackBar(
        const SnackBar(content: Text('Te saliste del partido')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
    }
  }

  void _abrirChat(Partido partido) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VistaConversacion(partido: partido)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartidosProvider>();
    final delDia = provider.delDia(_selectedDay);

    return Scaffold(
      body: Column(
        children: [
          TableCalendar<Partido>(
            locale: 'es_ES',
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mes',
              CalendarFormat.twoWeeks: '2 semanas',
              CalendarFormat.week: 'Semana',
            },
            // Pinta un puntito en los días que tienen partidos
            eventLoader: provider.delDia,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          ),
          const Divider(),
          Expanded(child: _listaDelDia(provider, delDia)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo partido',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _listaDelDia(PartidosProvider provider, List<Partido> delDia) {
    final miId = Supabase.instance.client.auth.currentUser?.id;
    if (provider.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!),
            TextButton(
              onPressed: provider.cargar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (delDia.isEmpty) {
      return const Center(
        child: Text(
          'No tienes partidos este día.\nToca + para armar uno.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.cargar,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: delDia.length,
        itemBuilder: (context, index) {
          final partido = delDia[index];
          final esMio = partido.esDe(miId);
          final estado = partido.completo
              ? '¡Completo!'
              : partido.faltan == 1
              ? 'Falta 1 jugador'
              : 'Faltan ${partido.faltan} jugadores';
          final otros = integrantes(partido, miId);
          final quienes = esMio
              ? (otros.isEmpty ? '' : ' · se sumaron: ${otros.join(', ')}')
              : ' · organiza ${partido.organizador ?? 'otra persona'}';
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Badge(
                isLabelVisible: !esMio,
                label: const Icon(Icons.check, size: 10, color: Colors.white),
                backgroundColor: Colors.blue,
                child: Icon(
                  buscarModalidad(partido.deporte).$1.icono,
                  color: esMio ? Colors.green : Colors.blue,
                ),
              ),
              title: Text('${partido.deporte} · ${partido.lugar}'),
              subtitle: Text(
                '${partido.hora} hrs · $estado$quienes\n'
                        '${esMio ? partido.notas ?? '' : 'Te sumaste · toca para abrir el chat'}'
                    .trim(),
              ),
              isThreeLine: !esMio || partido.notas != null,
              onTap: () => esMio
                  ? _abrirFormulario(partido: partido)
                  : _abrirChat(partido),
              trailing: esMio
                  ? IconButton(
                      tooltip: 'Borrar',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmarBorrado(partido),
                    )
                  : IconButton(
                      tooltip: 'Salirme',
                      icon: const Icon(Icons.logout),
                      onPressed: () => _confirmarSalida(partido),
                    ),
            ),
          );
        },
      ),
    );
  }
}
