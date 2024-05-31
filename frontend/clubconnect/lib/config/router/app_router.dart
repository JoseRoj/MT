import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/screens/home_screen.dart';
import 'package:clubconnect/presentation/screens/login_screen.dart';
import 'package:clubconnect/presentation/screens/registration_screen.dart';
import 'package:clubconnect/presentation/views/Clubequipos.dart';
import 'package:clubconnect/presentation/views/club.dart';
import 'package:clubconnect/presentation/views/equipo.dart';
import 'package:clubconnect/presentation/views/newClub/newClub.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(initialLocation: '/login', routes: [
  GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = int.parse(state.pathParameters['page'] ?? '0');
        return HomeScreen(pageIndex: pageIndex);
      },
      routes: [
        GoRoute(
          path: 'club/:id', //:id',
          name: ClubView.name,
          builder: (context, state) {
            final clubId = state.pathParameters['id'] ?? 'no-id';
            return ClubView(id: int.parse(clubId));
          },
        ),
        GoRoute(
          path: 'club/:id/equipos', //:id',
          name: Equipos.name,
          builder: (context, state) {
            final clubId = state.pathParameters['id'] ?? 'no-id';
            return Equipos(idclub: int.parse(clubId));
          },
          routes: [
            GoRoute(
              path: ':idequipo', //:id',
              name: Equipo.name,
              builder: (context, state) {
                final clubId = state.pathParameters['id'] ?? 'no-id';
                final equipoId = state.pathParameters['idequipo'] ?? 'no-id';

                return Equipo(
                    idclub: int.parse(clubId), idequipo: int.parse(equipoId));
              },
            ),
          ],
        ),
        GoRoute(
          path: 'newClub', //:id',
          name: CreateClub.name,
          builder: (context, state) {
            //final movieId = state.params['id'] ?? 'no-id';

            return CreateClub();
          },
        ),
      ]),
  GoRoute(
    path: '/login',
    name: LoginScreen.name,
    builder: (context, state) => LoginScreen(),
  ),
  GoRoute(
    path: '/register',
    name: RegistrationScreen.name,
    builder: (context, state) => RegistrationScreen(),
  ),
  GoRoute(
    path: '/',
    redirect: (_, __) => '/login',
  ),
]);
