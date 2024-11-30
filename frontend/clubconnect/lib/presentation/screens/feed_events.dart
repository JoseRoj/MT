import 'package:clubconnect/helpers/loadEventPublic.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/discover_provider.dart';
import 'package:clubconnect/presentation/views/feed/feedScrollable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accede al valor de discoverProvider
    final disco = ref.watch(discoverProvider);
    final discoverNotifier = ref.read(discoverProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: disco.initialLoading
          ? Center(
              child: SizedBox(
                width: 50, // Tamaño deseado del indicador de progreso
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Colors.blue,
                ),
              ),
            )
          : SafeArea(
              child: FeedScrollable(
                posts: disco.videos,
                loadMore: () async {
                  await discoverNotifier.loadNextPage(
                      getIdClubes(ref.watch(clubesRegisterProvider)));
                },
                isLoading: disco.initialLoading,
              ),
            ),
    );
  }
}
