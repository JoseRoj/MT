import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/presentation/widget/video/video_background.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String url;
  final String caption;

  const FullScreenPlayer({super.key, required this.url, required this.caption});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  //late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    /*controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..setVolume(0)
      ..setLooping(true)
      ..play();
    ;*/

    /*controller = VideoPlayerController.asset(widget.url)
      ..setVolume(0)
      ..setLooping(true)
      ..play();*/
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Puedes poner alguna lógica aquí si quieres que haga algo al hacer tap
          },
          child: Center(
            child: Image.memory(
              imagenFromBase64(widget.url),
              fit: BoxFit.cover,
            ), /*Image.network(
              // Usamos Image.asset o Image.network dependiendo de la fuente
              widget.url, // Aquí el `url` es la ruta de la imagen
              fit: BoxFit
                  .contain, // Ajusta la imagen para que se vea completamente dentro del contenedor
            ),*/
          ),
        ),
      ],
    );
    /*return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        return Stack(
          // Center para que el video esté en el centro de la pantalla
          children: [
            GestureDetector(
              onTap: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );*/
  }
}

class _VideoCaption extends StatelessWidget {
  final String caption;

  const _VideoCaption({super.key, required this.caption});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return SizedBox(
      width: size.width * 0.6,
      child: Text(caption, maxLines: 2, style: titleStyle),
    );
  }
}
