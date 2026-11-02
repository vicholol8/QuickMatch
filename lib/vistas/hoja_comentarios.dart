import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/anuncio.dart';
import '../modelos/comentario.dart';
import '../servicios/anuncios_service.dart';
import '../servicios/auth_service.dart';
import '../utils/fechas.dart';
import 'feed_partido.dart';

// Se abre desde una tarjeta del feed para leer y escribir comentarios
class HojaComentarios extends StatefulWidget {
  final Anuncio anuncio;

  const HojaComentarios({super.key, required this.anuncio});

  @override
  State<HojaComentarios> createState() => _HojaComentariosState();
}

class _HojaComentariosState extends State<HojaComentarios> {
  final _service = AnunciosService();
  final _textoController = TextEditingController();
  List<Comentario>? _comentarios;
  String? _error;
  bool _enviando = false;

  String? get _miId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final lista = await _service.listarComentarios(widget.anuncio.id!);
      if (mounted) setState(() => _comentarios = lista);
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(e));
    }
  }

  Future<void> _enviar() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty || _enviando) return;
    if (texto.length > 300) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Máximo 300 caracteres')));
      return;
    }

    setState(() => _enviando = true);
    try {
      final nuevo = await _service.comentar(
        Comentario(
          anuncioId: widget.anuncio.id!,
          autor: nombreDelUsuario(),
          texto: texto,
        ),
      );
      _textoController.clear();
      if (mounted) setState(() => _comentarios = [...?_comentarios, nuevo]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _borrar(Comentario comentario) async {
    try {
      await _service.borrarComentario(comentario.id!);
      if (mounted) {
        setState(() => _comentarios!.removeWhere((c) => c.id == comentario.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.anuncio.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _lista()),
            const Divider(height: 1),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textoController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 300,
                        onSubmitted: (_) => _enviar(),
                        decoration: const InputDecoration(
                          hintText: 'Escribe un comentario',
                          border: OutlineInputBorder(),
                          isDense: true,
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _enviando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      onPressed: _enviando ? null : _enviar,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lista() {
    if (_error != null) return Center(child: Text(_error!));
    final comentarios = _comentarios;
    if (comentarios == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (comentarios.isEmpty) {
      return const Center(
        child: Text(
          'Nadie ha comentado todavía.\n¡Rompe el hielo!',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: comentarios.length,
      itemBuilder: (context, index) {
        final c = comentarios[index];
        final esMio = c.userId == _miId;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorDePersona(c.autor),
            child: Text(
              c.autor.characters.first.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: esMio ? '${c.autor} (tú)' : c.autor,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '  ${haceCuanto(c.creado)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          subtitle: Text(c.texto),
          trailing: esMio
              ? IconButton(
                  tooltip: 'Borrar',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _borrar(c),
                )
              : null,
        );
      },
    );
  }
}
