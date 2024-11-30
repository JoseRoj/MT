import 'dart:typed_data';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomCardClub extends StatefulWidget {
  final Club club;
  final List<Deporte> deportes;
  final Function() closeWindow;

  const BottomCardClub({
    Key? key,
    required this.club,
    required this.deportes,
    required this.closeWindow,
  }) : super(key: key);

  @override
  BottomCardClubState createState() => BottomCardClubState();
}

class BottomCardClubState extends State<BottomCardClub> {
  Uint8List? _clubImageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.club.logo != null && widget.club.logo != "") {
      _clubImageBytes = imagenFromBase64(widget.club.logo);
    }
  }

  @override
  void didUpdateWidget(covariant BottomCardClub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id ||
        oldWidget.club.logo != widget.club.logo) {
      setState(() {
        _clubImageBytes = (widget.club.logo != null && widget.club.logo != "")
            ? imagenFromBase64(widget.club.logo)
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deporte = widget.deportes
        .firstWhere((deporte) => deporte.id == widget.club.idDeporte)
        .nombre;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ClipOval(
                      child: _clubImageBytes == null
                          ? Image.asset(
                              'assets/nofoto.jpeg',
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            )
                          : Image.memory(
                              _clubImageBytes!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.club.nombre,
                      style: AppTheme().getTheme().textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    Text(deporte!),
                  ],
                ),
              ),
              Container(
                width: 60,
                padding: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  onPressed: () {
                    context.go('/home/0/club/${widget.club.id}');
                  },
                  child: Text(
                    'Ver',
                    style: AppTheme().getTheme().textTheme.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton.filled(
            constraints: const BoxConstraints.tightFor(
              width: 25,
              height: 25,
            ),
            iconSize: 10,
            onPressed: widget.closeWindow,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
