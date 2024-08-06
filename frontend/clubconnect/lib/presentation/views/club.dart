import 'dart:async';
import 'dart:typed_data';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:flutter/material.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubView extends ConsumerStatefulWidget {
  static const name = 'club-view';
  final int id;

  ClubView({super.key, required this.id});

  @override
  ClubViewState createState() => ClubViewState();
}

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

class ClubViewState extends ConsumerState<ClubView>
    with TickerProviderStateMixin {
  final Uri uriInstagram =
      Uri.parse("https://www.instagram.com/josepeperojas13/");

  late Future<String?> _futureEstado;
  String? estado;
  late Future<ClubEspecifico> _futureClub;
  ClubEspecifico? club = null;
  Uint8List? logoClub;
  get items => null;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late TabController _tabController;
  List<String> categorias = ['Sub-8', 'Sub-10', 'Todo Competidor', 'Senior'];
  List<String> tipo = ['Recreativo', 'Competitivo', 'Formativo'];
  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _futureEstado = ref
        .read(clubConnectProvider)
        .getEstadoSolicitud(ref.read(authProvider).id!, widget.id)
        .then((value) => estado = value);
    _futureClub = ref.read(clubConnectProvider).getClub(widget.id);
    _futureClub.then((value) {
      club = value;
      logoClub = imagenFromBase64(club!.club.logo);
      markers = {
        Marker(
          markerId: MarkerId(club!.club.id!),
          position: LatLng(club!.club.latitud, club!.club.longitud),
          //infoWindow: InfoWindow(title: 'Club Deportivo Mewlen'),
        ),
      };
    });
  }

  Future<void> launchUrlSiteBrowser() async {
    if (await canLaunchUrl(uriInstagram)) {
      await launchUrl(uriInstagram, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uriInstagram';
    }
  }

  Widget textButtonSolicitud() {
    String textButton;
    switch (estado) {
      case "":
        textButton = "Enviar Solicitud";
      case "Aceptado":
        textButton = "Ya eres Miembro";
      case "Pendiente":
        textButton = "Solicitud Enviada";
      case "Cancelada":
        textButton = "Solicitud Cancelada (Reenviar)";
      default:
        textButton = "Enviar Solicitud";
    }
    return ElevatedButton.icon(
      onPressed: () async {
        switch (estado) {
          case "":
            await ref.read(clubConnectProvider).sendSolicitud(
                ref.read(authProvider).id!, int.parse(club!.club.id!));
            setState(
              () {
                estado = "Pendiente";
              },
            );
          case "Cancelada":
            await ref.read(clubConnectProvider).sendSolicitud(
                ref.read(authProvider).id!, int.parse(club!.club.id!));
            setState(
              () {
                estado = "Pendiente";
              },
            );
        }
      },
      icon: const Icon(Icons.send_outlined),
      label: Text(
        textButton,
        style: AppTheme().getTheme().textTheme.bodySmall,
      ),
    );
  }

  Widget bodyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
              child: ImageOval(club!.club.logo, logoClub, 80, 80),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              decoration: decoration,
              child: Row(
                children: [
                  Image(
                    image: AssetImage('assets/miembros.png'),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 10),
                  Text("60", style: AppTheme().getTheme().textTheme.labelSmall)
                ],
              ),
            ),
          ],
        ),
        TabBarWidget(tabController: _tabController),
        Expanded(
          child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        child: Text(club!.club.descripcion,
                            style: AppTheme().getTheme().textTheme.bodyMedium),
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail_lock,
                              color: const Color.fromARGB(255, 145, 134, 39),
                              size: 20),
                          Text(club!.club.correo)
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone,
                              color: const Color.fromARGB(255, 145, 134, 39),
                              size: 20),
                          Text(club!.club.telefono),
                        ],
                      ),
                      divider,
                      Column(
                        children: [
                          Text("Categorías",
                              style:
                                  AppTheme().getTheme().textTheme.titleSmall),
                          WrapView(options: club!.categorias),
                        ],
                      ),
                      divider,
                      Column(
                        children: [
                          Text("Tipo",
                              style:
                                  AppTheme().getTheme().textTheme.titleSmall),
                          WrapView(options: club!.tipo),
                        ],
                      ),
                      divider,
                      Column(
                        children: [
                          Text("Redes",
                              style:
                                  AppTheme().getTheme().textTheme.titleSmall),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await launchUrlSiteBrowser();
                                },
                                icon: Icon(
                                  Icons.facebook,
                                  color:
                                      const Color.fromARGB(255, 145, 134, 39),
                                  size: 30,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      textButtonSolicitud(),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme().getTheme().colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  height: 50,
                  width: 300,
                  child: GoogleMap(
                    markers: markers,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      //bearing: 192.8334901395799,
                      target: LatLng(club!.club.latitud, club!.club.longitud),
                      //tilt: 59.440717697143555,
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                    },
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                  ),
                  /*
                        ),*/
                ),
              ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Estado: $estado");
    return club == null
        ? FutureBuilder<void>(
            future: Future.wait([_futureClub, _futureEstado]),
            builder: (context, snapshot) {
              return Scaffold(
                appBar: AppBar(
                  shadowColor: const Color.fromARGB(255, 0, 0, 0),
                  elevation: 1,
                  backgroundColor: Colors.white,
                  title: Text(
                    snapshot.connectionState == ConnectionState.waiting
                        ? ""
                        : (club?.club.nombre ?? "Club"),
                    style: AppTheme().getTheme().textTheme.titleSmall,
                  ),
                ),
                body: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                        ? const Center(child: Text('Error loading data'))
                        : bodyContent(),
              );
            },
          )
        : Scaffold(
            appBar: AppBar(
              shadowColor: const Color.fromARGB(255, 0, 0, 0),
              elevation: 1,
              backgroundColor: Colors.white,
              title: Text(
                club!.club.nombre,
                style: AppTheme().getTheme().textTheme.titleSmall,
              ),
            ),
            body: bodyContent(),
          );
    /*return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
      child: 
        FutureBuilder(
        future: Future.wait([_futureClub, _futureEstado]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Scaffold(
                  backgroundColor: color,
                  appBar: AppBar(
                    shadowColor: Color.fromARGB(255, 0, 0, 0),
                    elevation: 1,
                    backgroundColor: Colors.white,
                    title: Text(
                      club.club.nombre,
                      style: AppTheme().getTheme().textTheme.titleSmall,
                    ),
                  ),
                  body: bodyContent());
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );*/
  }
}
