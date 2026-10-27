import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../ui/agregar_materia/view_models/agregar_materia_viewmodel.dart';
import '../ui/agregar_materia/widgets/agregar_materia_screen.dart';
import '../ui/bienvenida/view_models/bienvenida_viewmodel.dart';
import '../ui/bienvenida/widgets/bienvenida_screen.dart';
import '../ui/core/ui/barra_navegacion.dart';
import '../ui/descanso/view_models/descanso_viewmodel.dart';
import '../ui/descanso/widgets/descanso_screen.dart';
import '../ui/inicio/view_models/inicio_viewmodel.dart';
import '../ui/inicio/widgets/inicio_screen.dart';
import '../ui/login/view_models/login_viewmodel.dart';
import '../ui/login/widgets/login_screen.dart';
import '../ui/logros/view_models/logros_viewmodel.dart';
import '../ui/logros/widgets/logros_screen.dart';
import '../ui/mascota/view_models/mascota_viewmodel.dart';
import '../ui/mascota/widgets/mascota_screen.dart';
import '../ui/materias/view_models/materias_viewmodel.dart';
import '../ui/materias/widgets/materias_screen.dart';
import '../ui/nueva_sesion/view_models/nueva_sesion_viewmodel.dart';
import '../ui/nueva_sesion/widgets/nueva_sesion_screen.dart';
import '../ui/perfil/view_models/perfil_viewmodel.dart';
import '../ui/perfil/widgets/perfil_screen.dart';
import '../ui/pesca_rapida/view_models/pesca_rapida_viewmodel.dart';
import '../ui/pesca_rapida/widgets/pesca_rapida_screen.dart';
import '../ui/progreso/view_models/progreso_viewmodel.dart';
import '../ui/progreso/widgets/progreso_screen.dart';
import '../ui/racha/view_models/racha_viewmodel.dart';
import '../ui/racha/widgets/racha_screen.dart';
import '../ui/registro/view_models/registro_viewmodel.dart';
import '../ui/registro/widgets/registro_screen.dart';
import '../ui/temporizador/view_models/temporizador_viewmodel.dart';
import '../ui/temporizador/widgets/temporizador_screen.dart';
import 'routes.dart';

/// Crea el router. Cada ruta arma su ViewModel con los repositorios que
/// están en el árbol de `Provider` (ver `config/dependencies.dart`).
GoRouter router(AuthRepository auth) => GoRouter(
  initialLocation: Routes.inicio,
  refreshListenable: auth,
  redirect: (context, state) => _redirect(auth, state),
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) =>
          LoginScreen(viewModel: LoginViewModel(authRepository: context.read())),
    ),
    GoRoute(
      path: Routes.registro,
      builder: (context, state) =>
          RegistroScreen(viewModel: RegistroViewModel(authRepository: context.read())),
    ),
    GoRoute(
      path: Routes.bienvenida,
      builder: (context, state) =>
          BienvenidaScreen(viewModel: BienvenidaViewModel(authRepository: context.read())),
    ),

    // Barra inferior con 5 pestañas; el orden es el de la barra.
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => BarraNavegacion(navigationShell: shell),
      branches: [
        _rama(Routes.mascota, (c) => MascotaScreen(
          viewModel: MascotaViewModel(gamificacionRepository: c.read()),
        )),
        _rama(Routes.materias, (c) => MateriasScreen(
          viewModel: MateriasViewModel(materiaRepository: c.read(), sesionRepository: c.read()),
        )),
        _rama(Routes.inicio, (c) => InicioScreen(
          viewModel: InicioViewModel(
            authRepository: c.read(),
            materiaRepository: c.read(),
            sesionRepository: c.read(),
            gamificacionRepository: c.read(),
            logroRepository: c.read(),
          ),
        )),
        _rama(Routes.progreso, (c) => ProgresoScreen(
          viewModel: ProgresoViewModel(sesionRepository: c.read(), materiaRepository: c.read()),
        )),
        _rama(Routes.logros, (c) => LogrosScreen(
          viewModel: LogrosViewModel(logroRepository: c.read()),
        )),
      ],
    ),

    GoRoute(
      path: Routes.agregarMateria,
      builder: (context, state) => AgregarMateriaScreen(
        viewModel: AgregarMateriaViewModel(materiaRepository: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.nuevaSesion,
      builder: (context, state) => NuevaSesionScreen(
        viewModel: NuevaSesionViewModel(
          materiaRepository: context.read(),
          configuracionRepository: context.read(),
          sesionRepository: context.read(),
          materiaInicial: state.uri.queryParameters['materia'],
        ),
      ),
    ),
    GoRoute(
      path: Routes.temporizador,
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return TemporizadorScreen(
          viewModel: TemporizadorViewModel(
            materiaId: q['materia'] ?? '',
            pomodoro: int.tryParse(q['n'] ?? '') ?? 1,
            completadosAntes: int.tryParse(q['c'] ?? '') ?? 0,
            configuracionRepository: context.read(),
            sesionRepository: context.read(),
            materiaRepository: context.read(),
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.descanso,
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return DescansoScreen(
          viewModel: DescansoViewModel(
            materiaId: q['materia'] ?? '',
            pomodoro: int.tryParse(q['n'] ?? '') ?? 1,
            saltado: q['saltado'] == 'true',
            completados: int.tryParse(q['c'] ?? '') ?? 0,
            configuracionRepository: context.read(),
            materiaRepository: context.read(),
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.racha,
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return RachaScreen(
          viewModel: RachaViewModel(
            materiaId: q['materia'] ?? '',
            pomodoro: int.tryParse(q['n'] ?? '') ?? 1,
            finCiclo: q['fin'] == 'true',
            completados: int.tryParse(q['c'] ?? '') ?? 0,
            gamificacionRepository: context.read(),
            sesionRepository: context.read(),
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.perfil,
      builder: (context, state) => PerfilScreen(
        viewModel: PerfilViewModel(authRepository: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.pescaRapida,
      builder: (context, state) => PescaRapidaScreen(
        viewModel: PescaRapidaViewModel(gamificacionRepository: context.read()),
      ),
    ),
  ],
);

StatefulShellBranch _rama(String path, Widget Function(BuildContext) pantalla) =>
    StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => pantalla(context))],
    );

String? _redirect(AuthRepository auth, GoRouterState state) {
  final ruta = state.matchedLocation;
  final enAcceso = ruta == Routes.login || ruta == Routes.registro;
  if (!auth.isAuthenticated) return enAcceso ? null : Routes.login;
  if (enAcceso) return auth.debeVerTutorial ? Routes.bienvenida : Routes.inicio;
  return null;
}
