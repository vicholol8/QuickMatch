# QuickMatch

App en Flutter para armar partidos y encontrar jugadores que falten. Cada usuario tiene su cuenta, guarda sus partidos en un calendario, revisa deportes y publica anuncios en un feed compartido.

## Qué incluye

| Requisito | Dónde está |
|---|---|
| Login con Supabase (registro, entrar, salir) | `vistas/vista_login.dart`, `vistas/vista_registro.dart`, `servicios/auth_service.dart`. El `AuthGate` de `main.dart` cambia de pantalla según la sesión. |
| Datos de una API de deportes con `FutureBuilder` | `vistas/vista_deportes.dart` usa [TheSportsDB](https://www.thesportsdb.com/) a través de `servicios/deportes_service.dart`. |
| Navegación al detalle pasando el dato por constructor | Al tocar un deporte se abre `VistaDetalleDeporte(deporte: ...)`. Lo mismo pasa con los chats (`VistaConversacion(chat: ...)`). |
| Animaciones | `Hero` en la imagen del deporte (lista → detalle). Animaciones implícitas: `AnimatedScale` en el corazón de favoritos, `AnimatedOpacity` en el texto del detalle y `AnimatedContainer` en el avatar del perfil. |
| Tabla en Supabase con RLS y CRUD | Tabla `partidos`: cada usuario ve, crea, edita y borra solo los suyos (calendario). También hay una tabla `anuncios`, que todos pueden leer pero que solo su autor puede editar o borrar. |
| Formulario con validación | `vistas/formulario_partido.dart` (crear/editar partido), el formulario de anuncios, login, registro y edición de perfil. Todos usan `Form` + `TextFormField` con `validator`. |
| Estado con Provider | `PartidosProvider` lo comparten el calendario, el formulario y el perfil. `FavoritosProvider` lo comparten la lista de deportes, el detalle y el perfil. |

## Cómo correrla

1. Crea un proyecto en [Supabase](https://supabase.com/).
2. En **SQL Editor**, pega y ejecuta el contenido de `supabase/schema.sql`. Ese script crea las tablas y las políticas RLS.
3. En **Project Settings > API** copia la URL del proyecto y la anon key.
4. Ejecuta la app pasando esos datos:

   ```bash
   flutter pub get
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=tu_anon_key
   ```

   También puedes reemplazar los valores por defecto en `lib/config/supabase_config.dart`.

> Si en Supabase está activada la confirmación de correo (**Authentication > Providers > Email**), después de registrarte tienes que confirmar el correo antes de poder entrar. Para probar más rápido puedes desactivarla.

## Estructura

```
lib/
  config/       datos de conexión a Supabase
  modelos/      Deporte, Partido, Anuncio
  providers/    estado compartido (ChangeNotifier)
  servicios/    llamadas a la API y a Supabase
  utils/        validadores de formularios
  vistas/       pantallas
supabase/
  schema.sql    tablas y políticas RLS
```

## Pruebas

```bash
flutter test
```
