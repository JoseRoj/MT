import 'package:flutter/material.dart';

Widget formInput({
  required String label,
  bool? dark = false,
  String? hint,
  int? maxLines,
  bool readOnly = false,
  TextEditingController? controller,
  required String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
    child: TextFormField(
        keyboardType: TextInputType.text,
        readOnly: readOnly,
        maxLines: maxLines ?? 1,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14)), // Bordes del campo de entrada
          labelStyle:
              const TextStyle(fontSize: 14), // Tamaño del texto de la etiqueta
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 10), // Altura del campo de entrada
        ),
        style: TextStyle(
            fontSize: 14,
            color:
                (dark ?? false) ? Colors.white : Colors.black), // Verifica null
        validator: validator),
  );
}

Widget formInputPass(
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
            const TextStyle(fontSize: 14), // Tamaño del texto de la etiqueta
        contentPadding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 10), // Altura del campo de entrada
      ),
      style: const TextStyle(
          fontSize: 14), // Tamaño del texto dentro del campo de entrada
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu password';
        }
        return null;
      },
    ),
  );
}
