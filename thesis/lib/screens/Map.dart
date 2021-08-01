import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:thesis/main.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/route_service.dart';
import 'main_drawer.dart';
import 'package:thesis/services/localisation_service.dart';
import 'package:thesis/helpers/helper.dart';
import 'dart:convert';

final LatLngBounds polandBounds = LatLngBounds(
  southwest: const LatLng(53.87076927224154, 14.75693698615063),
  northeast: const LatLng(50.04796881023576, 22.94931924436554),
);

class MapUiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MapUiBody();
  }
}

class MapUiBody extends StatefulWidget {
  const MapUiBody();

  @override
  State<StatefulWidget> createState() => MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  MapUiBodyState();

  double _southWestLatitude = 0.0;
  double _southWestLongitude = 0.0;
  double _northEastLatitude = 0.0;
  double _northEastLongitude = 0.0;

  List<String> _routeIds = <String>[];
  List<RouteModel> _routeModels = <RouteModel>[];
  Symbol? _selectedSymbol;
  RouteModel? _selectedRoute;

  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(52.23172889914352, 21.019465047569224),
    zoom: 12.0,
  );
  LocalisationService _localisationService = LocalisationService.getInstance();
  RouteService _routeService = RouteService.getInstance();

  MapboxMapController? mapController;
  CameraPosition? _position = _kInitialPosition;
  bool _switchValue = false;
  bool _isMoving = false;
  bool _compassEnabled = true;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  int _styleStringIndex = 0;

  bool _isInCreatorMode = false;
  bool _isRouteSelected = false;
  List<LocationModel> _locations = <LocationModel>[];

  // Style string can a reference to a local or remote resources.
  // On Android the raw JSON can also be passed via a styleString, on iOS this is not supported.
  List<String> _styleStrings = [
    MapboxStyles.OUTDOORS,
    MapboxStyles.MAPBOX_STREETS,
    MapboxStyles.SATELLITE
  ];
  List<String> _styleStringLabels = [
    "OUTDOORS"
        "MAPBOX_STREETS",
    "SATELLITE"
  ];
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = false;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  bool _telemetryEnabled = true;
  MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.None;
  List<Object>? _featureQueryFilter;
  Fill? _selectedFill;

  Location location = new Location();

  @override
  void initState() {
    super.initState();

    initLocation().whenComplete(() => {});

    location.onLocationChanged.listen((LocationData currentLocation) {
      _localisationService.addLocationRequest(currentLocation);
    });
  }

  Future<void> initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  void _onMapChanged() async {
    _extractMapInfo();
  }

  void _extractMapInfo() async {}

  void _onMapCameraIdle() async {
    _isMoving = mapController!.isCameraMoving;
    if (_isMoving == false) {
      _extractVisibleRegion();
    }
  }

  Future _extractVisibleRegion() async {
    final visibleRegion = await mapController!.getVisibleRegion();
    print('Visible Region: ${visibleRegion}');

    bool update = false;
    if (visibleRegion.southwest.longitude < _southWestLongitude) {
      update = true;
      _southWestLongitude = visibleRegion.southwest.longitude < -180.0
          ? -180.0
          : visibleRegion.southwest.longitude;
    }

    if (visibleRegion.southwest.latitude < _southWestLatitude) {
      update = true;
      _southWestLatitude = visibleRegion.southwest.latitude < -90.0
          ? -90.0
          : visibleRegion.southwest.latitude;
    }

    if (visibleRegion.northeast.longitude > _northEastLongitude) {
      update = true;
      _northEastLongitude = visibleRegion.northeast.longitude > 180.0
          ? 180.0
          : visibleRegion.northeast.longitude;
    }

    if (visibleRegion.northeast.latitude > _northEastLatitude) {
      update = true;
      _northEastLatitude = visibleRegion.northeast.latitude > 90.0
          ? 90.0
          : visibleRegion.northeast.latitude;
    }

    if (update) {
      var response = await _routeService.getRoutesRequest(
          visibleRegion.southwest,
          visibleRegion.northeast,
          null,
          null,
          true,
          1);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var isNotEmpty = jsonResponse['isNotEmpty'];
        if (isNotEmpty) {
          var items = jsonResponse['items'];
          var pages = jsonResponse['totalPages'];
          var totalPages = jsonResponse['totalPages'];

          items.forEach((route) => displayRoute(route));
        }
      }
    }
  }

  Future displayRoute(dynamic route) async {
    var _routeId = route['id'];
    if (_routeIds.contains(_routeId)) {
      return;
    }
    var _difficulty = route['difficulty'].toString().toLowerCase();
    var _points = route['points'];

    displayPoints(_points[0], _difficulty);

    for (var i = 1; i < _points.length; i++) {
      await displayLine(_points[i - 1], _points[i], _difficulty);
    }
    _routeIds.add(_routeId);
    _routeModels.add(new RouteModel.fromJson(route));
  }

  Future displayPoints(dynamic point, String _difficulty) async {
    var _latitude = point['latitude'];
    var _longitude = point['longitude'];
    var _geometry = new LatLng(_latitude, _longitude);

    await mapController!.addSymbol(SymbolOptions(
        geometry: _geometry,
        iconImage: 'marker-${_difficulty}',
        iconAnchor: "bottom",
        iconSize: 1.4));
  }

  Future displayLine(
      dynamic previusPoint, dynamic point, String _difficulty) async {
    var _previusLatitude = previusPoint['latitude'];
    var _previusLongitude = previusPoint['longitude'];
    var _previusGeometry = new LatLng(_previusLatitude, _previusLongitude);

    var _latitude = point['latitude'];
    var _longitude = point['longitude'];
    var _geometry = new LatLng(_latitude, _longitude);

    var color = "#ff0000";
    switch (_difficulty) {
      case 'green':
        color = "#00ff00";
        break;
      case 'blue':
        color = '#0000ff';
        break;
      case 'red':
        color = '#ff0000';
        break;
      case 'black':
        color = '#ffffff';
        break;
    }
    await mapController!.addLine(LineOptions(
        geometry: [_previusGeometry, _geometry],
        lineColor: color,
        lineWidth: 6.0,
        lineOpacity: 0.5));
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.4),
      );
    }
    if (_selectedSymbol == symbol) {
      setState(() {
        setSelectedRoute(null);
        _selectedSymbol = null;
        _updateSelectedSymbol(const SymbolOptions(iconSize: 1.4));
      });
      return;
    }
    setState(() {
      _selectedSymbol = symbol;
      _updateSelectedSymbol(
        SymbolOptions(
          iconSize: 1.7,
        ),
      );
    });

    var geometry = _selectedSymbol!.options.geometry;
    var result = _routeModels
        .where((route) =>
            route.points[0].latitude == geometry.latitude &&
            route.points[0].longitude == geometry.longitude)
        .single;
    if (result == null) {
      Helper.toastFailShort("Nie znaleziono trasy.");
      return;
    }
    setState(() {
      setSelectedRoute(result);
    });
  }

  void _updateSelectedSymbol(SymbolOptions changes) {
    mapController!.updateSymbol(_selectedSymbol!, changes);
  }

  @override
  void dispose() {
    mapController?.removeListener(_onMapChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MapboxMap mapboxMap = MapboxMap(
      accessToken: Application.ACCESS_TOKEN,
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      trackCameraPosition: true,
      compassEnabled: _compassEnabled,
      cameraTargetBounds: _cameraTargetBounds,
      minMaxZoomPreference: _minMaxZoomPreference,
      styleString: 'mapbox://styles/mpd97/ckrs8eh4l148w17o2ply5voho',
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      tiltGesturesEnabled: _tiltGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      myLocationEnabled: _myLocationEnabled,
      myLocationTrackingMode: _myLocationTrackingMode,
      myLocationRenderMode: MyLocationRenderMode.NORMAL,
      onCameraIdle: _onMapCameraIdle,
      onMapClick: (point, latLng) async {
        print(
            "Map click: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
        print("Filter $_featureQueryFilter");
      },
      onMapLongClick: (point, latLng) async {
        if (_isInCreatorMode) {
          var locationCount = _locations.length;
          var location = new LocationModel(
              latLng.latitude, latLng.longitude, 15, locationCount);
          if (_locations.length > 0) {
            var previus = _locations[locationCount - 1];
            var distance = calculateDistance(previus.Latitude,
                    previus.Longitude, latLng.latitude, latLng.longitude)
                .toInt();
            print("Distance: $distance");
            if (distance > 500) {
              Helper.toastFailShort("Zbyt duży dystans między puntami.");
              return;
            }

            if (distance < 100) {
              Helper.toastFailShort("Zbyt mały dystans między puntami.");
              return;
            }
            addLocation(location, latLng);
            mapController!.addLine(LineOptions(
                geometry: [LatLng(previus.Latitude, previus.Longitude), latLng],
                lineColor: "#ff0000",
                lineWidth: 10.0,
                lineOpacity: 0.5));
          } else {
            addLocation(location, latLng);
          }
        }
      },
      onCameraTrackingDismissed: () {
        this.setState(() {
          _myLocationTrackingMode = MyLocationTrackingMode.None;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
      ),
      drawer: MainDrawer(),
      body: mapboxMap,
      floatingActionButton: AuthService.userIsAuthorized == true
          ? _isInCreatorMode == false
              ? _isRouteSelected == true
                  ? Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton.extended(
                            onPressed: () {

                            },
                            label: const Text('Rozpocznij'),
                            icon: const Icon(Icons.arrow_forward),
                            backgroundColor: Colors.green,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/route/details', arguments: _selectedRoute);
                              },
                              label: const Text('Szczególy trasy'),
                              icon: const Icon(Icons.details),
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    )
                  : FloatingActionButton.extended(
                      onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Dodawanie nowej trasy'),
                                content: const Text(
                                    'Wybierz kolejno kilka punktów na mapie przytrzymując dłużej palec, a następnie naciśnij zapisz.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'anuluj'),
                                    child: const Text('anuluj'),
                                  ),
                                  TextButton(
                                    onPressed: () => {onCreateRoute()},
                                    child: const Text('OK'),
                                  ),
                                ],
                              )),
                      label: const Text('Dodaj'),
                      icon: const Icon(Icons.add),
                      backgroundColor: Colors.green,
                    )
              : Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          if (_locations.length < 4) {
                            Helper.toastFail(
                                "Wymagane są co najmniej 4 punkty");
                            return;
                          }
                          if (_locations.length > 50) {
                            Helper.toastFail(
                                "przekroczona została maksymalną ilośc punktów");
                            return;
                          }
                          Navigator.of(context)
                              .pushNamed('/route/add', arguments: _locations);
                        },
                        label: const Text('Zapisz'),
                        icon: const Icon(Icons.save),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            onCreateRouteCancelled();
                          },
                          label: const Text('Anuluj'),
                          icon: const Icon(Icons.cancel),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                )
          : FloatingActionButton.extended(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                Navigator.of(context).pushNamed('/login');
              },
              label: const Text('Zaloguj się'),
              icon: const Icon(Icons.login),
              backgroundColor: Colors.amber,
            ),
    );
  }

  void addLocation(LocationModel location, LatLng current) {
    _locations.add(location);
    mapController!.addSymbol(SymbolOptions(
        geometry: current, iconImage: "rating-v2", iconAnchor: "bottom"));
    Helper.toastSuccessShort("Dodano punkt #${_locations.length}");
  }

  void setSelectedRoute(RouteModel? model) {
    _selectedRoute = model;
    onRouteSelected();
  }

  void onRouteSelected() {
    setState(() {
      if (_selectedRoute == null) {
        _isRouteSelected = false;
        return;
      }
      _isRouteSelected = true;
    });
    print("Route selected: ${_isRouteSelected}");
  }

  void onCreateRoute() {
    Navigator.pop(context, 'OK');
    setState(() {
      _isInCreatorMode = true;
      _locations.clear();
    });
  }

  void onCreateRouteCancelled() {
    setState(() {
      _isInCreatorMode = false;
      _locations.clear();
      mapController!.removeSymbols(mapController!.symbols);
      mapController!.removeLines(mapController!.lines);
    });
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController!.addListener(_onMapChanged);
    _extractVisibleRegion();
    _extractMapInfo();

    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a));
  }
}
