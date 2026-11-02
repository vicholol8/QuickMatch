import '../modelos/deporte.dart';

// Con la key gratuita, TheSportsDB devuelve solo un par de deportes.
// Esta lista completa el catálogo usando las mismas imágenes de la API.
Deporte _respaldo(
  String clave,
  String nombre,
  String formato,
  String descripcion,
) {
  return Deporte(
    id: 'respaldo-$clave',
    nombre: nombre,
    formato: formato,
    imagen: 'https://www.thesportsdb.com/images/sports/$clave.jpg',
    icono: 'https://www.thesportsdb.com/images/icons/sports/$clave.png',
    descripcion: descripcion,
  );
}

final List<Deporte> deportesRespaldo = [
  _respaldo(
    'soccer',
    'Soccer',
    'TeamvsTeam',
    'Dos equipos de once jugadores intentan meter la pelota en el arco rival usando cualquier parte del cuerpo menos los brazos. Es el deporte más popular del mundo.',
  ),
  _respaldo(
    'basketball',
    'Basketball',
    'TeamvsTeam',
    'Dos equipos de cinco jugadores buscan encestar el balón en el aro rival. Se juega en cancha techada o al aire libre y es ideal para pichangas 3 vs 3.',
  ),
  _respaldo(
    'tennis',
    'Tennis',
    'TeamvsTeam',
    'Se juega en single o dobles con raqueta y pelota sobre una red. Gana quien consigue que el rival no pueda devolver la pelota dentro de la cancha.',
  ),
  _respaldo(
    'volleyball',
    'Volleyball',
    'TeamvsTeam',
    'Dos equipos de seis jugadores se pasan el balón por encima de una red sin dejar que toque el suelo de su lado. También existe la versión de playa en parejas.',
  ),
  _respaldo(
    'handball',
    'Handball',
    'TeamvsTeam',
    'Dos equipos de siete jugadores se pasan el balón con las manos para lanzarlo al arco rival. Es rápido, físico y de muchos goles.',
  ),
  _respaldo(
    'rugby',
    'Rugby',
    'TeamvsTeam',
    'Deporte de contacto en que el balón ovalado se pasa solo hacia atrás. Los puntos se consiguen apoyando el balón en el ingoal o pateándolo entre los palos.',
  ),
  _respaldo(
    'baseball',
    'Baseball',
    'TeamvsTeam',
    'Dos equipos se turnan para batear y defender. Se anotan carreras recorriendo las cuatro bases antes de que la defensa elimine al corredor.',
  ),
  _respaldo(
    'ice_hockey',
    'Ice Hockey',
    'TeamvsTeam',
    'Se juega sobre hielo con patines, palos y un disco. Cada equipo intenta meter el disco en el arco rival.',
  ),
  _respaldo(
    'american_football',
    'American Football',
    'TeamvsTeam',
    'Dos equipos de once avanzan con el balón corriendo o pasándolo para llegar a la zona de anotación rival.',
  ),
  _respaldo(
    'cricket',
    'Cricket',
    'TeamvsTeam',
    'Un equipo batea y el otro lanza y defiende. Se anotan carreras corriendo entre los dos wickets después de golpear la pelota.',
  ),
  _respaldo(
    'golf',
    'Golf',
    'EventSport',
    'Cada jugador intenta meter la pelota en una serie de hoyos usando la menor cantidad de golpes posible.',
  ),
  _respaldo(
    'cycling',
    'Cycling',
    'EventSport',
    'Carreras en bicicleta en ruta, pista o montaña. Se puede practicar en grupo o en competencias por etapas.',
  ),
  _respaldo(
    'athletics',
    'Athletics',
    'EventSport',
    'Reúne carreras, saltos y lanzamientos. Incluye desde los 100 metros planos hasta la maratón.',
  ),
  _respaldo(
    'fighting',
    'Fighting',
    'EventSport',
    'Agrupa deportes de combate como boxeo, artes marciales mixtas y kickboxing, donde dos rivales se enfrentan con reglas y categorías por peso.',
  ),
  _respaldo(
    'motorsport',
    'Motorsport',
    'EventSport',
    'Competencias de autos o motos en circuitos o rallies, donde gana quien completa el recorrido en el menor tiempo.',
  ),
  _respaldo(
    'esports',
    'ESports',
    'EventSport',
    'Competencias de videojuegos entre jugadores o equipos, muchas veces con torneos transmitidos en vivo.',
  ),
];
