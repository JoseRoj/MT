import 'dart:typed_data';

import 'package:flutter/material.dart';

Widget ImageOval(
    String image, Uint8List? logoClub, double? width, double? height) {
  return image == "" || image == null
      ? ClipOval(
          child: Image.asset(
            'assets/nofoto.jpeg',
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
        )
      : ClipOval(
          child: Image.memory(
            logoClub!,
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
        );
}
