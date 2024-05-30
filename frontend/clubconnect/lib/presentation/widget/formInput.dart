import 'package:flutter/material.dart';

Widget formInput({
  required String label,
  String? hint,
  int? maxLines,
  required TextEditingController controller,
  required String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
    child: TextFormField(
        maxLines: maxLines ?? 1,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14)), // Bordes del campo de entrada
          //hintText: hint,
          labelStyle:
              const TextStyle(fontSize: 16), // Tamaño del texto de la etiqueta
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 10), // Altura del campo de entrada
        ),
        style: const TextStyle(
            fontSize: 15), // Tamaño del texto dentro del campo de entrada
        validator: validator),
  );
}

Widget FormInputPass(
    {required String label,
    required TextEditingController passwordController,
    required bool obcureText,
    required Function() updateVisibility}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
    child: TextFormField(
      controller: passwordController,
      obscureText: obcureText,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(obcureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => updateVisibility(),
        ),
        labelText: label,
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14)), // Bordes del campo de entrada
        //hintText: hint,
        labelStyle:
            const TextStyle(fontSize: 16), // Tamaño del texto de la etiqueta
        contentPadding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 10), // Altura del campo de entrada
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu password';
        }
        return null;
      },
    ),
  );
}
