// Datos del proyecto en Supabase (Project Settings > API).
// Se pueden pasar al correr la app:
//   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
// o reemplazar directamente los valores por defecto de abajo.
// La anon key es pública por diseño; lo que protege los datos son las políticas RLS.
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'TU_SUPABASE_URL',
);

const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'TU_SUPABASE_ANON_KEY',
);
