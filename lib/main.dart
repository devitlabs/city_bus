import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'google_map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _highPosition;
  Position? _bestPosition;
  Position? _lowPosition;
  Position? _mediumPosition;
  Position? _reducedPosition;
  Position? _lowestPosition;
  Position? _bestForNavigationPosition;

  @override
  void initState() {
    _getCurrentLocations();
    super.initState();
  }

  Future<void> _getCurrentLocations() async {
    await _handlePermission();
    try {
      _highPosition = await _getPosition(LocationAccuracy.high);
      _bestPosition = await _getPosition(LocationAccuracy.best);
      _lowPosition = await _getPosition(LocationAccuracy.low);
      _mediumPosition = await _getPosition(LocationAccuracy.medium);
      _reducedPosition = await _getPosition(LocationAccuracy.reduced);
      _lowestPosition = await _getPosition(LocationAccuracy.lowest);
      _bestForNavigationPosition = await _getPosition(LocationAccuracy.bestForNavigation);

      setState(() {
        // setState to trigger a rebuild with the updated positions
      });
    } catch (e) {
      print(e);
    }
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

  Future<void> _handlePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever. Please enable in settings.');
    }
  }

  void _updateLocations() {
    _getCurrentLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Live Location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildPositionInfo("High Accuracy", _highPosition),
            _buildPositionInfo("Best Accuracy", _bestPosition),
            _buildPositionInfo("Low Accuracy", _lowPosition),
            _buildPositionInfo("Medium Accuracy", _mediumPosition),
            _buildPositionInfo("Reduced Accuracy", _reducedPosition),
            _buildPositionInfo("Lowest Accuracy", _lowestPosition),
            _buildPositionInfo(
                "Best for Navigation Accuracy", _bestForNavigationPosition),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateLocations,
        tooltip: 'Update Locations',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildPositionInfo(String accuracy, Position? position) {
    return InkWell(
      onTap: (){
        if (position != null ) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoogleMapScreen( position: position),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$accuracy:',
              style: TextStyle(fontSize: 20),
            ),
            if (position != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latitude: ${position.latitude.toStringAsFixed(10)}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Longitude: ${position.longitude.toStringAsFixed(10)}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                ],
              )
            else
              Text('Position not available', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}



