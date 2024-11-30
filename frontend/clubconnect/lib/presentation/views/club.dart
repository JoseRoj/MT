import 'dart:async';
import 'dart:typed_data';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/screens/public_events.dart';
import 'package:clubconnect/presentation/views/feed/feedScrollable.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:flutter/material.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClubView extends ConsumerStatefulWidget {
  static const name = 'club-view';
  final int id;

  ClubView({super.key, required this.id});

  @override
  ClubViewState createState() => ClubViewState();
}

List<Map<String, dynamic>> videoPosts = [
  {
    "estado": "Activo",
    "club": "Club Mewlen Angol",
    "fecha_evento": "2024-08-15T00:00:00.000Z",
    "url":
        "https://instagram.fccp3-1.fna.fbcdn.net/v/t51.29350-15/435621030_889264159666636_3458351929489774934_n.webp?stp=dst-jpg_e35&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xMDgweDEwODAuc2RyLmYyOTM1MC5kZWZhdWx0X2ltYWdlIn0&_nc_ht=instagram.fccp3-1.fna.fbcdn.net&_nc_cat=104&_nc_ohc=MqFV-oeK4X8Q7kNvgFjYFgj&_nc_gid=3efa323e0cc74cfdb0673287e7de9bb8&edm=APoiHPcBAAAA&ccb=7-5&ig_cache_key=MzM0MTI1ODMwMTY3Njc4Mjk5OQ%3D%3D.3-ccb7-5&oh=00_AYD94M-u7eBLB8uPctZaQ-grDLteZW7iF2h5TQ4etI4BEw&oe=6741C299&_nc_sid=22de04",
    "fecha_publicacion": "2024-08-15T00:00:00.000Z"
  },
  {
    "estado": "Finalizado",
    "club": "Tralkan",
    "fecha_evento": "2024-08-15T00:00:00.000Z",
    "url":
        "https://instagram.fccp3-1.fna.fbcdn.net/v/t51.29350-15/435621030_889264159666636_3458351929489774934_n.webp?stp=dst-jpg_e35&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xMDgweDEwODAuc2RyLmYyOTM1MC5kZWZhdWx0X2ltYWdlIn0&_nc_ht=instagram.fccp3-1.fna.fbcdn.net&_nc_cat=104&_nc_ohc=MqFV-oeK4X8Q7kNvgFjYFgj&_nc_gid=3efa323e0cc74cfdb0673287e7de9bb8&edm=APoiHPcBAAAA&ccb=7-5&ig_cache_key=MzM0MTI1ODMwMTY3Njc4Mjk5OQ%3D%3D.3-ccb7-5&oh=00_AYD94M-u7eBLB8uPctZaQ-grDLteZW7iF2h5TQ4etI4BEw&oe=6741C299&_nc_sid=22de04",
    "fecha_publicacion": "2024-08-15T00:00:00.000Z"
  }
];

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
    _tabController = TabController(length: 3, vsync: this);

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

  Future<void> launchUrlSiteBrowser(Uri redsocial) async {
    if (await canLaunchUrl(redsocial)) {
      await launchUrl(redsocial, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $redsocial';
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
      case "Admin":
        textButton = "Eres Administrador";
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
            /*Container(
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
            ),*/
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
                      club!.club.facebook == "" &&
                              club!.club.instagram == "" &&
                              club!.club.tiktok == ""
                          ? Container()
                          : Column(
                              children: [
                                Text("Redes",
                                    style: AppTheme()
                                        .getTheme()
                                        .textTheme
                                        .titleSmall),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    club!.club.facebook == ""
                                        ? Container()
                                        : IconButton(
                                            onPressed: () async {
                                              final Uri uriInstagram =
                                                  Uri.parse(
                                                      club!.club.instagram!);

                                              await launchUrlSiteBrowser(
                                                  uriInstagram);
                                            },
                                            icon: FaIcon(
                                              FontAwesomeIcons.squareFacebook,
                                              color: Colors.blue,
                                              size: 30,
                                            ),
                                          ),
                                    club!.club.instagram == ""
                                        ? Container()
                                        : IconButton(
                                            onPressed: () async {
                                              final Uri uriInstagram =
                                                  Uri.parse(
                                                      club!.club.instagram!);

                                              await launchUrlSiteBrowser(
                                                  uriInstagram);
                                            },
                                            icon: FaIcon(
                                                FontAwesomeIcons.instagram,
                                                size: 30,
                                                color: Colors
                                                    .purple), // Cambia el color y tamaño si lo deseas
                                          ),
                                    club!.club.tiktok == ""
                                        ? Container()
                                        : IconButton(
                                            onPressed: () async {
                                              final Uri uriInstagram =
                                                  Uri.parse(
                                                      club!.club.instagram!);

                                              await launchUrlSiteBrowser(
                                                  uriInstagram);
                                            },
                                            icon: FaIcon(
                                              FontAwesomeIcons.tiktok,
                                              color: Colors.black,
                                              size: 28,
                                            ),
                                          ),
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
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: videoPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    LocalVideoModel evento =
                        LocalVideoModel.fromJson(videoPosts[index]);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventsPublicClub(
                              club: club!,
                              videos:
                                  videoPosts.map<LocalVideoModel>((videoPost) {
                                return LocalVideoModel.fromJson(videoPost);
                              }).toList(),
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            Center(
                              child: Image.network(
                                  'https://marketplace.canva.com/EAGGE1BZbhA/1/0/1131w/canva-cartel-vertical-moderno-para-promoci%C3%B3n-de-festival-musical-amarillo-SOF81hXuW50.jpg',
                                  fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: evento.estado == "Activo"
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                width: 80,
                                child: Text(
                                  evento.estado,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Estado: $club");
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
