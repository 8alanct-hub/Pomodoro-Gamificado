import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_local.dart';
import '../data/repositories/configuracion/configuracion_repository.dart';
import '../data/repositories/configuracion/configuracion_repository_local.dart';
import '../data/repositories/gamificacion/gamificacion_repository.dart';
import '../data/repositories/gamificacion/gamificacion_repository_local.dart';
import '../data/repositories/logro/logro_repository.dart';
import '../data/repositories/logro/logro_repository_local.dart';
import '../data/repositories/materia/materia_repository.dart';
import '../data/repositories/materia/materia_repository_local.dart';
import '../data/repositories/sesion/sesion_repository.dart';
import '../data/repositories/sesion/sesion_repository_local.dart';
import '../data/services/datos_demo.dart';
import '../data/services/local_data_service.dart';

/// Dependencias con datos en memoria, para desarrollar sin Supabase.
///
/// Cuando exista la versión remota, se crea `providersRemote` con las
/// implementaciones `...RepositoryRemote` y `main.dart` la usa.
List<SingleChildWidget> get providersLocal => _providers(LocalDataService.new);

/// Igual que [providersLocal], pero con la cuenta de prueba y sus datos
/// (ver `data/services/datos_demo.dart`).
List<SingleChildWidget> get providersDemo => _providers(DatosDemo.crear);

List<SingleChildWidget> _providers(LocalDataService Function() crearDatos) => [
  Provider<LocalDataService>(create: (_) => crearDatos()),
  ChangeNotifierProvider<AuthRepository>(
    create: (c) => AuthRepositoryLocal(localDataService: c.read()),
  ),
  Provider<MateriaRepository>(
    create: (c) => MateriaRepositoryLocal(localDataService: c.read()),
  ),
  Provider<SesionRepository>(
    create: (c) => SesionRepositoryLocal(localDataService: c.read()),
  ),
  Provider<ConfiguracionRepository>(
    create: (c) => ConfiguracionRepositoryLocal(localDataService: c.read()),
  ),
  Provider<GamificacionRepository>(
    create: (c) => GamificacionRepositoryLocal(localDataService: c.read()),
  ),
  Provider<LogroRepository>(
    create: (c) => LogroRepositoryLocal(localDataService: c.read()),
  ),
];
