bool validarCorreo(String correo) {
  // Expresión regular para validar el formato de correo electrónico
  RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(correo);
}

String? emptyOrNull(String? value, String data) {
  if (value == null || value.isEmpty) {
    return 'Ingresa un $data';
  }
  return null;
}

String? emptyOrNullEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Ingresa un correo';
  }
  if (!validarCorreo(value)) {
    return 'Ingresa un correo válido';
  }
  return null;
}

String? emptyOrNullPhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Ingresa un numero de teléfono';
  }
  RegExp regex = RegExp(r'^[0-9]{9}$');
  if (regex.hasMatch(value) == false) {
    return 'Ingresa un numero de teléfono válido';
  }
  return null;
}
