import 'dart:io';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../insfrastructure/models.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  static const name = "registration-screen";
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  File? imagen;
  String base64Image = '';
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apellido1Controller = TextEditingController();
  final _apellido2Controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _correoController = TextEditingController();
  final _dateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reppasswordController = TextEditingController();
  final MultiSelectController _controller = MultiSelectController();
  List<String> generos = [
    "Masculino",
    "Femenino",
    "Otro",
  ];

  Future _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagen = File(pickedFile.path);
      });
      base64Image = await toBase64C(pickedFile.path);
    }
    print(base64Image);
    Navigator.of(context).pop();
  }

  Future _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imagen = File(pickedFile.path);
      });
    }
    Navigator.of(context).pop();
  }

  bool obcureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
//         ,
          },
        ),
        title: const Text("Crear Cuenta"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Selecciona una imagen'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Galería'),
                                onTap: () async {
                                  await _pickImageFromGallery();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera),
                                title: const Text('Cámara'),
                                onTap: () async {
                                  await _pickImageFromCamera();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: ClipOval(
                    child: InkWell(
                      child: imagen == null
                          ? ClipOval(
                              child: Container(
                                color: Colors.black54,
                                width: 130,
                                height: 130,
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ClipOval(
                              child: Image.file(
                                imagen!,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: formInput(
                    label: "Nombre",
                    controller: _nameController,
                    validator: (value) => emptyOrNull(value, "nombre"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: formInput(
                        label: "Apellido Paterno",
                        controller: _apellido1Controller,
                        validator: (value) => emptyOrNull(value, "nombre"),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: formInput(
                        label: "Apellido Materno",
                        controller: _apellido2Controller,
                        validator: (value) => emptyOrNull(value, "nombre"),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MultiSelectDropDown(
                    hint: "Selecciona tu género",
                    inputDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    //showClearIcon: true,

                    controller: _controller,
                    onOptionSelected: (options) {
                      //debugPrint(options.toString());
                    },
                    options: generos
                        .map((String item) => ValueItem(
                              label: item,
                              value: item,
                            ))
                        .toList(),
                    /* disabledOptions: const [
                      ValueItem(label: 'Option 1', value: '1')
                    ],*/
                    selectionType: SelectionType.single,
                    chipConfig: const ChipConfig(wrapType: WrapType.scroll),
                    dropdownHeight: 150,
                    optionTextStyle: const TextStyle(fontSize: 16),
                    selectedOptionIcon: const Icon(Icons.check_circle),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: formInput(
                    label: "Correo",
                    controller: _correoController,
                    validator: (value) => emptyOrNullEmail(value),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      style: TextStyle(fontSize: 15), //
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.calendar_today),

                        labelText: "Fecha de Nacimiento",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                14)), // Bordes del campo de entrada
                        //hintText: hint,
                        labelStyle: TextStyle(
                            fontSize: 16), // Tamaño del texto de la etiqueta
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        // Altura del campo de entrada
                      ),
                      onTap: () => {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            height: 200,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              backgroundColor: Colors.white,

                              maximumDate: DateTime.now(),
                              initialDateTime: DateTime(2003, 3, 10),
                              //                                  initialDateTime: .now(),
                              onDateTimeChanged: (DateTime value) {
                                DateTime fecha =
                                    DateTime.parse(value.toString());
                                String nuevaFecha =
                                    DateFormat('MM/dd/yyyy').format(fecha);

                                _dateController.text = nuevaFecha;
                              },
                            ),
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: formInput(
                    label: "Teléfono",
                    controller: _phoneController,
                    validator: (value) => emptyOrNullPhone(value),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: FormInputPass(
                    label: "Contraseña",
                    passwordController: _reppasswordController,
                    obcureText: obcureText,
                    updateVisibility: () {
                      setState(() {
                        obcureText = !obcureText;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: FormInputPass(
                    label: "Repetir Contraseña",
                    passwordController: _passwordController,
                    obcureText: obcureText,
                    updateVisibility: () {
                      setState(() {
                        obcureText = !obcureText;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate()) {
                      if (_passwordController.text !=
                          _reppasswordController.text) {
                        customToast(
                            "Contraseñas no coinciden", context, "isError");
                      } else if (_controller.selectedOptions.isEmpty) {
                        customToast("Selecciona un género", context, "isError");
                      } else if (_dateController.text.isEmpty) {
                        customToast("Selecciona tu fecha de nacimiento",
                            context, "isError");
                      } else {
                        DateFormat formato = DateFormat('dd/MM/yyyy');
                        User user = User(
                          nombre: _nameController.text,
                          email: _correoController.text,
                          telefono: _phoneController.text,
                          genero: _controller.selectedOptions[0].value,
                          fechaNacimiento:
                              transformarAFecha(_dateController.text),
                          contrasena: _passwordController.text,
                          apellido1: _apellido1Controller.text,
                          apellido2: _apellido2Controller.text,
                          imagen: base64Image,
                        );
                        await ref.read(clubConnectProvider).createUser(user);
                        customToast(
                            "Registrado con éxito", context, "isSuccess");
                      }
                    }
                  },
                  child: Text(
                    "Registrarse",
                    style: AppTheme().getTheme().textTheme.bodyMedium,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
