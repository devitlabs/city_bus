import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Completer<GoogleMapController> _googleMapController  = Completer<GoogleMapController>();
  double zoom = 18 ;
  PositionGeo pointA = PositionGeo(5.285230, -3.979946);
  double latitude = 0;
  double longitude = 0;
  PositionGeo pointB = PositionGeo(5.303519, -4.000889);
  CameraPosition? _cameraPosition;
  var avatar = BitmapDescriptor.defaultMarker;
  int increment = 0 ;
  bool start  = false;
  List<PositionGeo> positions = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBar(
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
        },
      ),
      floatingActionButton: Stack(
        children: [
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
    mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: latLng,
                zoom: zoom
            )
        )
    );
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
