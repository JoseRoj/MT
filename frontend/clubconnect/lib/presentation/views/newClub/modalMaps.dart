import 'package:clubconnect/helpers/image_to_byte.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ModalMap extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationSelected;
  final Set<Marker> markers;
  const ModalMap(
      {super.key,
      required this.initialLocation,
      required this.onLocationSelected,
      required this.markers});

  @override
  State<ModalMap> createState() => _ModalMapState();
}

class _ModalMapState extends State<ModalMap> {
  /*Set<Marker> markersCopy = {};

  @override
  void initState() {
    super.initState();
    markersCopy = widget.markers;
  }*/

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.63,
              child: GoogleMap(
                markers: widget.markers,
                initialCameraPosition: CameraPosition(
                  target: widget.initialLocation, // Ubicación inicial del mapa
                  zoom: 13, // Zoom inicial del mapa
                ),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  // Callback cuando el mapa se crea
                  // Aquí puedes inicializar el controlador del mapa
                },
                onTap: (LatLng latLng) async {
                  final icon = await BitmapDescriptor.fromBytes(
                    await assetToBytes('assets/marker.png'),
                  );
                  widget.markers.clear();
                  widget.markers.add(Marker(
                    markerId: MarkerId('1'),
                    icon: icon,
                    position: latLng,
                  ));
                  widget.onLocationSelected(latLng);

                  setState(() {});

                  // Callback cuando se toca el mapa
                  // Aquí puedes actualizar la ubicación seleccionada
                },
              ),
            ),
            Spacer(),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar', style: TextStyle(fontSize: 14))),
          ],
        ),
      ),
    ).build(context);
  }
}
