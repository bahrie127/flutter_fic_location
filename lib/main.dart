import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geolocation',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange[100],
      ),
      home: const GetUserLocation(title: 'Flutter Geolocation'),
    );
  }
}

class GetUserLocation extends StatefulWidget {
  const GetUserLocation({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<GetUserLocation> createState() => _GetUserLocationState();
}

class _GetUserLocationState extends State<GetUserLocation> {
  LocationData? currentLocation;
  String address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (currentLocation != null)
                Center(
                  child: Text(
                      "Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}"),
                ),
              if (currentLocation != null) Text("Address: $address"),
              MaterialButton(
                onPressed: _getLocation,
                color: Colors.orange,
                child: const Text(
                  "Get Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getLocation() {
    _getLocationData().then((value) {
      LocationData? location = value;
      _getAddress(location?.latitude, location?.longitude).then((value) {
        setState(() {
          currentLocation = location;
          address = value;
        });
      });
    });
  }
}

Future<LocationData?> _getLocationData() async {
  Location location = Location();
  LocationData locationData;

  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  locationData = await location.getLocation();

  return locationData;
}

Future<String> _getAddress(double? lat, double? lang) async {
  if (lat == null || lang == null) return "";

  final address = await geo.placemarkFromCoordinates(lat, lang);
  return "${address[0].street}, ${address[0].subLocality}, ${address[0].locality}, ${address[0].postalCode}";
}
