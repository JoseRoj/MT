import 'dart:async';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/deporte_provider.dart';
import 'package:clubconnect/presentation/widget/bottonCardClub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../insfrastructure/models/club.dart';
import '../providers/location_provider.dart';

class ClubsMap extends ConsumerStatefulWidget {
  final latitude;
  final longitude;
  const ClubsMap(this.latitude, this.longitude, {super.key});

  @override
  ClubsMapState createState() => ClubsMapState();
}

class ClubsMapState extends ConsumerState<ClubsMap> {
  var isLoading = false;
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> markers = {};
  List<Deporte> selectDeporte = [];
  List<Deporte> saveSelect = [];
  var isChanged = false;

  int? clubSelected;
  int? _bottomInfoWindow;
  @override
  void initState() {
    print("Select2");
    selectDeporte = ref.read(deportesProvider).map((e) => e).toList();
    super.initState();
  }

  void _mostrarInfoWindow(MarkerId markerId) {
    clubSelected = int.parse(markerId.value);
    print(clubSelected);
    setState(() {});
  }

  /*markers = clubs
        .map((club) => Marker(
              markerId: MarkerId(club.id),
              position: LatLng(club.latitud, club.longitud),
              infoWindow: InfoWindow(
                title: club.nombre,
                snippet: club.descripcion,
              ),
            ))
        .toSet();*/

  void closeWindow() {
    clubSelected = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubesRegisterProvider);
    print("SelectBuild");
    final deportes = ref.watch(deportesProvider);
    final Club club;
    final location = ref.watch(locationProvider.notifier).state;
    if (!clubs.isEmpty) {
      markers = clubs
          .map((club) => Marker(
                markerId: MarkerId(club.id!),
                onTap: () =>
                    {_mostrarInfoWindow(MarkerId(club.id!)), setState(() {})},
                //icon: icon!,
                position: LatLng(club.latitud, club.longitud),
              ))
          .toSet();
    } else {
      markers = {};
    }
    print("Select Build $selectDeporte");

    //final clubs = ref.watch(clubesRegistredProvider);
    return Column(
      children: [
        //isLoading ? CircularProgressIndicator() : Container(),
        Flexible(
          child: Stack(children: [
            GoogleMap(
              markers: markers,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                //bearing: 192.8334901395799,
                target: LatLng(widget.latitude, widget.longitude),
                //tilt: 59.440717697143555,
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.filled(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () async {
                    saveSelect = selectDeporte.map((e) => e).toList();

                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 30),
                          height: 250,
                          width: double.infinity,
                          child: StatefulBuilder(
                              builder: (context, setModalState) {
                            return ListView(
                              children: [
                                Wrap(
                                  children: deportes
                                      .map(
                                        (deporte) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1, horizontal: 4),
                                          child: FilterChip(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            label: Text(
                                              deporte.nombre,
                                              style: AppTheme()
                                                  .getTheme()
                                                  .textTheme
                                                  .labelSmall,
                                            ),
                                            selected:
                                                selectDeporte.contains(deporte),
                                            onSelected: (selected) {
                                              setModalState(() {
                                                if (selected) {
                                                  selectDeporte.add(deporte);
                                                } else {
                                                  selectDeporte.remove(deporte);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                FilledButton(
                                  onPressed: () async {
                                    isLoading = true;
                                    setState(() {});
                                    await ref
                                        .read(clubesRegisterProvider.notifier)
                                        .getClubes(selectDeporte
                                            .map((e) => int.parse(e.id))
                                            .toList())
                                        .then((value) => isLoading = false);
                                    setState(() {});

                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Aplicar Filtros'),
                                ),
                              ],
                            );
                          }),
                        );
                      },
                    );

                    if (result == null) {
                      selectDeporte = saveSelect;
                    }
                  }),
            ),
            isLoading
                ? const Positioned(
                    child: Center(child: CircularProgressIndicator()))
                : Container(),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () async {
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(CameraUpdate.newLatLngZoom(
                      LatLng(widget.latitude, widget.longitude), 14));
                }, // Llama a la función para ir a la ubicación del usuario
                child: const Icon(Icons.location_searching),
              ),
            ),
            clubSelected != null
                ? Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: bottomCardClub(
                      clubs.firstWhere(
                          (element) => element.id == clubSelected.toString()),
                      deportes,
                      context,
                      closeWindow,
                    ),
                  )
                : Container(),
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(clubesRegisterProvider.notifier).getClubes(
                      selectDeporte.map((e) => int.parse(e.id)).toList());
                }),
          ]),
        ),
      ],
    );
  }
}
