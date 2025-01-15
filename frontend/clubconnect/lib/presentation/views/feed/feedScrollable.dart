import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/datetotext.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:clubconnect/presentation/providers/discover_provider.dart';
import 'package:clubconnect/presentation/widget/video/PostInfo.dart';
import 'package:clubconnect/presentation/widget/video/fullscreen_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScrollable extends ConsumerStatefulWidget {
  final List<Post> posts;
  final int initialIndex;
  final Future<void> Function() loadMore;
  final bool isLoading; // Indica si está cargando más datos
  final bool isFeed;
  const FeedScrollable({
    super.key,
    required this.posts,
    required this.loadMore,
    required this.isFeed,
    this.initialIndex = 0,
    this.isLoading = false,
  });

  @override
  FeedScrollableState createState() => FeedScrollableState();
}

class FeedScrollableState extends ConsumerState<FeedScrollable> {
  late List<dynamic> posts;
  final ScrollController _scrollController = ScrollController();
  late PageController pageController;
  late int initialIndex;
  var cargando = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialIndex);

    // Detectar cuando el PageView se acerca al final y cargar más datos
    /*_scrollController.addListener(() {
      // Verificar si hemos llegado al final del PageView
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !ref.read(discoverProvider.notifier).initialLoading) {
        // Si no se está cargando más datos, cargar más
        if (!ref.read(discoverProvider.notifier).noMore) {
          widget.loadMore;
        }
      }
    });*/
    initialIndex = widget.initialIndex;
    posts = widget.posts;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Simula un tiempo de espera para el efecto
    await widget.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        // Detectar cuando llegamos al final del PageView
        if (scrollNotification is ScrollUpdateNotification &&
            scrollNotification.metrics.pixels ==
                scrollNotification.metrics.maxScrollExtent) {
          if (!widget.isLoading &&
              !ref.watch(discoverProvider.notifier).noMore) {
            setState(() {
              cargando = true;
            });
            widget.loadMore().then(
                  (value) => setState(
                    () {
                      if (!ref.watch(discoverProvider.notifier).noMore)
                        pageController.jumpToPage(initialIndex + 1);
                      cargando = false;
                    },
                  ),
                );
          } else {
            print("joj");
          }
        }
        return false;
      },
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length, // Número de elementos en el PageView
        itemBuilder: (context, index) {
          final Post post = widget.posts[index];
          initialIndex = index;
          return Column(
            children: [
              // Contenido de cada post
              if (widget.isFeed)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: SizedBox(
                      child: PostInfo(
                    post: post,
                  )),
                ),
              // Aquí puede ir el contenido multimedia o cualquier otro widget
              Expanded(
                child: Stack(
                  children: [
                    FullScreenPlayer(
                      caption: post.club?.nombre ?? "",
                      url: post.image,
                    ),
                    if (cargando == true)
                      Positioned(
                        bottom: 5,
                        left: MediaQuery.of(context).size.width / 2 - 20,
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
