import 'dart:async';
import 'dart:ui';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/loadEventPublic.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/deporte_provider.dart';
import 'package:clubconnect/presentation/providers/discover_provider.dart';
import 'package:clubconnect/presentation/widget/bottonCardClub.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide ClusterManager, Cluster;

import '../../insfrastructure/models/club.dart';
import '../providers/location_provider.dart';

class ClubsMap extends ConsumerStatefulWidget {
  final latitude;
  final longitude;
  const ClubsMap(this.latitude, this.longitude, {super.key});

  @override
  ClubsMapState createState() => ClubsMapState();
}

class Place with ClusterItem {
  final String id;
  final LatLng latLng;

  Place({required this.latLng, required this.id});

  @override
  LatLng get location => latLng;
}

class ClubsMapState extends ConsumerState<ClubsMap> {
  late ClusterManager manager;
  LatLngBounds? _visibleRegion;
  bool isLoading = false;
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> markers = {};
  List<Deporte> selectDeporte = [];
  List<Deporte> saveSelect = [];
  var isChanged = false;
  bool clusterTap = false;

  int? clubSelected;
  int? _bottomInfoWindow;
  @override
  void initState() {
    manager = ClusterManager<Place>(
      [],
      _updateMarkers,
      markerBuilder: markerBuilder,
      levels: [1, 4.25, 6.75, 8.25, 11.5, 13, 14.5, 16.0, 16.5, 20.0],
      extraPercent:
          0.2, // Optional : This number represents the percentage (0.2 for 20%) of latitude and longitude (in each direction) to be considered on top of the visible map bounds to render clusters. This way, clusters don't "pop out" when you cross the map.

      //stopClusteringZoom: 13,
    );
    selectDeporte = ref.read(deportesProvider).map((e) => e).toList();
    super.initState();
  }

  //* ------------- Funciones ------------- */
  void _updateMarkers(Set<Marker> newMarkers) {
    setState(() {
      markers = newMarkers;
    });
  }

