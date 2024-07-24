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
  LatLngBounds? _visibleRegion;
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
  void _filterMarkers() {
    if (_visibleRegion == null) return;

    final clubs = ref.read(clubesRegisterProvider);
    markers = clubs
        .map(
          (club) => Marker(
            markerId: MarkerId(club.id!),
            onTap: () => _mostrarInfoWindow(MarkerId(club.id!)),
            position: LatLng(club.latitud, club.longitud),
          ),
        )
        .toSet();
    //setState(() {});
  }

  void closeWindow() {
    clubSelected = null;
    setState(() {});
  }

  void _updateVisibleRegion() async {
    final bounds = await mapController?.getVisibleRegion();
    setState(() {
      _visibleRegion = bounds;
      _filterMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubesRegisterProvider);
    print("SelectBuild : $clubs ");
    final deportes = ref.watch(deportesProvider);
    final Club club;
    final location = ref.watch(locationProvider.notifier).state;
    if (!clubs.isEmpty) {
      markers = clubs
          .map(
            (club) => Marker(
              markerId: MarkerId(club.id!),
              onTap: () =>
                  {_mostrarInfoWindow(MarkerId(club.id!)), setState(() {})},
              //icon: icon!,
              position: LatLng(club.latitud, club.longitud),
            ),
          )
          .toSet();
    } else {
      markers = {};
    }
    //print("Select Build $selectDeporte");

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
              onMapCreated: (GoogleMapController controller) async {
                mapController = controller;
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                  await Future.delayed(Duration(milliseconds: 500));

                  // Esperar a que el mapa se haya creado y la región visible esté disponible
                  final bounds = await mapController.getVisibleRegion();
                  print(bounds);
                  _visibleRegion = bounds;
                  await ref
                      .read(clubesRegisterProvider.notifier)
                      .getClubes(
                          selectDeporte.map((e) => int.parse(e.id)).toList(),
                          bounds.northeast.latitude,
                          bounds.northeast.longitude,
                          bounds.southwest.latitude,
                          bounds.southwest.longitude)
                      .then((value) => isLoading = false);

                  setState(() {});
                }
              },
              onCameraIdle: _updateVisibleRegion,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
            ),
            if (_visibleRegion != null)
              Positioned(
                top: 10,
                left: MediaQuery.of(context).size.width * 0.5 - 100,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(clubesRegisterProvider.notifier).getClubes(
                        selectDeporte.map((e) => int.parse(e.id)).toList(),
                        _visibleRegion!.northeast.latitude,
                        _visibleRegion!.northeast.longitude,
                        _visibleRegion!.southwest.latitude,
                        _visibleRegion!.southwest.longitude);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(200, 40)),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  icon: const Icon(Icons.search_rounded),
                  label: Text('Buscar en esta Zona',
                      style: AppTheme().getTheme().textTheme.labelSmall),
                ),
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
                                              setModalState(
                                                () {
                                                  if (selected) {
                                                    selectDeporte.add(deporte);
                                                  } else {
                                                    selectDeporte
                                                        .remove(deporte);
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                FilledButton(
                                  onPressed: () async {
                                    _updateVisibleRegion();
                                    isLoading = true;
                                    setState(() {});
                                    await ref
                                        .read(clubesRegisterProvider.notifier)
                                        .getClubes(
                                            selectDeporte
                                                .map((e) => int.parse(e.id))
                                                .toList(),
                                            _visibleRegion!.northeast.latitude,
                                            _visibleRegion!.northeast.longitude,
                                            _visibleRegion!.southwest.latitude,
                                            _visibleRegion!.southwest.longitude)
                                        .then((value) => isLoading = false);
                                    setState(() {});

                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Aplicar Filtros'),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
                  if (result == null) {
                    selectDeporte = saveSelect;
                  }
                },
              ),
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
                onPressed: () async {
                  await ref.read(clubesRegisterProvider.notifier).getClubes(
                      selectDeporte.map((e) => int.parse(e.id)).toList(),
                      _visibleRegion!.northeast.latitude,
                      _visibleRegion!.northeast.longitude,
                      _visibleRegion!.southwest.latitude,
                      _visibleRegion!.southwest.longitude);
                }),
          ]),
        ),
      ],
    );
  }
}
