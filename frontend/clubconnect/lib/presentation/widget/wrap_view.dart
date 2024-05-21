import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WrapView extends StatelessWidget {
  final List<dynamic> options;
  const WrapView({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.0, // Espacio horizontal entre los elementos
      runSpacing: 8.0, // Espacio vertical entre las filas
      children: options.map((option) {
        return Chip(
          label:
              Text(option, style: AppTheme().getTheme().textTheme.labelSmall),
        );
      }).toList(),
    );
  }
}
