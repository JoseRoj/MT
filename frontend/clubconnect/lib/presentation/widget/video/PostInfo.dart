import 'package:clubconnect/helpers/datetotext.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:flutter/material.dart';

class PostInfo extends StatelessWidget {
  Post post;
  PostInfo({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.06,
        child: ClipOval(
          child: Image.memory(
            imagenFromBase64(post.club!.logo),
            fit: BoxFit.cover,
            width: 130,
            height: 130,
          ),
        ),
      ),
      SizedBox(width: 15),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width -
                MediaQuery.of(context).size.width * 0.3,
            child: Text(
              post.club?.nombre ?? "",
              style: TextStyle(color: Colors.white, fontSize: 15),
              softWrap: true,
              textAlign: TextAlign.left,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.circle,
                color: post.estado ? Colors.green : Colors.red,
                size: 10,
              ),
              const SizedBox(width: 5),
              Text(post.estado ? "Activo" : "Finalizado",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width -
                MediaQuery.of(context).size.width * 0.3,
            child: Text(
              dateToText("Publicado el", post.fechaPublicacion),
              style: TextStyle(color: Colors.white, fontSize: 13),
              softWrap: true,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    ]);
  }
}
