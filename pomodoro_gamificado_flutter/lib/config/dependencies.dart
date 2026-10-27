import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_local.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/repositories/configuracion/configuracion_repository.dart';
import '../data/repositories/configuracion/configuracion_repository_local.dart';
import '../data/repositories/configuracion/configuracion_repository_remote.dart';
import '../data/repositories/gamificacion/gamificacion_repository.dart';
import '../data/repositories/gamificacion/gamificacion_repository_local.dart';
import '../data/repositories/gamificacion/gamificacion_repository_remote.dart';
import '../data/repositories/logro/logro_repository.dart';
import '../data/repositories/logro/logro_repository_local.dart';
import '../data/repositories/logro/logro_repository_remote.dart';
import '../data/repositories/materia/materia_repository.dart';
import '../data/repositories/materia/materia_repository_local.dart';
import '../data/repositories/materia/materia_repository_remote.dart';
import '../data/repositories/sesion/sesion_repository.dart';
import '../data/repositories/sesion/sesion_repository_local.dart';
import '../data/repositories/sesion/sesion_repository_remote.dart';
import '../data/services/api_client.dart';
import '../data/services/datos_demo.dart';
import '../data/services/local_data_service.dart';

/// Dependencias reales: la app habla con la API de FastAPI (`pomodoro_api`),
/// que guarda todo en Supabase. [apiUrl] es, por ejemplo,
/// `http://127.0.0.1:8000`.
List<SingleChildWidget> providersRemote(String apiUrl) => [
  Provider<ApiClient>(create: (_) => ApiClient(baseUrl: apiUrl)),
  ChangeNotifierProvider<AuthRepository>(
    create: (c) => AuthRepositoryRemote(apiClient: c.read()),
  ),
  Provider<MateriaRepository>(
    create: (c) => MateriaRepositoryRemote(apiClient: c.read()),
  ),
  Provider<GamificacionRepository>(
    create: (c) => GamificacionRepositoryRemote(apiClient: c.read()),
  ),
  Provider<SesionRepository>(
    create: (c) => SesionRepositoryRemote(apiClient: c.read()),
  ),
  Provider<ConfiguracionRepository>(
    create: (c) => ConfiguracionRepositoryRemote(apiClient: c.read()),
  ),
  Provider<LogroRepository>(
    create: (c) => LogroRepositoryRemote(apiClient: c.read()),
  ),
];

/// Dependencias con datos en memoria, para desarrollar sin servidor.
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
  Provider<GamificacionRepository>(
    create: (c) => GamificacionRepositoryLocal(localDataService: c.read()),
  ),
  // Cierra la sesión sumando minutos a la materia y aplicando conchas y racha.
  Provider<SesionRepository>(
    create: (c) => SesionRepositoryLocal(
      localDataService: c.read(),
      materias: c.read<MateriaRepository>() as MateriaRepositoryLocal,
      gamificacion: c.read<GamificacionRepository>() as GamificacionRepositoryLocal,
    ),
  ),
  Provider<ConfiguracionRepository>(
    create: (c) => ConfiguracionRepositoryLocal(localDataService: c.read()),
  ),
  Provider<LogroRepository>(
    create: (c) => LogroRepositoryLocal(localDataService: c.read()),
  ),
];
