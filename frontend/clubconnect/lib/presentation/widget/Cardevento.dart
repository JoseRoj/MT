import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/views/Clubequipos.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardEvento extends StatelessWidget {
  final Evento evento;
  const CardEvento({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    print("cardClub");
    TextTheme StyleText = AppTheme().getTheme().textTheme;
    return GestureDetector(onTap: () {}, child: Container(child: Stack()));
  }
}
