import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../modelos/anuncio.dart';
import '../providers/partidos_provider.dart';
import '../servicios/anuncios_service.dart';
import '../servicios/auth_service.dart';
import '../utils/fechas.dart';
import '../utils/validadores.dart';
import 'feed_partido.dart';
import 'hoja_comentarios.dart';

class VistaAnuncios extends StatefulWidget {
  const VistaAnuncios({super.key});

  @override
  State<VistaAnuncios> createState() => _VistaAnunciosState();
}

class _VistaAnunciosState extends State<VistaAnuncios> {
  final _service = AnunciosService();
  late Future<List<Anuncio>> _futuroAnuncios;

  String? get _miId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _futuroAnuncios = _service.listar();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroAnuncios = _service.listar();
    });
    await _futuroAnuncios.catchError((_) => <Anuncio>[]);
  }

  // Mismo formulario para publicar y para editar
  void _mostrarFormulario({Anuncio? anuncio}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _FormularioAnuncio(anuncio: anuncio, onGuardado: _recargar),
    );
  }

  Future<void> _abrirComentarios(Anuncio anuncio) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HojaComentarios(anuncio: anuncio),
    );
    // Al cerrar se actualiza el contador de comentarios
    await _recargar();
  }

  Future<void> _borrar(Anuncio anuncio) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar anuncio'),
        content: const Text('Esta acción no se puede deshacer.'),
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
      await _service.borrar(anuncio.id!);
      await _recargar();
      messenger.showSnackBar(const SnackBar(content: Text('Anuncio borrado')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Anuncio>>(
        future: _futuroAnuncios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudieron cargar los anuncios'),
                  TextButton(
                    onPressed: _recargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final anuncios = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _recargar,
            child: anuncios.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'Todavía no hay anuncios.\nSé el primero en publicar.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: anuncios.length,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                    itemBuilder: (context, index) => _tarjeta(anuncios[index]),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
    );
  }

  Widget _tarjeta(Anuncio anuncio) {
    final esMio = anuncio.userId == _miId;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    esMio ? '${anuncio.autor} (tú)' : anuncio.autor,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  anuncio.haceCuanto,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // Solo el autor ve las opciones; igual RLS lo bloquea en la base
                if (esMio)
                  PopupMenuButton<String>(
                    onSelected: (opcion) {
                      if (opcion == 'editar') {
                        _mostrarFormulario(anuncio: anuncio);
                      } else {
                        _borrar(anuncio);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'borrar', child: Text('Borrar')),
                    ],
                  )
                else
                  const SizedBox(width: 12, height: 48),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anuncio.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    anuncio.descripcion,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (anuncio.partido != null)
                    TarjetaPartidoFeed(
                      partido: anuncio.partido!,
                      onCambio: _recargar,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => _abrirComentarios(anuncio),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(switch (anuncio.totalComentarios) {
                0 => 'Comentar',
                1 => '1 comentario',
                final n => '$n comentarios',
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormularioAnuncio extends StatefulWidget {
  final Anuncio? anuncio;
  final Future<void> Function() onGuardado;

  const _FormularioAnuncio({this.anuncio, required this.onGuardado});

  @override
  State<_FormularioAnuncio> createState() => _FormularioAnuncioState();
}

class _FormularioAnuncioState extends State<_FormularioAnuncio> {
  final _formKey = GlobalKey<FormState>();
  final _service = AnunciosService();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late int? _partidoId = widget.anuncio?.partidoId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.anuncio?.titulo);
    _descripcionController = TextEditingController(
      text: widget.anuncio?.descripcion,
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final anuncio = Anuncio(
      id: widget.anuncio?.id,
      autor: widget.anuncio?.autor ?? nombreDelUsuario(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      partidoId: _partidoId,
    );

    setState(() => _guardando = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (widget.anuncio == null) {
        await _service.crear(anuncio);
      } else {
        await _service.editar(anuncio);
      }
      if (!mounted) return;
      Navigator.pop(context);
      await widget.onGuardado();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.anuncio == null
                ? '¡Anuncio publicado!'
                : 'Anuncio actualizado',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.anuncio == null ? 'Crear Anuncio' : 'Editar Anuncio',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tituloController,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              validator: validarObligatorio('el título', minimo: 4),
              decoration: const InputDecoration(
                labelText: 'Título del anuncio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              validator: validarObligatorio('la descripción', minimo: 10),
              decoration: const InputDecoration(
                labelText: 'Descripción detallada',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            _selectorPartido(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(
                  widget.anuncio == null
                      ? 'Publicar Anuncio'
                      : 'Guardar cambios',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Solo se pueden invitar partidos propios que todavía no se juegan
  Widget _selectorPartido() {
    final ahora = DateTime.now();
    final miId = Supabase.instance.client.auth.currentUser?.id;
    final partidos = context
        .watch<PartidosProvider>()
        .partidos
        .where((p) => p.esDe(miId))
        .where((p) => p.fecha.isAfter(ahora) || p.id == _partidoId)
        .toList();

    return DropdownButtonFormField<int?>(
      initialValue: partidos.any((p) => p.id == _partidoId) ? _partidoId : null,
      isExpanded: true,
      onChanged: (id) => setState(() => _partidoId = id),
      decoration: InputDecoration(
        labelText: 'Invitar a un partido (opcional)',
        prefixIcon: const Icon(Icons.event_available),
        border: const OutlineInputBorder(),
        helperText: partidos.isEmpty
            ? 'Crea un partido en el calendario para poder invitar'
            : 'Los demás podrán verlo y sumarse',
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Sin partido')),
        for (final p in partidos)
          DropdownMenuItem(
            value: p.id,
            child: Text(
              '${p.deporte} · ${fechaCorta(p.fecha)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
