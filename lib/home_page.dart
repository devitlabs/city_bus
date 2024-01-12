import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Completer<GoogleMapController> _googleMapController  =
  Completer<GoogleMapController>();
  Location? _location;
  LocationData? _currentLocation;
  double zoom = 15 ;
  double latitude = 5.358343 ;
  double longitude =  -4.027523 ;
  CameraPosition? _cameraPosition;
  var avatar = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    await setCustomMarker();
    _location = Location();
    setState(() {
      _cameraPosition = CameraPosition(
          target: const LatLng(5.358343, -4.027523), // this is just the example lat and lng for initializing
          zoom: zoom
      );
    });
    _initLocation();
  }

  _initLocation() {
    //use this to go to current location instead
    _location?.getLocation().then((location) {
      _currentLocation = location;
    });
    _location?.onLocationChanged.listen((newLocation) {
      _currentLocation = newLocation;
      double? Klongitude = _currentLocation?.longitude;
      double? Klatitude = _currentLocation?.latitude;
      if (Klatitude != null && Klongitude != null) {
        setState(() {
          latitude = Klatitude;
          longitude = Klongitude;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBar(
          title: Text("Map Zoom ${ zoom != null ? zoom?.toStringAsFixed(2) : ""}"),
          actions: [
            IconButton(onPressed: (){
              _location?.getLocation().then((location) {
                setState(() {
                  _currentLocation = location;
                });
              });
              double? late = _currentLocation?.latitude ;
              double? long = _currentLocation?.longitude ;
              if (late != null && long != null) {
                moveToPosition(latLng: LatLng(late,long));
              }
            }, icon:  const Icon(Icons.home)
            ),
            IconButton(onPressed: () async{
              GoogleMapController mapController = await _googleMapController.future;
              double kZoom = await mapController.getZoomLevel();
              setState(() {
                zoom = kZoom;
              });
            }, icon:  const Icon(Icons.zoom_in_map)
            )
          ],
        ),
      ),
      body: _cameraPosition == null ? const Center(
        child: CircularProgressIndicator(),
      ) :  Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            onCameraMove: (CameraPosition cameraPosition) {
              setState(() {
                zoom = cameraPosition.zoom;
              });
            },
            initialCameraPosition: _cameraPosition!,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController .complete(controller);
            },
            markers: {
              Marker(
                markerId: MarkerId('myMarker'),
                position: LatLng(
                  latitude,
                  longitude,
                ),
                icon: avatar,
                infoWindow: const InfoWindow(
                  title: 'Ma Position',
                ),
              ),
            },
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


  void moveToPosition({required LatLng latLng}) async {
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
