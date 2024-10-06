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
  late Future<void> init;
  @override
  void initState() {
    init = initData();
    super.initState();
    /*  FirebaseApi()
        .initNotification(ref)
        .then((value) => print("Notificaciones inicializadas"));
*/

    //print(";");
  }

  Future<void> initData() async {
    await ref.read(authProvider).loadToken();
    await ref.read(categoriasProvider.notifier).getCategorias();
    await ref
        .read(deportesProvider.notifier)
        .getDeportes(); /*.then((value) => ref
        .read(clubesRegisterProvider.notifier)
        .getClubes(
            ref.read(deportesProvider).map((e) => int.parse(e.id)).toList()));*/

    //      final deportes = ref.watch(deportesProvider);
    await ref.read(tiposProvider.notifier).getTipos();
    setState(() {});
  }

  final viewRoutes = const <Widget>[
    ListClubView(), // <--- Hom
    HomeView(),
    Perfil(), // <--
    //FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );

            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Text('Error');
              } else {
                return Scaffold(
                  body: IndexedStack(
                    index: widget.pageIndex,
                    children: viewRoutes,
                  ),
                  bottomNavigationBar:
                      CustomBottomNavigation(currentIndex: widget.pageIndex),
                );
              }
            case ConnectionState.none:
              return const Text('none');
            case ConnectionState.active:
              return const Text('active');
          }
        });
  }
}
