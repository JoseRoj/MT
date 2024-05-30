import 'dart:async';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter/material.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClubView extends ConsumerStatefulWidget {
  static const name = 'club-view';
  final int id;

  ClubView({super.key, required this.id});

  @override
  ClubViewState createState() => ClubViewState();
}

class ClubViewState extends ConsumerState<ClubView>
    with TickerProviderStateMixin {
  late Future<String?> _futureEstado;
  String? estado;
  late Future<ClubEspecifico> _futureClub;
  late ClubEspecifico club;
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
      print(club.club.nombre);
      markers = {
        Marker(
          markerId: MarkerId(club.club.id!),
          position: LatLng(club.club.latitud, club.club.longitud),
          //infoWindow: InfoWindow(title: 'Club Deportivo Mewlen'),
        ),
      };
    });
  }

  /*void obtenerDatosClub() async {
    // Obtener el proveedor del club
    try {
      // Llama a la función getClub para obtener los datos del club
      club = await ref.read(clubConnectProvider).getClub(widget.id);
      // Aquí puedes manejar los datos del club obtenidos
      print('Nombre del club: ${club.club.nombre}');
      print('Descripción del club: ${club.club.descripcion}');
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir al obtener los datos del club
      print('Error al obtener los datos del club: $e');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    print("Estado: $estado");
    //final _formKey = GlobalKey<FormBuilderState>();
    Color color = AppTheme().getTheme().colorScheme.onPrimary;
    var StyleText = AppTheme().getTheme().textTheme;
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

    return Container(
      decoration:
          BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255)),
      child: FutureBuilder(
        future: Future.wait([_futureClub, _futureEstado]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              print("data" + snapshot.data.toString());
              print("Estado: $estado");
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
                body: Column(
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
                                color: Color.fromARGB(
                                    255, 0, 0, 0), // Color del borde
                                width: 2, // Ancho del borde
                              ),
                            ),
                            child: ClipOval(
                              child: Image.memory(
                                imagenFromBase64(club.club.logo),
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 0),
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
                                Text("60",
                                    style: AppTheme()
                                        .getTheme()
                                        .textTheme
                                        .labelSmall)
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Text(club.club.descripcion,
                                          style: AppTheme()
                                              .getTheme()
                                              .textTheme
                                              .bodyMedium),
                                    ),
                                    divider,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.mail_lock,
                                            color: const Color.fromARGB(
                                                255, 145, 134, 39),
                                            size: 20),
                                        Text(club.club.correo)
                                      ],
                                    ),
                                    divider,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.phone,
                                            color: const Color.fromARGB(
                                                255, 145, 134, 39),
                                            size: 20),
                                        Text(club.club.telefono),
                                      ],
                                    ),
                                    divider,
                                    Column(
                                      children: [
                                        Text("Categorías",
                                            style: AppTheme()
                                                .getTheme()
                                                .textTheme
                                                .titleSmall),
                                        WrapView(options: club.categorias),
                                      ],
                                    ),
                                    divider,
                                    Column(
                                      children: [
                                        Text("Tipo",
                                            style: AppTheme()
                                                .getTheme()
                                                .textTheme
                                                .titleSmall),
                                        WrapView(options: club.tipo),
                                      ],
                                    ),
                                    divider,
                                    Column(
                                      children: [
                                        Text("Redes",
                                            style: AppTheme()
                                                .getTheme()
                                                .textTheme
                                                .titleSmall),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.facebook,
                                                  color: const Color.fromARGB(
                                                      255, 59, 89, 152),
                                                  size: 30),
                                            ]),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        if (estado == "") {
                                          await ref
                                              .read(clubConnectProvider)
                                              .sendSolicitud(
                                                  ref.read(authProvider).id!,
                                                  int.parse(club.club.id!));
                                          setState(() {
                                            estado = "Pendiente";
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.send_outlined),
                                      label: estado == ""
                                          ? Text(
                                              "Enviar Solicitud",
                                              style: StyleText.bodySmall,
                                            )
                                          : estado == "Aceptada"
                                              ? Text(
                                                  "Ya eres Miembro",
                                                  style: StyleText.bodySmall,
                                                )
                                              : estado == "Pendiente"
                                                  ? Text(
                                                      "Solicitud Enviada",
                                                      style:
                                                          StyleText.bodySmall,
                                                    )
                                                  : Text(
                                                      "Solicitud Cancelada",
                                                      style:
                                                          StyleText.bodySmall,
                                                    ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme()
                                      .getTheme()
                                      .colorScheme
                                      .onPrimary,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                height: 50,
                                width: 300,
                                child: GoogleMap(
                                  markers: markers,
                                  mapType: MapType.normal,
                                  initialCameraPosition: CameraPosition(
                                    //bearing: 192.8334901395799,
                                    target: LatLng(
                                        club.club.latitud, club.club.longitud),
                                    //tilt: 59.440717697143555,
                                    zoom: 15,
                                  ),
                                  onMapCreated:
                                      (GoogleMapController controller) {
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
                    ]),
              );
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
