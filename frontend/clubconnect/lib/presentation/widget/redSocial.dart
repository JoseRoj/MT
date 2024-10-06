// ignore: file_names

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class RedSocial {
  String nombre;
  String? url;
  RedSocial({required this.nombre, this.url});
}

List<RedSocial> redes = [
  RedSocial(nombre: "Instagram"),
  RedSocial(nombre: "Facebook"),
  RedSocial(nombre: "TikTok"),
];

Future<bool?> addRedSocialModalBottom(BuildContext context,
    Function(String, String) add, List<dynamic> redesSelected) async {
  final MultiSelectController _perfilController = MultiSelectController();
  final TextEditingController controllerInstagram = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  return showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: 500,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: MultiSelectDropDown(
                          suffixIcon:
                              const Icon(Icons.arrow_drop_down, size: 13),
                          clearIcon: const Icon(Icons.clear, size: 10),
                          hint: "Red Social",
                          inputDecoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black54,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          //showClearIcon: true,
                          controller: _perfilController,
                          onOptionSelected: (options) {
                            //debugPrint(options.toString());
                          },
                          options: redes
                              .map((RedSocial item) => ValueItem(
                                  label: item.nombre.toString(),
                                  value: item.nombre.toString()))
                              .toList(),
                          /* disabledOptions: const [
                                                                      ValueItem(label: 'Option 1', value: '1')
                                                                    ],*/
                          selectionType: SelectionType.single,
                          chipConfig:
                              const ChipConfig(wrapType: WrapType.scroll),
                          dropdownHeight: 150,
                          optionTextStyle: const TextStyle(fontSize: 12),
                          selectedOptionIcon: const Icon(
                            Icons.check_circle,
                            size: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        child: formInput(
                          label: "URL Perfil Red Social",
                          controller: controllerInstagram,
                          validator: (value) =>
                              emptyOrNull(value, "URL Perfil"),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_perfilController.selectedOptions.isEmpty) {
                          customToast(
                              "Seleccione la red Social", context, "isError");
                        } else {
                          add(_perfilController.selectedOptions.first.value,
                              controllerInstagram.text);
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    child:
                        const Text("Agregar", style: TextStyle(fontSize: 16))),
              ],
            ),
          ),
        );
      });
}

Widget containerRedSocial(
    String redSocial, String perfil, Function deleteRedSocial) {
  return Container(
    height: 40,
    margin: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black54,
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize:
          MainAxisSize.min, // Hace que el Row use solo el espacio necesario

      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppTheme().getTheme().primaryColorLight,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            border: Border(
              right: BorderSide(
                color: Colors.black54,
              ),
            ),
          ),
          height: 40,
          width: 100,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: redSocial,
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: GestureDetector(
                      onTap: () {
                        deleteRedSocial();
                      },
                      child: Icon(
                        Icons.close,
                        size: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: Container(
          padding: const EdgeInsets.only(bottom: 28),
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 14),
            readOnly: true,
            initialValue: perfil,
            decoration: const InputDecoration(
              fillColor: Colors.red,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        )
            /*child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              height: 40,
              width: 140,
              child: Text(
                  "sdnfjkdsjfkgdjkgbfhjdsbfhjbfgbdfhjgbhjdfbgjhdfbjhgbdfhjgbdhjfbgdgdfgdfgdfgdfgfdfhjnjkdfngkjd")),*/
            ),
      ],
    ),
  );
}
