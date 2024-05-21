import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

Future<Uint8List> assetToBytes(String path) async {
  final byteData = await rootBundle.load(path);
  final bytes = byteData.buffer.asUint8List();
  final codec = await instantiateImageCodec(bytes, targetWidth: 70);
  final frame = await codec.getNextFrame();
  final newByteData = await frame.image.toByteData(format: ImageByteFormat.png);
  return newByteData!.buffer.asUint8List();
}
