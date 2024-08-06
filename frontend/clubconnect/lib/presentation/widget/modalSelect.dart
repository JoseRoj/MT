import 'package:clubconnect/presentation/views/equipo_view/editEvent_vies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

Future<bool?> modalSelected(
  Widget child,
  BuildContext context,
  DataSource dataSourceTotal,
  DataSource dataSourceSelected,
  Function add,
) async {
  final DataGridController dataGridController = DataGridController();
  final response = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (BuildContext context) => Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Container(
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(
              20)), // Asegura que el material también tenga bordes redondeados

          child: Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Selecciona los miembros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: SfDataGrid(
                    rowHeight: 40,
                    headerRowHeight: 35,
                    source: dataSourceTotal,
                    selectionMode: SelectionMode.multiple,
                    showCheckboxColumn: true,
                    controller: dataGridController,
                    columns: [
                      GridColumn(
                        visible: false,
                        columnName: "ID",
                        label: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'id',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      GridColumn(
                        minimumWidth: MediaQuery.of(context).size.width * 0.65,
                        maximumWidth: MediaQuery.of(context).size.width * 0.65,
                        columnName: 'Miembros',
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: const Text('MIEMBROS',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          dataGridController.selectedRows.forEach((element) {
                            if (!dataSourceSelected
                                .doesRowExist(element.getCells().first.value)) {
                              add(element);
                            }
                          });
                          Navigator.pop(context, true);
                        },
                        child: const Text('Agregar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return response;
}
