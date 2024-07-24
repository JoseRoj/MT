import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/views/listclubs_view.dart';
import 'package:clubconnect/presentation/views/home_view.dart';
import 'package:clubconnect/presentation/screens/perfil_screen.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({super.key, required this.pageIndex});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    /*  FirebaseApi()
        .initNotification(ref)
        .then((value) => print("Notificaciones inicializadas"));
*/
    super.initState();
    //print(";");
    ref.read(categoriasProvider.notifier).getCategorias();
    ref
        .read(deportesProvider.notifier)
        .getDeportes(); /*.then((value) => ref
        .read(clubesRegisterProvider.notifier)
        .getClubes(
            ref.read(deportesProvider).map((e) => int.parse(e.id)).toList()));*/

    //      final deportes = ref.watch(deportesProvider);

    ref.read(tiposProvider.notifier).getTipos();
    ref.read(authProvider).loadToken();
  }

  final viewRoutes = const <Widget>[
    ListClubView(), // <--- Hom
    HomeView(),
    Perfil(), // <--
    //FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(initialLoadingProvider);
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      print("Entre...");
      final deportes = ref.watch(deportesProvider);

      /*ref
          .read(clubesRegisterProvider.notifier)
          .getClubes(deportes.map((e) => int.parse(e.id)).toList());
*/
      return Scaffold(
        body: IndexedStack(
          index: widget.pageIndex,
          children: viewRoutes,
        ),
        bottomNavigationBar:
            CustomBottomNavigation(currentIndex: widget.pageIndex),
      );
    }
  }
}
