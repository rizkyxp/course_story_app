import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:story_app/util/colors.dart';
import 'package:go_router/go_router.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final initLocation = const LatLng(-6.8957473, 107.6337669);
  late GoogleMapController mapController;
  late final Set<Marker> markers = {};
  geo.Placemark? placemark;
  LatLng? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initLocation,
                zoom: 16,
              ),
              markers: markers,
              onMapCreated: (controller) {
                final marker = Marker(
                  markerId: const MarkerId("source"),
                  position: initLocation,
                );
                setState(() {
                  mapController = controller;
                  markers.add(marker);
                });
              },
              onLongPress: (LatLng latLng) => onLongPressMap(latLng),
            ),
            if (placemark != null)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          placemark!.street!,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            '${placemark!.subLocality}, ${placemark!.locality}, ${placemark!.postalCode}, ${placemark!.country}'),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                            onPressed: () {
                              context.pop(PickerResponse(
                                  latLng: location!,
                                  street: placemark!.street!,
                                  address:
                                      '${placemark!.subLocality}, ${placemark!.locality}, ${placemark!.postalCode}, ${placemark!.country}'));
                            },
                            child: Text('Select Location'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void defineMarker(LatLng latLng, String street, String address) {
    final marker = Marker(
        markerId: const MarkerId("source"),
        position: latLng,
        infoWindow: InfoWindow(
          title: street,
          snippet: address,
        ));

    /// todo--03: clear and add a new marker
    if (mounted) {
      setState(() {
        markers.clear();
        markers.add(marker);
      });
    }
  }

  void onLongPressMap(LatLng latLng) async {
    try {
      final info = await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      final place = info[0];
      final street = place.street!;
      final address = '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

      setState(() {
        placemark = place;
        location = latLng;
      });

      defineMarker(latLng, street, address);

      mapController.animateCamera(CameraUpdate.newLatLng(latLng));
    } catch (e) {
      setState(() {
        placemark = null;
      });
      defineMarker(latLng, 'no address', 'no address');
      mapController.animateCamera(CameraUpdate.newLatLng(latLng));
    }
  }
}

class PickerResponse {
  final LatLng latLng;
  final String street;
  final String address;

  PickerResponse({required this.latLng, required this.street, required this.address});
}
