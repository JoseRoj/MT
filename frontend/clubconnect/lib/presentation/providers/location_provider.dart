import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final locationProvider = StateProvider<Future<LatLng>>((ref) {
  return _determinePosition();
});

Future<LatLng> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  Position position;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permantly denied, we cannot request permissions.');
  }
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error(
          'Location permissions are denied (actual value: $permission).');
    }
  }
  position = await Geolocator.getCurrentPosition();
  final location = LatLng(position.latitude, position.longitude);
  //print(position);
  return location;
}

class LocationModel {
  final double latitude;
  final double longitude;
  LocationModel(this.latitude, this.longitude);
}
