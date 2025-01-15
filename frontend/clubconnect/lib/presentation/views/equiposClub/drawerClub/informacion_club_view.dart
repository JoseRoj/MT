import 'dart:io';
import 'dart:typed_data';

import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/providers/categorias_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/location_provider.dart';
import 'package:clubconnect/presentation/providers/tipos_provider.dart';
import 'package:clubconnect/presentation/views/newClub/modalMaps.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:clubconnect/presentation/widget/ImagePicker.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../../../insfrastructure/models.dart';

class InformacionClubWidget extends ConsumerStatefulWidget {
  final ClubEspecifico? club;

  const InformacionClubWidget({
    Key? key,
    required this.club,
  }) : super(key: key);

  @override
  _InformacionClubWidgetState createState() => _InformacionClubWidgetState();
}

class _InformacionClubWidgetState extends ConsumerState<InformacionClubWidget> {
  // * --- * INFORMACION CLUB * --- * //
  late List<Categoria> categorias;
  late Future<ClubEspecifico> _futureclub;
  late List<Tipo> tiposClub;
  late ClubEspecifico? club;
  LatLng? locationSelected;
  LatLng? locationInitial;

  late GoogleMapController _mapController;
  Set<Marker> markers = {};
  Uint8List? logoClub;
  final keyForm = GlobalKey<FormState>();
  bool readOnly = true;
  final picker = ImagePicker();
  File? imagen;
  String base64Image = '';

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController descripcionControllerClub =
      TextEditingController();

  final TextEditingController correoController = TextEditingController();
  final TextEditingController correoControllerClub = TextEditingController();

  final TextEditingController fonoController = TextEditingController();
  final TextEditingController fonoControllerClub = TextEditingController();

  final MultiSelectController usController = MultiSelectController();
  final MultiSelectController usControllerClub = MultiSelectController();

  final MultiSelectController controllerTipoClub = MultiSelectController();

  final TextEditingController instaController = TextEditingController();
  final TextEditingController instaControllerClub = TextEditingController();

  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController tiktokControllerClub = TextEditingController();

  final TextEditingController facebookController = TextEditingController();
  final TextEditingController facebookControllerClub = TextEditingController();
  Future<ClubEspecifico> fetchClub() async {
    final clubData = await ref
        .read(clubConnectProvider)
        .getClub(int.parse(widget.club!.club.id!));

    logoClub = imagenFromBase64(clubData.key!.club.logo);
    descriptionController.text = clubData.key!.club.descripcion;
    return clubData.key!;
  }

  void resetClub(Club club) {
    setState(() {
      //club = widget.club;
      logoClub = imagenFromBase64(club.logo);
      descriptionController.text = club.descripcion;
      descripcionControllerClub.text = club.descripcion;
      correoController.text = club.correo;
      correoControllerClub.text = club.correo;
      fonoController.text = club.telefono;
      fonoControllerClub.text = club.telefono;
      instaController.text = club.instagram ?? "";
      instaControllerClub.text = club.instagram ?? "";
      tiktokController.text = club.tiktok ?? "";
      tiktokControllerClub.text = club.tiktok ?? "";
      facebookController.text = club.facebook ?? "";
      facebookControllerClub.text = club.facebook ?? "";

      locationInitial = LatLng(club.latitud, club.longitud);
      locationSelected = LatLng(club.latitud, club.longitud);
    });
  }

