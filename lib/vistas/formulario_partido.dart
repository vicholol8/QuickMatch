import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/partido.dart';
import '../providers/partidos_provider.dart';
import '../servicios/auth_service.dart';
import '../utils/validadores.dart';

// Sirve para crear un partido nuevo o editar uno existente.
// Si llega [partido], el formulario parte con sus datos.
class FormularioPartido extends StatefulWidget {
  final Partido? partido;
  final String? deporteInicial;
  final DateTime? diaInicial;

  const FormularioPartido({
    super.key,
    this.partido,
    this.deporteInicial,
    this.diaInicial,
  });

  @override
  State<FormularioPartido> createState() => _FormularioPartidoState();
}

class _FormularioPartidoState extends State<FormularioPartido> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _deporteController;
  late final TextEditingController _lugarController;
  late final TextEditingController _cuposController;
  late final TextEditingController _notasController;

  DateTime? _fecha;
  bool _guardando = false;

  bool get _esEdicion => widget.partido != null;

  @override
  void initState() {
    super.initState();
    final p = widget.partido;
    _deporteController =
        TextEditingController(text: p?.deporte ?? widget.deporteInicial ?? '');
    _lugarController = TextEditingController(text: p?.lugar ?? '');
    _cuposController =
        TextEditingController(text: p != null ? '${p.cupos}' : '');
    _notasController = TextEditingController(text: p?.notas ?? '');

    if (p != null) {
      _fecha = p.fecha;
    } else if (widget.diaInicial != null) {
      final d = widget.diaInicial!;
      _fecha = DateTime(d.year, d.month, d.day, 19);
    }
  }

  @override
  void dispose() {
    _deporteController.dispose();
    _lugarController.dispose();
    _cuposController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha(FormFieldState<DateTime> campo) async {
    final ahora = DateTime.now();
    final base = _fecha ?? ahora;

    final dia = await showDatePicker(
      context: context,
      initialDate: base.isBefore(ahora) && !_esEdicion ? ahora : base,
      firstDate: _esEdicion ? DateTime(2024) : DateTime(ahora.year, ahora.month, ahora.day),
      lastDate: DateTime(2030, 12, 31),
    );
    if (dia == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (hora == null) return;

    final elegida =
        DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute);
    setState(() => _fecha = elegida);
    campo.didChange(elegida);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final notas = _notasController.text.trim();
    final partido = Partido(
      id: widget.partido?.id,
      deporte: _deporteController.text.trim(),
      lugar: _lugarController.text.trim(),
      fecha: _fecha!,
      cupos: int.parse(_cuposController.text.trim()),
      notas: notas.isEmpty ? null : notas,
    );

    setState(() => _guardando = true);
    final provider = context.read<PartidosProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_esEdicion) {
        await provider.editar(partido);
      } else {
        await provider.crear(partido);
      }
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_esEdicion ? 'Partido actualizado' : 'Partido creado'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _formatearFecha(DateTime f) {
    final dd = f.day.toString().padLeft(2, '0');
    final mm = f.month.toString().padLeft(2, '0');
    final hh = f.hour.toString().padLeft(2, '0');
    final min = f.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${f.year} a las $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar partido' : 'Nuevo partido'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _deporteController,
              textCapitalization: TextCapitalization.sentences,
              validator: validarObligatorio('el deporte', minimo: 3),
              decoration: const InputDecoration(
                labelText: 'Deporte',
                hintText: 'Fútbol, básquetbol, pádel...',
                prefixIcon: Icon(Icons.sports_soccer),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lugarController,
              textCapitalization: TextCapitalization.sentences,
              validator: validarObligatorio('el lugar', minimo: 3),
              decoration: const InputDecoration(
                labelText: 'Lugar',
                hintText: 'Nombre de la cancha o dirección',
                prefixIcon: Icon(Icons.place_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FormField<DateTime>(
              initialValue: _fecha,
              validator: (valor) {
                if (valor == null) return 'Elige el día y la hora';
                if (!_esEdicion && valor.isBefore(DateTime.now())) {
                  return 'La fecha ya pasó';
                }
                return null;
              },
              builder: (campo) {
                return InkWell(
                  onTap: () => _elegirFecha(campo),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha y hora',
                      prefixIcon: const Icon(Icons.event),
                      border: const OutlineInputBorder(),
                      errorText: campo.errorText,
                    ),
                    child: Text(
                      _fecha == null
                          ? 'Toca para elegir'
                          : _formatearFecha(_fecha!),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cuposController,
              keyboardType: TextInputType.number,
              validator: (valor) {
                final n = int.tryParse(valor?.trim() ?? '');
                if (n == null) return 'Ingresa un número';
                if (n < 1 || n > 50) return 'Debe ser entre 1 y 50';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Jugadores que faltan',
                prefixIcon: Icon(Icons.group_add_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasController,
              maxLines: 3,
              maxLength: 200,
              validator: (valor) {
                if ((valor?.length ?? 0) > 200) return 'Máximo 200 caracteres';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Ej: traer petos, se paga la cancha entre todos',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_esEdicion ? 'Guardar cambios' : 'Crear partido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
