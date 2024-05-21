import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/providers/usuario_provider.dart';
import 'package:clubconnect/presentation/views/listclubs_view.dart';
import 'package:clubconnect/presentation/views/home_view.dart';
import 'package:clubconnect/presentation/views/perfil.dart';
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
    super.initState();
    //print(";");
    ref.read(clubesRegisterProvider.notifier).getClubes();
    ref.read(categoriasProvider.notifier).getCategorias();
    ref.read(deportesProvider.notifier).getDeportes();
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
