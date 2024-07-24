import 'dart:typed_data';

import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/providers/categorias_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/location_provider.dart';
import 'package:clubconnect/presentation/providers/tipos_provider.dart';
import 'package:clubconnect/presentation/views/newClub/modalMaps.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late GoogleMapController _mapController;
  Set<Marker> markers = {};
  Uint8List? logoClub;
  bool readOnly = true;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController fonoController = TextEditingController();
  final MultiSelectController controller = MultiSelectController();
  final MultiSelectController controllerTipoClub = MultiSelectController();

  Future<ClubEspecifico> fetchClub() async {
    final clubData = await ref
        .read(clubConnectProvider)
        .getClub(int.parse(widget.club!.club.id!));
    logoClub = imagenFromBase64(clubData.club.logo);
    descriptionController.text = clubData.club.descripcion;
    return clubData;
  }

  @override
  void initState() {
    super.initState();
    club = widget.club;
    logoClub = imagenFromBase64(club!.club.logo);
    descriptionController.text = club!.club.descripcion;
    correoController.text = club!.club.correo;
    fonoController.text = club!.club.telefono;
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
    return Center(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        readOnly = !readOnly;
                      });
                    },
                  ),
                  right: 0,
                  top: 0,
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromARGB(255, 0, 0, 0), // Color del borde
                        width: 2, // Ancho del borde
                      ),
                    ),
                    child: club!.club.logo == "" || club!.club.logo == null
                        ? ClipOval(
                            child: Image.asset(
                              'assets/nofoto.jpeg',
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          )
                        : ClipOval(
                            child: Image.memory(
                              logoClub!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            club!.club.nombre,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: formInput(
              label: "Descripción",
              readOnly: readOnly,
              maxLines: 3,
              controller: descriptionController,
              validator: (value) => emptyOrNull(value, "descripción"),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: formInput(
              readOnly: readOnly,
              label: "Correo",
              controller: correoController,
              validator: (value) => emptyOrNullEmail(value),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: formInput(
              readOnly: readOnly,
              label: "Teléfono",
              controller: fonoController,
              validator: (value) => emptyOrNullPhone(value),
            ),
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
                            label: e.nombre.toString(), value: e.id.toString()))
                        .toList(),
                    controller: controller,
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
                        .where((element) => club!.tipo.contains(element.nombre))
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
                                locationSelected = location;
                                _mapController.animateCamera(
                                    CameraUpdate.newLatLng(locationSelected!));
                              });
                            },
                            markers: {
                              Marker(
                                  markerId: MarkerId('1'),
                                  position: locationSelected ?? LatLng(0, 0))
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
                            markerId: MarkerId('1'),
                            position: locationSelected ?? LatLng(0, 0))
                      },
                      initialCameraPosition:
                          CameraPosition(target: locationSelected!, zoom: 15),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                    ),
                  ),
                )
              : Container(),
          readOnly
              ? Container()
              : ElevatedButton.icon(
                  label: Text('Guardar',
                      style: Theme.of(context).textTheme.labelMedium),
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    if (controller.selectedOptions.isEmpty ||
                        controllerTipoClub.selectedOptions.isEmpty) {
                      print("No se ha seleccionado un equipo o un rol");
                    } else {
                      // Guarda los cambios
                    }
                  },
                ),
        ],
      ),
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
