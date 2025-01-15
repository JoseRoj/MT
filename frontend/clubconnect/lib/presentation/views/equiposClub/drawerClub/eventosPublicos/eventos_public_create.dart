import 'dart:io';
import 'dart:typed_data';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class EventPublicEditCreate extends ConsumerStatefulWidget {
  final String idClub;
  final Future<void> Function(Post newPost) addEvent;
  const EventPublicEditCreate({
    required this.addEvent,
    required this.idClub,
    super.key,
  });

  @override
  EventPublicEditCreateWidgetState createState() =>
      EventPublicEditCreateWidgetState();
}

class EventPublicEditCreateWidgetState
    extends ConsumerState<EventPublicEditCreate> {
  final picker = ImagePicker();
  final _dateController = TextEditingController();
  File? initialImage; // Imagen inicial (puede ser null)
  String imageBase64 = "";
  Uint8List? memoryImage;

  final MultiSelectController _controller = MultiSelectController();

  final _estadoController = TextEditingController();

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      initialImage = File(pickedFile.path);
      imageBase64 = await toBase64C(pickedFile.path);
      memoryImage = imagenFromBase64(imageBase64);
    }
    setState(() {});
    //widget.onImageSelected(widget.initialImage, widget.imageBase64);
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      initialImage = File(pickedFile.path);
      imageBase64 = await toBase64C(pickedFile.path);
      memoryImage = imagenFromBase64(imageBase64);
    }
    setState(() {});
    //widget.onImageSelected(widget.initialImage, widget.imageBase64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // Cambia el color del icono de retroceso aquí
          ),
          backgroundColor: Colors.black,
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
                final Post newPost = new Post(
                    fechaPublicacion: DateTime.now(),
                    fechaEvento: transformarAFecha(_dateController.text),
                    estado: true,
                    clubId: widget.idClub,
                    image: imageBase64);
                await widget.addEvent(newPost);
                context.pop();
              },
              child: const Text(
                "Agregar",
                style: TextStyle(fontSize: 14),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Video Player + gradiente
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: TextFormField(
                    readOnly: false,
                    controller: _dateController,
                    style:
                        const TextStyle(fontSize: 15, color: Colors.white), //
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.calendar_today),

                      labelText: "Fecha Evento",
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
                            //maximumDate: DateTime.now(),
                            initialDateTime: _dateController.text.isEmpty
                                ? DateTime(2024)
                                : DateFormat("dd/MM/yyyy")
                                    .parse(_dateController.text),
                            //                                  initialDateTime: .now(),
                            onDateTimeChanged: (DateTime value) {
                              DateTime fecha = DateTime.parse(value.toString());
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

              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent, // Sin efecto "splash"
                    highlightColor:
                        Colors.transparent, // Sin efecto "highlight"
                  ),
                  child: MultiSelectDropDown(
                    hint: "Estado",
                    inputDecoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    selectedOptions: estados
                        .where((element) => element == _estadoController.text)
                        .map((element) => ValueItem(
                              label: _estadoController.text,
                              value: element,
                            ))
                        .toList(),
                    controller: _controller,
                    onOptionSelected: (options) {
                      // Acción al seleccionar una opción
                    },
                    options: estados
                        .map((String item) => ValueItem(
                              label: item,
                              value: item,
                            ))
                        .toList(),
                    selectionType: SelectionType.single,
                    chipConfig: const ChipConfig(
                      wrapType: WrapType.scroll,
                    ),
                    dropdownHeight: 100,
                    clearIcon: Icon(Icons.close_outlined,
                        size: 20, color: Colors.white),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    optionTextStyle: const TextStyle(color: Colors.black),
                    selectedOptionIcon: const Icon(Icons.check_circle),
                    selectedOptionTextColor: Colors.amber,
                    hintColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alinea el contenido arriba

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
                                      Navigator.of(context)
                                          .pop(); // Cierra el diálogo
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera),
                                    title: const Text('Cámara'),
                                    onTap: () async {
                                      await _pickImageFromCamera();
                                      Navigator.of(context)
                                          .pop(); // Cierra el diálogo
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: memoryImage == null
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white, // Color del borde
                                    width: 2.0, // Ancho del borde
                                    strokeAlign: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: 200,
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Agrega tu evento",
                                    style: AppTheme()
                                        .getTheme(scaffold: Colors.black)
                                        .textTheme
                                        .bodyMedium,
                                  )
                                ],
                              ),
                            )
                          : Image.memory(
                              memoryImage!,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )

        // Botones
        /*Positioned(
              bottom: 40,
              right: 20,
              child: VideoButtons(video: videoPost)
            ),*/

        );
  }
}