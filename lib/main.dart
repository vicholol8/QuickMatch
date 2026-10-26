import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/favoritos_provider.dart';
import 'providers/partidos_provider.dart';
import 'vistas/vista_login.dart';
import 'vistas/vista_registro.dart';
import 'vistas/vista_anuncios.dart';
import 'vistas/vista_chat.dart';
import 'vistas/vista_calendario.dart';
import 'vistas/vista_deportes.dart';
import 'vistas/vista_perfil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nombres de días y meses en español para el calendario
  await initializeDateFormatting('es_ES');
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PartidosProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
      ],
      child: const QuickMatchApp(),
    ),
  );
}

class QuickMatchApp extends StatelessWidget {
  const QuickMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickMatch',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/registro': (context) => const VistaRegistro(),
      },
    );
  }
}

// Decide qué mostrar según haya o no sesión activa en Supabase.
// Así el login, el registro y el cierre de sesión no tienen que
// navegar a mano: basta con que cambie el estado de auth.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        if (session == null) {
          return const VistaLogin();
        }
        return MainNavigator(key: ValueKey(session.user.id));
      },
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
    VistaCalendario(),
    VistaDeportes(),
    VistaAnuncios(),
    VistaChat(),
    VistaPerfil(),
  ];

  @override
  void initState() {
    super.initState();
    // Se cargan apenas entra el usuario, porque el perfil también los usa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartidosProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickMatch'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(index: _currentIndex, children: _vistas),
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
            icon: Icon(Icons.sports_basketball),
            label: 'Deportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
