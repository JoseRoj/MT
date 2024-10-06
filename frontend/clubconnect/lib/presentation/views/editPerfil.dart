import 'dart:io';
import 'dart:typed_data';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/usuario_provider.dart';
import 'package:clubconnect/presentation/widget/ImagePicker.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:clubconnect/presentation/widget/modalCarga.dart';
import 'package:clubconnect/presentation/widget/wrap_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class InformacionUser extends ConsumerStatefulWidget {
  const InformacionUser({super.key});

  @override
  InformacionUserState createState() => InformacionUserState();
}

class InformacionUserState extends ConsumerState<InformacionUser> {
  File? imagen;
  bool readOnly = true;
  String base64Image = '';
  Uint8List? imageMemory;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apellido1Controller = TextEditingController();
  final _apellido2Controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _correoController = TextEditingController();
  final _dateController = TextEditingController();
  final MultiSelectController _controller = MultiSelectController();
  final _generoController = TextEditingController();
  @override
  void initState() {
    super.initState();
    var user = ref.read(usuarioProvider);
    _nameController.text = user.nombre;
    _apellido1Controller.text = user.apellido1;
    _apellido2Controller.text = user.apellido2;
    _phoneController.text = user.telefono;
    _correoController.text = user.email;
    _dateController.text = DateToString(user.fechaNacimiento);
    _generoController.text = user.genero;
    base64Image = user.imagen;
    imageMemory = imagenFromBase64(user.imagen);
  }

  //*  --------------    Funciones ------------------ **/
  void onImageSelected(File? image, String base64) {
    imagen = image; // Guarda la imagen selecciona
    if (base64 != "") {
      imageMemory = imagenFromBase64(base64);
      base64Image = base64;
    } else {
      imageMemory = null;
      base64Image = base64;
    }
    setState(() {});
  }

  void update() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (_controller.selectedOptions.isEmpty) {
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
            apellido1: _apellido1Controller.text,
            apellido2: _apellido2Controller.text,
            imagen: base64Image,
            id: ref.watch(usuarioProvider).id);
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return modalCarga("Actualizando .. ");
          },
        );
        final response =
            await ref.watch(usuarioProvider.notifier).updateUsuario(user);
        if (response.statusCode == 400) {
          customToast(response.data["message"], context, "isError");
        } else {
          customToast("Actualizado con éxito", context, "isSuccess");
          Navigator.of(context).pop();
        }
      }
      Navigator.of(context).pop();
      //FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (!readOnly) {
                update();
              }
              if (readOnly) {
                setState(() {
                  readOnly = !readOnly;
                });
              }
            },
            child: Text(
              readOnly ? "Editar" : "Guardar",
              style: const TextStyle(fontSize: 14),
            ),
          )
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
                  memoryImage: imageMemory,
                  readOnly: readOnly,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: formInput(
                      label: "Nombre",
                      controller: _nameController,
                      validator: (value) => emptyOrNull(value, "nombre"),
                      readOnly: readOnly),
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
                          readOnly: readOnly),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: formInput(
                          label: "Apellido Materno",
                          controller: _apellido2Controller,
                          validator: (value) => emptyOrNull(value, "nombre"),
                          readOnly: readOnly),
                    ),
                  ],
                ),
                readOnly
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: formInput(
                            label: "Género",
                            controller: _generoController,
                            validator: (value) => emptyOrNull(value, "Genero"),
                            readOnly: true),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
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
                          selectedOptions: generos
                              .where((element) =>
                                  element == _generoController.text)
                              .map((element) => ValueItem(
                                    label: _generoController
                                        .text, // Usamos el valor de _generoController
                                    value: element, // Elemento actual filtrado
                                  ))
                              .toList(),
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
                          chipConfig:
                              const ChipConfig(wrapType: WrapType.scroll),
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
                      readOnly: readOnly),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      style: const TextStyle(fontSize: 15), //
                      decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.calendar_today),

                        labelText: "Fecha de Nacimiento",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                14)), // Bordes del campo de entrada
                        //hintText: hint,
                        labelStyle: const TextStyle(
                            fontSize: 16), // Tamaño del texto de la etiqueta
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
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
                      readOnly: readOnly),
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
