import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: 'nl815fqtrf');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Flutter App'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ImageTab(),
          ChartTab(),
          MapTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Image'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: 'Chart'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}

class MapTab extends StatelessWidget {
  final marker = NMarker(
      id: 'netropy', position: NLatLng(37.479325875153, 126.95266251463));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
              target: NLatLng(37.479325875153, 126.95266251463),
              zoom: 15,
              bearing: 0,
              tilt: 0),
        ),
        onMapReady: (controller) {
          controller.addOverlay(marker);
        },
      ),
    );
  }
}

class ImageTab extends StatefulWidget {
  @override
  _ImageTabState createState() => _ImageTabState();
}

class _ImageTabState extends State<ImageTab> {
  PickedFile? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getRandomImage() async {
    var status = await Permission.photos.request();
    
    if (status.isGranted) {
      // Permission granted: proceed to pick an image
      final pickedFile = await _picker.getImage(source: ImageSource.gallery);
      setState(() {
        _image = pickedFile;
      });
    } else if (status.isPermanentlyDenied) {
      // If permanently denied, guide user to settings
      await openAppSettings();
    } else {
      // Permission denied scenario
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Permission Denied"),
          content: Text("Photo access permission is required to pick images."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image == null
              ? Text('No image selected.')
              : Image.file(File(_image!.path)),
              SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _getRandomImage,
            child: Text('Select Photo from library'),
          ),
        ],
      ),
    );
  }
}

class ChartTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: _generateRandomData(),
          minX: 0,
          maxX: 10,
          minY: 0,
          maxY: 10,
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }

  List<ScatterSpot> _generateRandomData() {
    final random = Random();
    return List.generate(20, (index) {
      return ScatterSpot(
        random.nextDouble() * 10,
        random.nextDouble() * 10,
      );
    });
  }
}
