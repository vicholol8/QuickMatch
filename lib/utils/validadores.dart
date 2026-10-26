// Validadores que se repiten en varios formularios
final _regexEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validarEmail(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Ingresa tu correo';
  if (!_regexEmail.hasMatch(texto)) return 'El correo no es válido';
  return null;
}

String? validarPassword(String? valor) {
  if (valor == null || valor.isEmpty) return 'Ingresa tu contraseña';
  if (valor.length < 6) return 'Debe tener al menos 6 caracteres';
  return null;
}

String? Function(String?) validarObligatorio(String campo, {int minimo = 1}) {
  return (String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Completa $campo';
    if (texto.length < minimo) {
      return 'Escribe al menos $minimo caracteres';
    }
    return null;
  };
}
