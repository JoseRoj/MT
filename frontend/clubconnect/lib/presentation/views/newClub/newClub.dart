import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:clubconnect/presentation/widget/redSocial.dart';
import 'package:flutter/material.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/views/newClub/modalMaps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../../insfrastructure/models.dart';

class CreateClub extends ConsumerStatefulWidget {
  static const name = 'create-club';
  const CreateClub({super.key});

  @override
  CreateClubState createState() => CreateClubState();
}

class RedSocial {
  String nombre;
  String? url;
  RedSocial({required this.nombre, this.url});
}

class CreateClubState extends ConsumerState<CreateClub> {
  final textTheme = AppTheme().getTheme().textTheme;
  late List<Deporte> items;
  late List<Tipo> tipos;

  List<RedSocial?> redesSocialesSelected = [];

  late List<Categoria> categorias;
  late int id_user;
  late final deportes;
  late GoogleMapController _mapController;
  String? selectedValue;
  LatLng? locationSelected;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _fonoController = TextEditingController();
  final MultiSelectController _controller = MultiSelectController();
  final TextEditingController controllerInstagram = TextEditingController();
  final TextEditingController controllerFacebook = TextEditingController();
  final MultiSelectController _controllerTipo = MultiSelectController();
  final MultiSelectController _controllerDeporte = MultiSelectController();
  File? imagen;
  String base64Image = '';
  final picker = ImagePicker();
  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

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

  void addNewRedSocial(String name, String perfil) {
    redesSocialesSelected.add(RedSocial(nombre: name, url: perfil));
  }

