import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final mapController = MapController();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Map Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(51.509364, -0.128928),
              zoom: 3.2,
            ),
            children: [
              TileLayer(
                // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OpenStreetMap
                // urlTemplate: 'https://stamen-tiles.a.ssl.fastly.net/toner-background/{z}/{x}/{y}.png',
                // urlTemplate: 'https://stamen-tiles.a.ssl.fastly.net/terrain/{z}/{x}/{y}.png',

                urlTemplate: 'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // OpenCycleMap
                // urlTemplate: 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Transport
                // urlTemplate: 'https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Landscape
                // urlTemplate: 'https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Outdoors
                // urlTemplate: 'https://tile.thunderforest.com/transport-dark//{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Transport-dark
                // urlTemplate: 'https://tile.thunderforest.com/spinal-map/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Spinal-map
                // urlTemplate: 'https://tile.thunderforest.com/pioneer/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Pioneer
                // urlTemplate: 'https://tile.thunderforest.com/mobile-atlas/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Mobile-atlas
                // urlTemplate: 'https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Neighbourhood
                // urlTemplate: 'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=c1522771387c4170a55beb3ecaaabf61', // Atlas

                // userAgentPackageName: 'com.example.app',
              ),
              PolygonLayer(
                polygonCulling: false,
                polygons: [
                  Polygon(
                      points: [
                        LatLng(36.95, -9.5),
                        LatLng(42.25, -9.5),
                        LatLng(42.25, -6.2),
                        LatLng(36.95, -6.2),
                      ],
                      color: Colors.blue.withOpacity(0.2),
                      borderStrokeWidth: 1,
                      borderColor: Colors.blue,
                      isFilled: true),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      LatLng(38.73, -9.14), // Lisbon, Portugal
                      LatLng(51.50, -0.12), // London, United Kingdom
                      LatLng(52.37, 4.90), // Amsterdam, Netherlands
                    ],
                    color: Colors.green,
                    strokeWidth: 2,
                  ),
                ],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(52.2677, 5.1689), // center of 't Gooi
                    radius: 5000,
                    useRadiusInMeter: true,
                    color: Colors.red.withOpacity(0.3),
                    borderColor: Colors.red.withOpacity(0.7),
                    borderStrokeWidth: 2,
                  )
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(51.509364, -0.128928),
                    width: 80,
                    height: 80,
                    builder: (context) => const Icon(
                      Icons.location_on_outlined,
                      color: Colors.pink,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Locate',
        child: Icon(Icons.my_location_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
