import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/provider/story_provider.dart';
import 'package:story_app/util/colors.dart';
import 'package:geocoding/geocoding.dart' as geo;

class DetailStoryScreen extends StatefulWidget {
  final String id;
  const DetailStoryScreen({super.key, required this.id});

  @override
  State<DetailStoryScreen> createState() => _DetailStoryScreenState();
}

class _DetailStoryScreenState extends State<DetailStoryScreen> {
  geo.Placemark? placemark;
  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (mounted && token != null) {
          Provider.of<DetailStoryProvider>(context, listen: false).getDetailStory(token, widget.id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Story',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => context.goNamed('story'),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: Consumer<DetailStoryProvider>(
        builder: (context, value, child) {
          if (value.state == StoryState.initial) {
            return const Center();
          } else if (value.state == StoryState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (value.state == StoryState.error) {
            return Center(
              child: Text(value.message),
            );
          } else {
            if (isValidLocation(value.detailStoryModel.story.lat, value.detailStoryModel.story.lon)) {
              initialMarker(value.detailStoryModel.story.lat!, value.detailStoryModel.story.lon!);
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, top: 8, left: 8, right: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                value.detailStoryModel.story.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                formatDate(value.detailStoryModel.story.createdAt),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 10, right: 8, bottom: 8),
                    child: Text(
                      value.detailStoryModel.story.description,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                  Image.network(value.detailStoryModel.story.photoUrl),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 10, right: 8, bottom: 8),
                    child: Text(
                      'Location:',
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: isValidLocation(value.detailStoryModel.story.lat, value.detailStoryModel.story.lon)
                        ? GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(value.detailStoryModel.story.lat!, value.detailStoryModel.story.lon!),
                              zoom: 18,
                            ),
                            markers: markers,
                            onMapCreated: (controller) {
                              setState(() {
                                mapController = controller;
                              });
                            },
                            gestureRecognizers: const {
                              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)
                            },
                          )
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.location_off_outlined), Text('Location not available')],
                          )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  bool isValidLocation(double? lat, double? lng) {
    return lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  void defineMarker(double latitude, double longitude, String street, String address) {
    final marker = Marker(
      markerId: const MarkerId("source"),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: street,
        snippet: address,
      ),
    );

    /// todo--03: clear and add a new marker
    if (mounted) {
      setState(() {
        markers.clear();
        markers.add(marker);
      });
    }
  }

  void initialMarker(double latitude, double longitude) async {
    try {
      final info = await geo.placemarkFromCoordinates(latitude, longitude);
      final place = info[0];
      final street = place.street!;
      final address = '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

      setState(() {
        placemark = place;
      });

      defineMarker(latitude, longitude, street, address);
    } catch (e) {
      defineMarker(latitude, longitude, 'Address not found', e.toString());
    }
  }
}

String formatDate(DateTime dateTime) {
  return DateFormat('dd-MM-yyyy').format(dateTime);
}