  @override
  Widget build(BuildContext context) {
    tipos = ref.watch(tiposProvider);
    items = ref.watch(deportesProvider);
    id_user = ref.watch(authProvider).id!;
    categorias = ref.watch(categoriasProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        shadowColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0.01,
        backgroundColor: Colors.white,
        title: Text(
          "Nuevo Club",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                              )),
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: formInput(
                    label: "Descripción",
                    controller: _descriptionController,
                    validator: (value) => emptyOrNull(value, "descripción"),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.86,
                  child: MultiSelectDropDown<dynamic>(
                    controller: _controllerDeporte,
                    onOptionSelected: (List<ValueItem> selectedOptions) {},
                    options: items
                        .map((Deporte item) => ValueItem(
                            label: item.nombre.toString(),
                            value: item.id.toString()))
                        .toList(),
                    hint: "Seleccione el deporte",
                    inputDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    selectionType: SelectionType.single,
                    chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                    dropdownHeight: 200,
                    optionTextStyle:
                        const TextStyle(fontSize: 16, color: Colors.black87),
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
                  child: formInput(
                    label: "Teléfono",
                    controller: _fonoController,
                    validator: (value) => emptyOrNullPhone(value),
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.86,
                  child: MultiSelectDropDown(
                    hint: "Selecciona las categorías",
                    inputDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    //showClearIcon: true,
                    selectedOptions: categorias
                        .where((element) => categorias.contains(element.nombre))
                        .map((e) => ValueItem(label: e.nombre, value: e.id))
                        .toList(),
                    controller: _controller,
                    onOptionSelected: (options) {
                      //debugPrint(options.toString());
                    },
                    options: categorias
                        .map((Categoria item) => ValueItem(
                            label: item.nombre.toString(),
                            value: item.id.toString()))
                        .toList(),

                    /* disabledOptions: const [
                      ValueItem(label: 'Option 1', value: '1')
                    ],*/
                    selectionType: SelectionType.multi,
                    chipConfig: const ChipConfig(wrapType: WrapType.scroll),
                    dropdownHeight: 300,
                    optionTextStyle: const TextStyle(fontSize: 16),
                    selectedOptionIcon: const Icon(Icons.check_circle),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.86,
                  child: MultiSelectDropDown(
                    hint: "Selecciona el tipo",
                    inputDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    //showClearIcon: true,
                    controller: _controllerTipo,
                    onOptionSelected: (options) {
                      //debugPrint(options.toString());
                    },
                    options: tipos
                        .map((Tipo item) => ValueItem(
                            label: item.nombre.toString(),
                            value: item.id.toString()))
                        .toList(),
                    /* disabledOptions: const [
                        ValueItem(label: 'Option 1', value: '1')
                      ],*/
                    selectionType: SelectionType.multi,
                    chipConfig: const ChipConfig(wrapType: WrapType.scroll),
                    dropdownHeight: 150,
                    optionTextStyle: const TextStyle(fontSize: 14),
                    selectedOptionIcon: const Icon(Icons.check_circle),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(children: [
                        Text(
                          "Redes Sociales",
                          style: textTheme.labelMedium,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: IconButton.filled(
                            iconSize: 20,
                            padding: EdgeInsets
                                .zero, // Ajusta el padding para reducir el tamaño total
                            onPressed: () async {
                              var response = await addRedSocialModalBottom(
                                  context, addNewRedSocial);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.add,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        width: MediaQuery.of(context).size.width * 0.86,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black54,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(children: [
                          for (var red in redesSocialesSelected)
                            containerRedSocial(red!.nombre, red.url!)
                        ])),
                  ],
                ),
                Center(
                  child: ElevatedButton.icon(
                      label: Text('Seleccionar ubicación',
                          style: textTheme.labelMedium),
                      icon: const Icon(Icons.location_on),
                      onPressed: () async {
                        final locationFuture = ref.watch(locationProvider);
                        final LatLng locationInitial = await locationFuture;
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ModalMap(
                              initialLocation: locationInitial,
                              onLocationSelected: (LatLng location) {
                                setState(() {
                                  if (locationSelected == null) {
                                    locationSelected = location;
                                  } else {
                                    locationSelected = location;
                                    _mapController.animateCamera(
                                      CameraUpdate.newLatLng(locationSelected!),
                                    );

                                    /*markers.clear();
                                  markers.add(Marker(
                                    markerId: MarkerId('1'),
                                    position: location,
                                  ));*/
                                  }
                                });
                              },
                              markers: markers,
                            );
                          },
                        );
                      }),
                ),
                locationSelected != null
                    ? Center(
                        child: SizedBox(
                          height: 200,
                          width: 300,
                          child: GoogleMap(
                            markers: markers,
                            initialCameraPosition: CameraPosition(
                              target:
                                  locationSelected!, // Ubicación inicial del mapa
                              zoom: 15, // Zoom inicial del mapa
                            ),
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                              // Callback cuando el mapa se crea
                              // Aquí puedes inicializar el controlador del mapa
                            },
                          ),
                        ),
                      )
                    : Container(),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {});
                      bool red = redesSocialesSelected
                          .any((element) => element!.nombre == "Instagram");
                      print("x $red");
                      if (_formKey.currentState!.validate()) {
                        // All fields are valid, submit the form
                        // Here you can process the form data
                        String name = _nameController.text;
                        String description = _descriptionController.text;
                        String correo = _correoController.text;
                        String fono = _fonoController.text;
                        print("name $id_user");
                        debugPrint(base64Image);
                        List<dynamic> us = _controller.selectedOptions
                            .map((e) => e.value)
                            .toList();

                        List<dynamic> tipo = _controllerTipo.selectedOptions
                            .map((e) => e.value)
                            .toList();
                        Club club = Club(
                          latitud: locationSelected!.latitude,
                          longitud: locationSelected!.longitude,
                          nombre: name,
                          descripcion: description,
                          idDeporte: _controllerDeporte
                              .selectedOptions.first.value
                              .toString(),
                          logo: base64Image,
                          correo: _correoController.text,
                          telefono: _fonoController.text,
                          facebook: redesSocialesSelected.any(
                                  (element) => element!.nombre == "Facebook")
                              ? redesSocialesSelected
                                  .firstWhere((element) =>
                                      element!.nombre == "Facebook")!
                                  .url
                              : null,
                          instagram: redesSocialesSelected.any(
                                  (element) => element!.nombre == "Instagram")
                              ? redesSocialesSelected
                                  .firstWhere((element) =>
                                      element!.nombre == "Instagram")!
                                  .url
                              : null,
                          tiktok: redesSocialesSelected
                                  .any((element) => element!.nombre == "Tiktok")
                              ? redesSocialesSelected
                                  .firstWhere(
                                      (element) => element!.nombre == "Tiktok")!
                                  .url
                              : null,
                        );

                        // Do something with the data, like saving it to a database
                        final resp = await ref
                            .read(clubConnectProvider)
                            .addClub(club, us, tipo, id_user);
                        print("resp $resp");
                        resp == true
                            ? {
                                // ignore: use_build_context_synchronously
                                customToast("Club creado", context, "isSucess"),
                                Navigator.of(context).pop()
                              }
                            // ignore: use_build_context_synchronously
                            : customToast(
                                "Ha ocurrido un error", context, "isError");
                      }
                    },
                    child: Text('Crear club', style: textTheme.labelMedium),
                  ),
                ),
                //Set an animation
              ],
            ),
          ),
        ),
      ),
    );
  }
}
