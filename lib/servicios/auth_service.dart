import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  User? get usuario => _auth.currentUser;

  Future<void> iniciarSesion(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  // Devuelve true si quedó con sesión iniciada. Si el proyecto pide
  // confirmar el correo, la sesión llega recién después de confirmarlo.
  Future<bool> registrar(String nombre, String email, String password) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {'nombre': nombre},
    );
    return res.session != null;
  }

  Future<void> actualizarPerfil(Map<String, dynamic> datos) async {
    await _auth.updateUser(UserAttributes(data: datos));
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}

// Nombre con el que el usuario aparece en el feed, comentarios y partidos
String nombreDelUsuario() {
  final usuario = Supabase.instance.client.auth.currentUser;
  final nombre = usuario?.userMetadata?['nombre'] as String?;
  if (nombre != null && nombre.isNotEmpty) return nombre;
  return usuario?.email ?? 'Anónimo';
}

// Supabase responde en inglés; traducimos los casos más comunes
String mensajeDeError(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login')) return 'Correo o contraseña incorrectos';
    if (msg.contains('already registered')) {
      return 'Ese correo ya tiene una cuenta';
    }
    if (msg.contains('email not confirmed')) {
      return 'Falta confirmar el correo. Revisa tu bandeja de entrada';
    }
    if (msg.contains('password')) {
      return 'La contraseña no cumple los requisitos (mínimo 6 caracteres)';
    }
    return error.message;
  }
  if (error is PostgrestException) {
    return 'No se pudo guardar en la base de datos (${error.message})';
  }
  return 'Algo salió mal. Revisa tu conexión e inténtalo otra vez';
}
