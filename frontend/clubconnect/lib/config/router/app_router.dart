import 'package:clubconnect/insfrastructure/models/equipo.dart';
import 'package:clubconnect/insfrastructure/models/solicitud.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/screens/club_equipos_screen.dart';
import 'package:clubconnect/presentation/screens/equipo_screen.dart';
import 'package:clubconnect/presentation/screens/home_screen.dart';
import 'package:clubconnect/presentation/screens/login_screen.dart';
import 'package:clubconnect/presentation/screens/registration_screen.dart';
import 'package:clubconnect/presentation/views/club.dart';
import 'package:clubconnect/presentation/views/miembros/miembroStadistic_view.dart';
import 'package:clubconnect/presentation/views/newClub/newClub.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final appRouter =
    GoRouter(navigatorKey: navigatorKey, initialLocation: '/login', routes: [
  GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = int.parse(state.pathParameters['page'] ?? '0');
        return HomeScreen(pageIndex: pageIndex);
      },
      routes: [
        GoRoute(
          path: 'club/:id/:pageDrawer', //:id',
          name: ClubEquipos.name,
          builder: (context, state) {
            final clubId = state.pathParameters['id'] ?? 'no-id';
            final pageIndex =
                int.parse(state.pathParameters['pageDrawer'] ?? '0');
            return ClubEquipos(idclub: int.parse(clubId), pageIndex: pageIndex);
          },
          routes: [
            GoRoute(
                path: ':idequipo', //:id',
                name: EquipoSpecific.name,
                builder: (context, state) {
                  final clubId = state.pathParameters['id'] ?? 'no-id';
                  final equipoId = state.pathParameters['idequipo'] ?? 'no-id';
                  final Map<String, dynamic>? extras =
                      state.extra as Map<String, dynamic>?;

                  return EquipoSpecific(
                    idclub: int.parse(clubId),
                    idequipo: int.parse(equipoId),
                    team: extras!['team'] as Equipo,
                    //usuario: usuario
                  );
                },
                routes: [
                  GoRoute(
                    path: ':iduser', //:id',
                    name: UserStadistic.name,
                    builder: (context, state) {
                      final clubId =
                          int.parse(state.pathParameters['id'] ?? '0');
                      final equipoId =
                          int.parse(state.pathParameters['idequipo'] ?? '0');
                      final userId =
                          int.parse(state.pathParameters['iduser'] ?? '33');
                      final Map<String, dynamic>? extras =
                          state.extra as Map<String, dynamic>?;

                      return UserStadistic(
                          idclub: clubId,
                          idequipo: equipoId,
                          iduser: userId,
                          usuario: extras!['usuario']);
                    },
                  ),
                ]),
          ],
        ),
        GoRoute(
          path: 'club/:id', //:id',
          name: ClubView.name,
          builder: (context, state) {
            final clubId = state.pathParameters['id'] ?? 'no-id';
            return ClubView(id: int.parse(clubId));
          },
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
