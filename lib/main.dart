import 'package:flutter/material.dart';
import 'vistas/vista_anuncios.dart';
import 'vistas/vista_chat.dart';
import 'vistas/vista_calendario.dart';

void main() {
  runApp(const QuickMatchApp());
}

class QuickMatchApp extends StatelessWidget {
  const QuickMatchApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickMatch',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _vistas = const [
    VistaCalendario(),VistaChat(), VistaAnuncios(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickMatch'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _vistas[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
        ],
      ),
    );
  }
}
