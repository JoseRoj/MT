import 'dart:typed_data';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/userTeam.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/views/equiposClub/modalUserPerfil.dart';
import 'package:clubconnect/presentation/widget/modalCarga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Menu { eliminar, perfil }

class AllMiembrosWidget extends ConsumerStatefulWidget {
  final int idclub;
  final Club club;
  //final Future<List<UserTeam>> futuremiembros;
  //final Future<String?> futurerole;
  //final String role;
  final List<UserTeam> miembros;
  final List<Equipo> equipos;
  //final ValueNotifier<int> indexNotifier;
  //final Future<List<UserTeam>> Function() getmiembrosCallBack;
  //final Future<bool> Function(int, int, int) expulsarmiembro;

  const AllMiembrosWidget({
    Key? key,
    required this.idclub,
    required this.club,
    required this.miembros,
    required this.equipos,
  }) : super(key: key);

  @override
  _AllMiembrosWidgetState createState() => _AllMiembrosWidgetState();
}

class _AllMiembrosWidgetState extends ConsumerState<AllMiembrosWidget> {
  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  late List<UserTeam> miembros;
  Uint8List? logoClub;

  @override
  void initState() {
    print("Entrando en AllMiembros");
    super.initState();
    miembros = widget.miembros;
    logoClub = imagenFromBase64(widget.club.logo);
  }

  Future<bool> expulsarmiembro(int idmiembro, int idclub, int index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return modalCarga("Expulsando Miembro del Club...");
      },
    );
    var result = await ref
        .read(clubConnectProvider)
        .deleteMiembroClub(idmiembro, idclub);
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (result) {
      miembros.removeAt(index);
      setState(() {});
      customToast("Se ha explusado del club", context, "isSuccess");
    } else {
      customToast("Error al eliminar del club", context, "isError");
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        miembros =
            await ref.read(clubConnectProvider).getMiembros(widget.idclub);
        setState(() {});
      },
      child: miembros.isEmpty
          ? Center(
              child: ListView(
                children: const [
                  SizedBox(
                    height: 50,
                  ),
                  Icon(Icons.group, size: 100, color: Colors.grey),
                  Center(
                    child: Text("No hay miembros",
                        style: TextStyle(fontSize: 20, color: Colors.grey)),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Número de columnas
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height /
                            2), // Proporción de aspecto,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 3),
                itemCount: miembros.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            miembros[index].imagen == "" ||
                                    miembros[index].imagen == null
                                ? ClipOval(
                                    child: Image.asset(
                                      'assets/nofoto.jpeg',
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                    ),
                                  )
                                : ClipOval(
                                    child: Image.memory(
                                      imagenFromBase64(miembros[index].imagen!),
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "${miembros[index].nombre} ${miembros[index].apellido1} ${miembros[index].apellido2}",
                                style:
                                    AppTheme().getTheme().textTheme.labelMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          top: 0,
                          right: -10,
                          child: PopupMenuButton<Menu>(
                            //popUpAnimationStyle: _animationStyle,
                            icon: const Icon(Icons.more_vert),
                            onSelected: (Menu item) {},
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<Menu>>[
                              PopupMenuItem<Menu>(
                                value: Menu.perfil,
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.info,
                                      color: Colors.black),
                                  title: const Text('Perfil'),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    await Future.delayed(
                                        const Duration(milliseconds: 500));
                                    // ignore: use_build_context_synchronously
                                    modalUserPerfil(context, miembros[index],
                                        widget.club, widget.equipos, ref);
                                    // ignore: use_build_context_synchronously
                                  },
                                ),
                              ),
                              PopupMenuItem<Menu>(
                                value: Menu.eliminar,
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.person_remove_alt_1,
                                    color: Colors.red,
                                  ),
                                  title: const Text('Expulsar'),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    bool expulseResponse =
                                        await expulsarmiembro(
                                            int.parse(miembros[index].id),
                                            widget.idclub,
                                            index);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ))
                    ],
                  );
                },
              ),
            ),
    );
  }
}
