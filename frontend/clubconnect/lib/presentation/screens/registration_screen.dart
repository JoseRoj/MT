import 'dart:io';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/deporte_provider.dart';
import 'package:clubconnect/presentation/widget/ImagePicker.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:clubconnect/presentation/widget/modalCarga.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  //* Funciones **/
  void onImageSelected(File? image, String base64) {
    imagen = image; // Guarda la imagen selecciona
    base64Image = base64;
    setState(() {});
  }

  void register() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _reppasswordController.text) {
        customToast("Contraseñas no coinciden", context, "isError");
      } else if (_controller.selectedOptions.isEmpty) {
        customToast("Selecciona un género", context, "isError");
      } else if (_dateController.text.isEmpty) {
        customToast("Selecciona tu fecha de nacimiento", context, "isError");
      } else {
        DateFormat formato = DateFormat('dd/MM/yyyy');
        User user = User(
          nombre: _nameController.text,
          email: _correoController.text,
          telefono: _phoneController.text,
          genero: _controller.selectedOptions[0].value,
          fechaNacimiento: transformarAFecha(_dateController.text),
          contrasena: _passwordController.text,
          apellido1: _apellido1Controller.text,
          apellido2: _apellido2Controller.text,
          imagen: base64Image,
        );
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return modalCarga("Creando cuenta, espera un momento .... ");
          },
        );
        final dio = Dio(BaseOptions(headers: {}));

        try {
          final response = await dio.post(
              '${dotenv.env["API_URL"]}/usuarios/create',
              data: user.toJson());

          if (response.statusCode == 201) {
            final responde = await ref
                .read(authProvider.notifier)
                .saveToken(user.email, user.contrasena!);

            if (responde != null) {
              //* Save user data in the provider
              final id = ref.read(authProvider).id;
              final tokenfb = ref.read(authProvider).tokenDispositivo;

              await ref
                  .read(clubConnectProvider)
                  .updateToken(id!, tokenfb != null ? tokenfb : "tokenfb");
              print("tokenfb: $tokenfb");
              context.go('/home/1');
              //ref.watch(UsuarioProvider(responde.id as int));
              customToast("Registrado con éxito", context, "isSuccess");
            }
          }
        } catch (error) {
          customToast(
              "Ocurrió un error al completar registro", context, "isError");
        } finally {
          Navigator.of(context).pop();
        }

        //FocusScope.of(context).unfocus();
      }
    }
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
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () async {
                  register();
                },
                child: const Text(
                  "Registrarse",
                  style: TextStyle(fontSize: 14),
                ),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ImagePickerWidget(
                  initialImage: imagen,
                  onImageSelected: onImageSelected,
                  imageBase64: base64Image,
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
                              initialDateTime: _dateController.text.isEmpty
                                  ? DateTime(2024)
                                  : DateFormat("dd/MM/yyyy")
                                      .parse(_dateController.text),
                              //                                  initialDateTime: .now(),
                              onDateTimeChanged: (DateTime value) {
                                DateTime fecha =
                                    DateTime.parse(value.toString());
                                String nuevaFecha =
                                    DateFormat('dd/MM/yyyy').format(fecha);

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
                  child: formInputPass(
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
                  child: formInputPass(
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
                /*ElevatedButton(
                 child: Text(
                    "Registrarse",
                    style: AppTheme().getTheme().textTheme.bodyMedium,
                  ),
                )*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
