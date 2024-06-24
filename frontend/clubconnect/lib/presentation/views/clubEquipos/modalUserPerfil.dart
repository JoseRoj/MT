import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/insfrastructure/models/userTeam.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/views/clubEquipos/Clubequipos.dart';
import 'package:clubconnect/presentation/views/miembros.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

void modalUserPerfil(BuildContext context, dynamic miembro, Club? club,
    List<Equipo>? equipos, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          miembro.imagen == "" || miembro.imagen == null
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
                                    imagenFromBase64(miembro.imagen),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${miembro.nombre} ${miembro.apellido1} ${miembro.apellido2}",
                              style:
                                  AppTheme().getTheme().textTheme.labelMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                  ),
                  Container(
                    child: Column(
                      children: [
                        textAlert("Fecha de Nacimiento: ",
                            DateToString(miembro.fechaNacimiento)),
                        textAlert("Genero: ", miembro.genero),
                        textAlert("Correo: ", miembro.email),
                        textAlert("Teléfono: ", miembro.telefono),
                      ],
                    ),
                  ),
                  club == null
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(
                                "Equipos",
                                style:
                                    AppTheme().getTheme().textTheme.titleSmall,
                                textAlign: TextAlign.center,
                              ),
                              FilledButton.icon(
                                  onPressed: () async {
                                    final response = await modalAdd(
                                        context,
                                        equipos,
                                        ref,
                                        int.parse(miembro.id),
                                        miembro);
                                    if (response) {
                                      setModalState(() {});
                                    }
                                    // TODO: Crear Funcion para agregar al un nuevo equipo
                                  },
                                  icon: const Icon(Icons.add, size: 10),
                                  label: Text("Agregar",
                                      style: AppTheme()
                                          .getTheme()
                                          .textTheme
                                          .labelSmall)),
                            ]),
                  club == null
                      ? Container()
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: miembro.equipos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 5),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${miembro.equipos[index].nombre}",
                                              style: AppTheme()
                                                  .getTheme()
                                                  .textTheme
                                                  .labelMedium,
                                              textAlign: TextAlign.start),
                                          Text(
                                              "Rol: ${miembro.equipos[index].rol}",
                                              style: AppTheme()
                                                  .getTheme()
                                                  .textTheme
                                                  .labelSmall,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final response = await ref
                                              .read(clubConnectProvider)
                                              .deleteMiembro(
                                                  int.parse(miembro.id),
                                                  int.parse(miembro
                                                      .equipos[index].id));
                                          if (response) {
                                            setModalState(() {});
                                            miembro.equipos.removeAt(index);
                                            customToast(
                                                "Usuario Eliminado del equipo",
                                                context,
                                                "isSuccess");
                                          } else {
                                            customToast(
                                                "Error al eliminar usuario",
                                                context,
                                                "isError");
                                          }
                                          // TODO: Crear Funcion para eliminar de un equipo
                                        },
                                        icon: Icon(Icons.person_remove),
                                      ),
                                    ]),
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<bool> modalAdd(BuildContext context, List<Equipo>? equipos,
    WidgetRef ref, int idusuario, UserTeam miembro) {
  List<String> tipo = [
    "Entrenador",
    "Deportista",
  ];
  final MultiSelectController _controller = MultiSelectController();
  final MultiSelectController _controllerEquipo = MultiSelectController();

  return showDialog<bool>(
      context: context,
// El usuario debe presionar el botón para cerrar el diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 250,
            child: Column(
              children: [
                Text("Agregar a un equipo",
                    style: AppTheme().getTheme().textTheme.titleSmall),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MultiSelectDropDown(
                    hint: "Selecciona Equipo",
                    inputDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    controller: _controllerEquipo,
                    onOptionSelected: (options) {
                      //debugPrint(options.toString());
                    },
                    options: equipos!
                        .map((dynamic item) => ValueItem(
                              label: item.nombre,
                              value: item.id.toString(),
                            ))
                        .toList(),
                    /* disabledOptions: const [
                        ValueItem(label: 'Option 1', value: '1')
                      ],*/
                    selectionType: SelectionType.single,
                    chipConfig: const ChipConfig(wrapType: WrapType.scroll),
                    dropdownHeight: 250,
                    optionTextStyle: const TextStyle(fontSize: 16),
                    selectedOptionIcon: const Icon(Icons.check_circle),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MultiSelectDropDown(
                    hint: "Selecciona tipo de usuario",
                    inputDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    controller: _controller,
                    onOptionSelected: (options) {
                      //debugPrint(options.toString());
                    },
                    options: tipo
                        .map((String item) => ValueItem(
                              label: item,
                              value: item,
                            ))
                        .toList(),
                    /* disabledOptions: const [
                        ValueItem(label: 'Option 1', value: '1')
                      ],*/
                    selectionType: SelectionType.single,
                    chipConfig: const ChipConfig(wrapType: WrapType.scroll),
                    dropdownHeight: 100,
                    optionTextStyle: const TextStyle(fontSize: 16),
                    selectedOptionIcon: const Icon(Icons.check_circle),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    if (_controllerEquipo.selectedOptions.isEmpty ||
                        _controller.selectedOptions.isEmpty) {
                      customToast("Falta seleccionar", context, "isError");
                    } else {
                      final response = await ref
                          .read(clubConnectProvider)
                          .addMiembro(
                              idusuario,
                              int.parse(
                                  _controllerEquipo.selectedOptions[0].value),
                              _controller.selectedOptions[0].value);
                      miembro.equipos.add(EquipoUser(
                          nombre: _controllerEquipo.selectedOptions[0].label,
                          rol: _controller.selectedOptions[0].value));
                      if (response) {
                        // ignore: use_build_context_synchronously
                        customToast("Usuario Agregado", context, "isSuccess");
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(true);
                      } else {
                        customToast("Error al agregar", context, "isError");
                      }
                    }
                    //await ref.read(clubConnectProvider).addMiembro(idusuario, _controllerEquipo.value, _controller)
                    //
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      AppTheme().getTheme().colorScheme.primary,
                    ),
                  ),
                  icon: const Icon(Icons.person_add, size: 15),
                  label: Text("Agregar",
                      style: AppTheme().getTheme().textTheme.labelSmall),
                ),
              ],
            ),
          ),
        );
      }).then(
    (value) => value ?? false,
  );
}