  void onImageSelected(File? image, String base64) {
    imagen = image; // Guarda la imagen selecciona
    base64Image = base64;
    if (base64 != "") {
      logoClub = imagenFromBase64(base64);
      club!.club.logo = base64;
    } else {
      logoClub = null;
      club!.club.logo = base64;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    print("Entre 2 ...");
    club = widget.club;

    logoClub = imagenFromBase64(club!.club.logo);
    base64Image = (club!.club.logo);
    descriptionController.text = club!.club.descripcion;
    descripcionControllerClub.text = club!.club.descripcion;

    correoController.text = club!.club.correo;
    correoControllerClub.text = club!.club.correo;

    fonoController.text = club!.club.telefono;
    fonoControllerClub.text = club!.club.telefono;

    instaController.text = club?.club.instagram ?? "";
    instaControllerClub.text = club?.club.instagram ?? "";

    tiktokController.text = club?.club.tiktok ?? "";
    tiktokControllerClub.text = club?.club.tiktok ?? "";

    facebookController.text = club?.club.facebook ?? "";
    facebookControllerClub.text = club?.club.facebook ?? "";
    locationInitial = LatLng(club!.club.latitud, club!.club.longitud);
    locationSelected = LatLng(club!.club.latitud, club!.club.longitud);
  }

  @override
  Widget build(BuildContext context) {
    tiposClub = ref.watch(tiposProvider);
    categorias = ref.watch(categoriasProvider);
    /*return FutureBuilder(
      future: _futureclub,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            return RefreshIndicator(
              onRefresh: () async {},
              child: */
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Column(
                  children: [
                    IconButton(
                      icon: readOnly
                          ? const Icon(Icons.edit)
                          : const Icon(Icons.edit_off),
                      onPressed: () {
                        setState(() {
                          readOnly = !readOnly;
                          _mapController.animateCamera(
                              CameraUpdate.newLatLng(locationInitial!));
                          locationSelected = locationInitial;
                        });
                      },
                    ),
                    readOnly
                        ? Container()
                        : IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              if (keyForm.currentState!.validate()) {
                                String description = descriptionController.text;
                                String correo = correoController.text;
                                String fono = fonoController.text;

                                List<dynamic> us = usController.selectedOptions
                                    .map((e) => e.value)
                                    .toList();
                                List<dynamic> tipo = controllerTipoClub
                                    .selectedOptions
                                    .map((e) => e.value)
                                    .toList();
                                Club clubSend = Club(
                                  id: widget.club!.club.id,
                                  latitud: locationSelected!.latitude,
                                  longitud: locationSelected!.longitude,
                                  idDeporte: club!.club.idDeporte,
                                  nombre: club!.club.nombre,
                                  correo: correo,
                                  telefono: fono,
                                  descripcion: description,
                                  logo: base64Image,
                                  facebook: facebookController.text,
                                  instagram: instaController.text,
                                  tiktok: tiktokController.text,
                                  /* correo: _correoController.text,
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
                              : null,*/
                                );
                                final response = await ref
                                    .read(clubConnectProvider)
                                    .editClub(clubSend, us, tipo);
                                if (response.statusCode == 200) {
                                  club = await fetchClub();
                                  resetClub(club!.club);
                                  customToast(response.data['message'], context,
                                      "Succes");
                                  readOnly = !readOnly;
                                  setState(() {});
                                } else {
                                  customToast(
                                      response.message, context, "isError");
                                }
                              }

                              /*setState(() {
                                  controllerTipoClub.selectedOptions
                                      .forEach((element) {
                                    print(element);
                                  });
                                });*/
                            },
                          ),
                  ],
                ),
              ),
              Center(
                child: readOnly
                    ? ClipOval(
                        child: InkWell(
                            child: ImageOval(
                                club!.club.logo,
                                base64Image != ""
                                    ? imagenFromBase64(base64Image)
                                    : imagenFromBase64(club!.club.logo),
                                100,
                                100)))
                    : ImagePickerWidget(
                        imageBase64: base64Image,
                        onImageSelected: onImageSelected,
                        memoryImage: logoClub,
                        initialImage: null),
              ),
            ],
          ),
        ),
        Form(
          key: keyForm,
          child: Column(
            children: [
              Text(
                club!.club.nombre,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              readOnly
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                        label: "Descripción",
                        readOnly: readOnly,
                        maxLines: 3,
                        controller: descripcionControllerClub,
                        validator: (value) => emptyOrNull(value, "descripción"),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                        label: "Descripción",
                        readOnly: readOnly,
                        maxLines: 3,
                        controller: descriptionController,
                        validator: (value) => emptyOrNull(value, "descripción"),
                      ),
                    ),
              readOnly
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                        readOnly: readOnly,
                        label: "Correo",
                        controller: correoControllerClub,
                        validator: (value) => emptyOrNullEmail(value),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                        readOnly: readOnly,
                        label: "Correo",
                        controller: correoController,
                        validator: (value) => emptyOrNullEmail(value),
                      ),
                    ),
              readOnly
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                        readOnly: readOnly,
                        label: "Teléfono",
                        controller: fonoControllerClub,
                        validator: (value) => emptyOrNullPhone(value),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: formInput(
                        readOnly: readOnly,
                        label: "Teléfono",
                        controller: fonoController,
                        validator: (value) => emptyOrNullPhone(value),
                      ),
                    ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: formInput(
                    readOnly: readOnly,
                    label: "Instagram",
                    controller:
                        readOnly ? instaControllerClub : instaController,
                    validator: (value) {}),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: formInput(
                    readOnly: readOnly,
                    label: "TikTok",
                    controller:
                        readOnly ? tiktokControllerClub : tiktokController,
                    validator: (value) {}),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: formInput(
                    readOnly: readOnly,
                    label: "Facebook",
                    controller:
                        readOnly ? facebookControllerClub : facebookController,
                    validator: (value) {}),
              ),
              readOnly
                  ? Column(
                      children: [
                        Text("Categorías",
                            style: Theme.of(context).textTheme.titleSmall),
                        WrapView(
                          options: club!.categorias,
                        ),
                      ],
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.86,
                      child: MultiSelectDropDown(
                        hint: "Selecciona las categorías",
                        inputDecoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        selectedOptions: categorias
                            .where((element) =>
                                club!.categorias.contains(element.nombre))
                            .map((e) => ValueItem(
                                label: e.nombre.toString(),
                                value: e.id.toString()))
                            .toList(),
                        controller: usController,
                        onOptionSelected: (options) {},
                        options: categorias
                            .map((Categoria item) => ValueItem(
                                label: item.nombre.toString(),
                                value: item.id.toString()))
                            .toList(),
                        selectionType: SelectionType.multi,
                        chipConfig: const ChipConfig(wrapType: WrapType.scroll),
                        dropdownHeight: 300,
                        optionTextStyle: const TextStyle(fontSize: 16),
                        selectedOptionIcon: const Icon(Icons.check_circle),
                      ),
                    ),
              const SizedBox(height: 5),
              readOnly
                  ? Column(
                      children: [
                        Text("Tipo de Club",
                            style: Theme.of(context).textTheme.titleSmall),
                        WrapView(options: club!.tipo),
                      ],
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.86,
                      child: MultiSelectDropDown(
                        hint: "Selecciona el Tipo de Club",
                        inputDecoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        selectedOptions: tiposClub
                            .where((element) =>
                                club!.tipo.contains(element.nombre))
                            .map((e) => ValueItem(label: e.nombre, value: e.id))
                            .toList(),
                        controller: controllerTipoClub,
                        onOptionSelected: (options) {},
                        options: tiposClub
                            .map((Tipo item) => ValueItem(
                                label: item.nombre.toString(),
                                value: item.id.toString()))
                            .toList(),
                        selectionType: SelectionType.multi,
                        chipConfig: const ChipConfig(wrapType: WrapType.scroll),
                        dropdownHeight: 150,
                        optionTextStyle: const TextStyle(fontSize: 16),
                        selectedOptionIcon: const Icon(Icons.check_circle),
                      ),
                    ),
              readOnly
                  ? Container()
                  : Center(
                      child: ElevatedButton.icon(
                        label: Text('Cambiar ubicación',
                            style: Theme.of(context).textTheme.labelMedium),
                        icon: const Icon(Icons.location_on),
                        onPressed: () async {
                          final locationFuture =
                              await ref.watch(locationProvider);
                          final LatLng location = locationFuture;
                          // ignore: use_build_context_synchronously
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ModalMap(
                                initialLocation: location,
                                onLocationSelected: (LatLng location) {
                                  setState(() {
                                    print("location $location");
                                    locationSelected = location;
                                    _mapController.animateCamera(
                                        CameraUpdate.newLatLng(
                                            locationSelected!));
                                  });
                                },
                                markers: {
                                  Marker(
                                      markerId: const MarkerId('1'),
                                      position: locationSelected ??
                                          const LatLng(0, 0))
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
              locationSelected != null
                  ? Center(
                      child: SizedBox(
                        height: 200,
                        width: 300,
                        child: GoogleMap(
                          markers: {
                            Marker(
                                markerId: const MarkerId('1'),
                                position:
                                    locationSelected ?? const LatLng(0, 0))
                          },
                          initialCameraPosition: CameraPosition(
                              target: locationSelected!, zoom: 15),
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ]),
    );

    /*case ConnectionState.none:
            return Text('none');
          case ConnectionState.active:
            return Text('active');
        }
      },
    );*/
  }
}
