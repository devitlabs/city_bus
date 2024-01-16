import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import "package:universal_html/html.dart" as html;


class GoogleMapScreen extends StatefulWidget {
  final Position position;
  const GoogleMapScreen({ Key? key, required this.position }) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {

  final Completer<GoogleMapController> _googleMapController  = Completer<GoogleMapController>();
  double zoom = 18 ;
  PositionGeo pointA = PositionGeo(5.285230, -3.979946);
  double latitude = 0;
  double longitude = 0;

  double currentLatitude = 0;
  double currentLongitude = 0;

  PositionGeo pointB = PositionGeo(5.303519, -4.000889);
  CameraPosition? _cameraPosition;
  var avatar = BitmapDescriptor.defaultMarker;
  int increment = 0 ;
  bool start  = false;
  bool track  = false;
  List<PositionGeo> positions = [];
  List<List<dynamic>> _csvData = [];
  StreamSubscription<Position>? _locationStream;


  @override
  void dispose() {
    super.dispose();
  }

  Future<Position?> _getPosition(LocationAccuracy accuracy) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e) {
      print("Error obtaining position with accuracy $accuracy: $e");
      return null;
    }
  }

  Future<void> _startTracking() async {
    _locationStream = Geolocator.getPositionStream(locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    )).listen((Position position) async {
      if (track) {
        await _addData(position);
        setState(() {
          currentLatitude = position.latitude;
          currentLongitude = position.latitude;
        });
        await moveToPosition(latLng: LatLng(currentLatitude, currentLongitude));
      }
    });
  }

  Future<void> _stopTracking() async {
    _locationStream?.cancel();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    currentLatitude = widget.position.latitude;
    currentLongitude = widget.position.longitude;
    await setCustomMarker();
    int numPositions = 1000;

    List<PositionGeo> resultPositions = generatePositions(pointA, pointB, numPositions);
    positions = resultPositions;

    latitude = pointA.latitude;
    longitude =  pointA.longitude;


    _cameraPosition = CameraPosition(
        target: LatLng(latitude, longitude), // this is just the example lat and lng for initializing
        zoom: zoom
    );
  }

  Future<void> _addData(Position position) async {
    final csvRow = [position.latitude, position.longitude, DateTime.now().toString()];
    _csvData.add(csvRow);
  }

  Future<void> _downloadCSV() async {
    final csvString = ListToCsvConverter().convert(_csvData);

    final directory = "/storage/emulated/0/Documents";
    final date = DateTime.now();
    final fileName = "locationcsv-${date.year}${date.month}${date.day}-${date.hour}H${date.minute}.csv";
    String filePath = '$directory/$fileName';

    File file = File(filePath);
    await file.writeAsString(csvString);

    _csvData = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Zoom ${ zoom != null ? zoom?.toStringAsFixed(2) : ""} Incr : ${increment} Total ${positions.length}",
          style: TextStyle(fontSize: 18),),
        ),
      ),
      body: _cameraPosition == null ? const Center(
        child: CircularProgressIndicator(),
      ) :  GoogleMap(
        mapType: MapType.normal,
        onCameraMove: (CameraPosition cameraPosition) {
          setState(() {
            zoom = cameraPosition.zoom;
          });
        },
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        initialCameraPosition: _cameraPosition!,
        onMapCreated: (GoogleMapController controller) {
          _googleMapController .complete(controller);
        },
        markers: {
          Marker(
            markerId: MarkerId('BUS 1'),
            position: LatLng(
              latitude,
              longitude,
            ),
            icon: avatar,
            infoWindow: const InfoWindow(
              title: 'BUS 1',
            ),
          ),
          Marker(
            markerId: MarkerId("Fabrice"),
            position: LatLng(
              currentLatitude,
              currentLongitude,
            ),
            icon: avatar,
            infoWindow: const InfoWindow(
              title: 'Fabrice',
            ),
          ),
        },
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 16.0,
            bottom: 100.0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                backgroundColor: start ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                onPressed: () async {
                  final currentLocation = await _getPosition(LocationAccuracy.high);
                  if (currentLocation != null ) {
                    moveToPosition(latLng: LatLng(currentLocation.latitude, currentLocation.longitude));
                  }

                },
                child: Icon(Icons.home),
              ),
            ),
          ),
          Positioned(
            left: 16.0,
            bottom: 16.0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                backgroundColor: start ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                onPressed: () async {
                  setState(() {
                    if (start ) {
                      start = false;
                    }else {
                      start = true;
                    }
                  });

                  while ( start && increment < 1000) {

                    setState(() {
                      latitude = positions[increment].latitude;
                      longitude =  positions[increment].longitude;
                    });

                    _cameraPosition = await CameraPosition(
                        target: LatLng(latitude, longitude), // this is just the example lat and lng for initializing
                        zoom: zoom
                    );

                    await Future.delayed(const Duration(milliseconds: 100));

                    setState(() {
                      increment = increment +1;
                    });

                    await Future.delayed(Duration(milliseconds: 400));
                  }

                },
                child: Icon( start ? Icons.pause : Icons.play_arrow),
              ),
            ),
          ),
          Positioned(
            left: 16.0,
            bottom: 170.0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                backgroundColor: track ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                onPressed: () async {

                  setState(() {
                    track = !track;
                  });

                  if (track) {
                    await _startTracking();
                  } else {
                    await _stopTracking();
                    print(_csvData);
                    await _downloadCSV();
                    await Future.delayed(Duration(seconds: 2));
                  }

                },
                child: Icon(Icons.location_on),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future setCustomMarker() async {
    final marker = await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/location.png");
    setState(() {
      avatar = marker;
    });
  }


  Future moveToPosition({required LatLng latLng}) async {
    GoogleMapController mapController = await _googleMapController.future;
    setState(() {
      mapController.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: latLng,
                  zoom: zoom
              )
          )
      );
    });
  }


  Widget _getMarker() {
    return Container(
      width: 20,
      height: 20,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
                color: Colors.grey,
                offset: Offset(0,3),
                spreadRadius: 4,
                blurRadius: 6
            )
          ]
      ),
      child:  ClipOval(child: Image.asset("assets/profile.jpg")),
    );
  }

}