  Future<Marker> Function(Cluster<Place>) get markerBuilder => (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          icon: await _getMarkerBitmap(cluster.isMultiple ? 80 : 40,
              text: cluster.isMultiple ? cluster.count.toString() : null),
          onTap: () {
            clusterTap = true;
            if (cluster.isMultiple) {
              // Aquí podrías hacer zoom en la cámara si el cluster tiene múltiples elementos
              mapController.animateCamera(
                CameraUpdate.newLatLngZoom(cluster.location, 16),
              );
            } else {
              _mostrarInfoWindow(MarkerId(cluster.items.first.id));
            }
          },
        );
      };
  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  void _mostrarInfoWindow(MarkerId markerId) {
    setState(() {
      clubSelected = int.parse(markerId.value);
    });
  }

  /* void _filterMarkers() {
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
  }*/
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

  Future<void> _updateVisibleRegion() async {
    final bounds = await mapController.getVisibleRegion();
    /*await ref.read(clubesRegisterProvider.notifier).getClubes(
        selectDeporte.map((e) => int.parse(e.id)).toList(),
        bounds.northeast.latitude,
        bounds.northeast.longitude,
        bounds.southwest.latitude,
        bounds.southwest.longitude);*/

    _visibleRegion = bounds;
  }

  @override
  Widget build(BuildContext context) {
    print("jojo");
    final clubs = ref.watch(clubesRegisterProvider);
    final deportes = ref.watch(deportesProvider);
    final Club club;
    final location = ref.watch(locationProvider.notifier).state;

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
                manager.setMapId(controller.mapId);
                manager.setMapId(controller.mapId);
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                  // Espera a que el mapa esté completamente cargado
                  await Future.delayed(Duration(
                      seconds: 1)); // Ajusta el tiempo según sea necesario

                  final bounds = await controller.getVisibleRegion();
                  _visibleRegion = bounds;

                  // Obtén los límites visibles y asegúrate de que los clubes estén cargados
                  List<Club> clubes =
                      await ref.read(clubesRegisterProvider.notifier).getClubes(
                            selectDeporte.map((e) => int.parse(e.id)).toList(),
                            _visibleRegion!.northeast.latitude,
                            _visibleRegion!.northeast.longitude,
                            _visibleRegion!.southwest.latitude,
                            _visibleRegion!.southwest.longitude,
                          );

                  await ref
                      .read(discoverProvider)
                      .loadNextPage(getIdClubes(clubes), false);

                  // Establece los ítems del manager
                  manager.setItems(clubes.map((club) {
                    return Place(
                      latLng: LatLng(club.latitud, club.longitud),
                      id: club.id!,
                    );
                  }).toList());

                  // Actualiza el mapa
                  manager.updateMap();
                  isLoading == false;
                  setState(() {});
                }
              },
              onCameraIdle: () async {
                await _updateVisibleRegion();

                manager.updateMap();

                // Asegúrate de actualizar el ClusterManager con los nuevos clubes
              },
              onCameraMove: (position) {
                manager.onCameraMove(position);
              },
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
            ),
            uiSearching(),
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
                                    setState(() {
                                      isLoading = true;
                                    });
                                    List<Club> clubes = await ref
                                        .read(clubesRegisterProvider.notifier)
                                        .getClubes(
                                            selectDeporte
                                                .map((e) => int.parse(e.id))
                                                .toList(),
                                            _visibleRegion!.northeast.latitude,
                                            _visibleRegion!.northeast.longitude,
                                            _visibleRegion!.southwest.latitude,
                                            _visibleRegion!
                                                .southwest.longitude);

                                    manager.setItems(clubes.map((club) {
                                      return Place(
                                        latLng:
                                            LatLng(club.latitud, club.longitud),
                                        id: club.id!,
                                      );
                                    }).toList());
                                    setState(() {
                                      isLoading = false;
                                    });
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
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () async {
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(CameraUpdate.newLatLngZoom(
                      LatLng(widget.latitude, widget.longitude), 14));
                  manager.setItems(clubs.map((club) {
                    // Aquí deberías crear un nuevo objeto Place con los datos del club
                    return Place(
                      latLng: LatLng(club.latitud, club.longitud),
                      // Asumiendo que Place tiene un constructor que acepta ciertos parámetros
                      // Cambia esto según cómo esté definido tu constructor de Place
                      id: club.id!,
                      // Otros campos según la definición de Place
                    );
                  }).toList());
                }, // Llama a la función para ir a la ubicación del usuario
                child: const Icon(Icons.location_searching),
              ),
            ),
            if (clubSelected != null)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: BottomCardClub(
                  club: clubs.firstWhere(
                      (element) => element.id == clubSelected.toString()),
                  deportes: deportes,
                  closeWindow: closeWindow,
                ),
              ),
            /*IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await ref.read(clubesRegisterProvider.notifier).getClubes(
                      selectDeporte.map((e) => int.parse(e.id)).toList(),
                      _visibleRegion!.northeast.latitude,
                      _visibleRegion!.northeast.longitude,
                      _visibleRegion!.southwest.latitude,
                      _visibleRegion!.southwest.longitude);
                }),*/
          ]),
        ),
      ],
    );
  }

  //* ---- Widgets ---------- *//
  Widget uiSearching() {
    return Positioned(
      top: 10,
      left: MediaQuery.of(context).size.width * 0.5 - 100,
      child: ElevatedButton.icon(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          clubSelected = null;
          List<Club> clubes = await ref
              .read(clubesRegisterProvider.notifier)
              .getClubes(
                  selectDeporte.map((e) => int.parse(e.id)).toList(),
                  _visibleRegion!.northeast.latitude,
                  _visibleRegion!.northeast.longitude,
                  _visibleRegion!.southwest.latitude,
                  _visibleRegion!.southwest.longitude);
          await ref
              .read(discoverProvider)
              .loadNextPage(getIdClubes(clubes), true);
          manager.setItems(clubes.map((club) {
            // Aquí deberías crear un nuevo objeto Place con los datos del club
            return Place(
              latLng: LatLng(club.latitud, club.longitud),
              // Asumiendo que Place tiene un constructor que acepta ciertos parámetros
              // Cambia esto según cómo esté definido tu constructor de Place
              id: club.id!,
              // Otros campos según la definición de Place
            );
          }).toList());
          setState(() {
            isLoading = false;
          });
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(200, 40)),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          foregroundColor: WidgetStateProperty.all(Colors.black),
        ),
        icon: const Icon(Icons.search_rounded),
        label: Text(isLoading ? 'Buscando ... ' : 'Buscar aquí',
            style: AppTheme().getTheme().textTheme.labelSmall),
      ),
    );
  }
}
