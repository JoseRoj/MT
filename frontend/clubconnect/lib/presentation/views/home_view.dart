import 'dart:async';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/image_to_byte.dart';

import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/providers/usuario_provider.dart';
import 'package:clubconnect/presentation/widget/clubsmaps.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../insfrastructure/models.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {
  late GoogleMapController mapController;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late List<Deporte> deportes;
  late Future<void> _locationFuture;
  late LatLng location;
  late String address;

  Set<Marker> markers = {};
  late List<Club> clubs;
  final _icons = Completer<BitmapDescriptor>();
  var icon;
  @override
  void initState() {
    super.initState();
    _locationFuture = initData();
    assetToBytes('assets/marker.png').then((value) {
      final bitmap = BitmapDescriptor.fromBytes(value);
      _icons.complete(bitmap);
    });
    _icons.future.then((value) {
      icon = value;
    });

    //print(ref.watch(clubesRegisterProvider));
    /*markers = ref
        .watch(clubesRegisterProvider)
        .map((club) => Marker(
              markerId: MarkerId(club.id),
              //icon: _icons.future,
              position: LatLng(club.latitud, club.longitud),
              infoWindow: InfoWindow(
                title: club.nombre,
                snippet: club.descripcion,
              ),
            ))
        .toSet();*/
    //ref.watch(locationProvider);
  }

  /*static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);*/
  Future<void> initData() async {
    try {
      var longlat = await ref.read(locationProvider);
      var direction = await Dio().get(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${longlat.latitude},${longlat.longitude}&result_type=locality&key=${dotenv.env["API_KEY"]}');
      setState(() {
        location = longlat;
        address = direction.data['results'][0]['formatted_address'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuild");
    final id = ref.watch(authProvider).id;
    final user = ref.watch(UsuarioProvider(id!));
    deportes = ref.watch(deportesProvider);

    TextTheme StyleText = AppTheme().getTheme().textTheme;
    // Obtener el valor actual del proveedor locationProvider
    //print("location" + locationFuture.toString());
    var decoration = BoxDecoration(
      color: AppTheme().getTheme().colorScheme.onPrimary,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, 4), // changes position of shadow
        ),
      ],
    );
    return FutureBuilder(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mientras se carga la ubicación, puedes mostrar un indicador de carga
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Si hay un error al obtener la ubicación, puedes mostrar un mensaje de error
          return Center(
            child: Text('Error al obtener la ubicación: ${snapshot.error}'),
          );
        } else {
          print("dsfjlsdnfs");
          //initData();
//          location = snapshot.data[0] as LatLng;
          //location = snapshot.data as LatLng;
          // Cuando se ha obtenido la ubicación, puedes mostrar el mapa
          return Column(children: [
            Container(
              decoration: decoration,
              padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text('ClubConnect.', style: StyleText.titleLarge),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color:
                                    AppTheme().getTheme().colorScheme.secondary,
                                size: 20),
                            Text(address,
                                style: Theme.of(context).textTheme.labelSmall),
                          ],
                        )
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: decoration,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Icon(
                        Icons.notifications,
                        color: Color.fromARGB(255, 255, 230, 3),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(child: ClubsMap(location.latitude, location.longitude)),
          ]);
        }
      },
    );
  }
}
