import 'package:flutter/material.dart';

class VistaAnuncios extends StatefulWidget {
  const VistaAnuncios({super.key});

  @override
  State<VistaAnuncios> createState() => _VistaAnunciosState();
}

class _VistaAnunciosState extends State<VistaAnuncios> {
  // Lista local de anuncios de prueba
  final List<Map<String, String>> _anuncios = [
    {
      'titulo': 'Busco datos de canchas',
      'descripcion': 'Sector céntrico, ojala la reserva no sea muy cara.',
      'autor': 'Carlos',
      'fecha': 'Hace 2 horas',
    },
    {
      'titulo': 'Partido de fútbol este viernes',
      'descripcion': 'Nos falta 1 jugador para completar el equipo a las 20:00 hrs.',
      'autor': 'María',
      'fecha': 'Hace 5 horas',
    },
  ];

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  void _publicarAnuncio() {
    if (_tituloController.text.isNotEmpty && _descripcionController.text.isNotEmpty) {
      setState(() {
        _anuncios.insert(0, {
          'titulo': _tituloController.text,
          'descripcion': _descripcionController.text,
          'autor': 'Tú',
          'fecha': 'Justo ahora',
        });
      });

      _tituloController.clear();
      _descripcionController.clear();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Anuncio publicado con éxito!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  void _mostrarFormularioPublicar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Anuncio',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del anuncio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _publicarAnuncio,
                  child: const Text('Publicar Anuncio', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _anuncios.isEmpty
          ? const Center(child: Text('No hay anuncios disponibles.'))
          : ListView.builder(
              itemCount: _anuncios.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final anuncio = _anuncios[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              anuncio['autor']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              anuncio['fecha']!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          anuncio['titulo']!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          anuncio['descripcion']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormularioPublicar,
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
    );
  }
}
