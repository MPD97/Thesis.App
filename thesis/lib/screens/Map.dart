import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'main_drawer.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Mapa"),
        ),
        drawer: MainDrawer(),
        body: FlutterMap(
          options: MapOptions(
            center: LatLng(51.5, -0.09),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
                urlTemplate: "https://api.mapbox.com/styles/v1/mpd97/ckron763a3v0319o13q3dzpx9/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibXBkOTciLCJhIjoiY2twNzdheDNiMTM5bTJvczFvb3FvMDZjciJ9.SsZFQE9EsGcgE5l8_etrlw",
                additionalOptions: {
                  "accessToken": "pk.eyJ1IjoibXBkOTciLCJhIjoiY2twNzdheDNiMTM5bTJvczFvb3FvMDZjciJ9.SsZFQE9EsGcgE5l8_etrlw",
                  "id": "mapbox.mapbox-terrain-v2"
                }
            ),
            /*MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: latLng.LatLng(51.5, -0.09),
                builder: (ctx) =>
                    Container(
                      child: FlutterLogo(),
                    ),
              ),
            ],
          ),*/
          ],
        )
    );
  }
}
