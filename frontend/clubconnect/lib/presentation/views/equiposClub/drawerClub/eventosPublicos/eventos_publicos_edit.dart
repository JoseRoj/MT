import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:clubconnect/presentation/widget/video/fullscreen_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class EventPublicEdit extends ConsumerStatefulWidget {
  final LocalVideoModel? video;

  const EventPublicEdit({
    super.key,
    required this.video,
  });

  @override
  EventPublicEditWidgetState createState() => EventPublicEditWidgetState();
}

class EventPublicEditWidgetState extends ConsumerState<EventPublicEdit> {
  bool readOnly = false;
  final _dateController = TextEditingController();
  final MultiSelectController _controller = MultiSelectController();

  final _estadoController = TextEditingController();

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
                if (!readOnly) {
                  setState(() {
                    readOnly = !readOnly;
                  });
                } else {
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Video Player + gradiente
              readOnly
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                          label: "Fecha Evento",
                          dark: true,
                          controller: _dateController,
                          validator: (value) =>
                              emptyOrNull(value, "Fecha Evento"),
                          readOnly: true),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        child: TextFormField(
                          readOnly: false,
                          controller: _dateController,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white), //
                          decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.calendar_today),

                            labelText: "Fecha Evento",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    14)), // Bordes del campo de entrada
                            //hintText: hint,
                            labelStyle: const TextStyle(
                                fontSize:
                                    16), // Tamaño del texto de la etiqueta
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

              readOnly
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                          label: "Género",
                          controller: _estadoController,
                          validator: (value) => emptyOrNull(value, "Genero"),
                          readOnly: true),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor:
                              Colors.transparent, // Sin efecto "splash"
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
                              .where((element) =>
                                  element == _estadoController.text)
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
                    Image.network(
                      widget
                          .video!.url, // Aquí el `url` es la ruta de la imagen
                      fit: BoxFit
                          .contain, // Ajusta la imagen dentro del contenedor
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Publicado el 18/05/2024",
                        style: AppTheme()
                            .getTheme(scaffold: Colors.black)
                            .textTheme
                            .labelSmall,
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
