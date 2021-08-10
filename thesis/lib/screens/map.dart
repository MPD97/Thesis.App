import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/main.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/models/PagedRouteModel.dart';
import 'package:thesis/models/PointModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/localisation_service.dart';
import 'package:thesis/services/route_service.dart';
import 'package:thesis/services/run_service.dart';

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

  final List<String> _drawedRoutes = <String>[];
  final List<RouteModel> _routeModels = <RouteModel>[];
  Symbol? _selectedSymbol;
  RouteModel? _selectedRoute;

  bool _mapInitalized = false;
  bool _isPreparingRunGettingLocation = false;
  bool _isPreparingRun = false;
  bool _isInRun = false;
  bool _cameraTracking = false;

  LocationData? _currentLocation;
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(52.23172889914352, 21.019465047569224),
    zoom: 12.0,
  );

  final LocalisationService _localisationService =
  LocalisationService.getInstance();
  final RouteService _routeService = RouteService.getInstance();
  final AuthService _authService = AuthService.getInstance();
  final RunService _runService = RunService.getInstance();

  late MapboxMapController mapController;
  bool _isMoving = false;
  final bool _compassEnabled = true;
  final CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  final MinMaxZoomPreference _minMaxZoomPreference =
      MinMaxZoomPreference.unbounded;

  bool _isInCreatorMode = false;
  bool _isRouteSelected = false;
  final List<LocationModel> _locations = <LocationModel>[];

  final bool _rotateGesturesEnabled = true;
  final bool _scrollGesturesEnabled = true;
  final bool _tiltGesturesEnabled = false;
  final bool _zoomGesturesEnabled = true;
  final bool _myLocationEnabled = true;

  final MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.None;
  HubConnection? hubConnection;

  final Location _location = Location();

  @override
  void initState() {
    initLocation().whenComplete(() => {});
    _location.onLocationChanged.listen((LocationData currentLocation) {
      _localisationService.addLocationRequest(currentLocation);
    });
    super.initState();
  }

  Future initSignalR() async {
    const _serverUrl = "http://thesisapi.ddns.net/hub";
    hubConnection = HubConnectionBuilder().withUrl(_serverUrl).build();
    hubConnection!.on("connected", _handleResponseConnected);
    hubConnection!.on("operation_completed", _handleResponseCompleted);
    hubConnection!.onclose(_handleResponseOnClose);

    await hubConnection!.start();
    print("AccessToken: ${AuthService.accessToken}");
    await hubConnection!
        .invoke("initializeAsync", args: <Object>[AuthService.accessToken!]);
  }

  Future _handleResponseCompleted(List<dynamic>? parameters) async {
    if (parameters == null) {
      Helper.toastFail("Coś poszło nie tak");
      return;
    }
    print("HandleResponse: $parameters");
    var _json = json.decode(json.encode(parameters[0]));
    if (_json['name'] == 'POST /locations') {
      if (_json['data']['pointId'] != null) {
        final _pointId = _json['data']['pointId'];
        for (int i = 0; i < _selectedRoute!.points.length; i++) {
          if (_selectedRoute!.points[i].id == _pointId) {
            drawCircleRunCompleted(_selectedRoute!.points[i]);
            if (i + 1 < _selectedRoute!.points.length) {
              drawCircleRunNext(_selectedRoute!.points[i + 1]);
            }
            Helper.toastSuccess("Zaliczono punkt");
            return;
          }
        }
      } else if (_json['data']['runId'] != null &&
          _json['data']['userId'] != null &&
          _json['data']['routeId'] != null) {
        onRunCompleted();
        onRunPreparingCancelled();
      }
    }
  }

  void _handleResponseConnected(List<dynamic>? parameters) {
    if (parameters == null) {
      Helper.toastFail("Coś poszło nie tak");
      return;
    }
    Helper.toastSuccessShort("Nawiązano połączenie");
  }

  void _handleResponseOnClose(Exception? error) {
    if (error == null) {
      Helper.toastFail("Coś poszło nie tak");
      return;
    }
    Helper.toastFailShort("Utracono połączenie");
  }

  Future<void> initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    await _location.getLocation();
  }

  void _onMapChanged() async {
    _extractMapInfo();
  }

  void _extractMapInfo() async {}

  void _onMapCameraIdle() async {
    if (_mapInitalized) {
      _isMoving = mapController.isCameraMoving;
      if (_isMoving == false) {
        _extractVisibleRegion();
      }
    }
  }

  Future _extractVisibleRegion() async {
    if (_isPreparingRun || _isPreparingRunGettingLocation) {
      return;
    }
    final visibleRegion = await mapController.getVisibleRegion();
    print('Visible Region: $visibleRegion');

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
      var _totalPages = 1;
      var _currentPage = 0;

      while (_currentPage < _totalPages) {
        var _response = await getRoutes(visibleRegion, _currentPage++);
        print("Current page: $_currentPage Total pages: $_totalPages");
        if (_response.statusCode == 200) {
          PagedRouteModel _pagedResult =
          PagedRouteModel.fromJson(json.decode(_response.body));
          if (_pagedResult.isNotEmpty) {
            for (var route in _pagedResult.items) {
              addRoute(route);
            }
          }
          _totalPages = _pagedResult.totalPages;
          await drawRoutes();
        }
      }
    }
  }

  Future<Response> getRoutes(LatLngBounds visibleRegion, int page) async {
    return await _routeService.getRoutesRequest(visibleRegion.southwest,
        visibleRegion.northeast, null, null, true, page);
  }

  Future addRoute(RouteModel route) async {
    if (_routeModels.where((r) => r.id == route.id).isNotEmpty) {
      return;
    }
    _routeModels.add(route);
  }

  Future drawRoutes() async {
    for (final route in _routeModels) {
      await drawRoute(route);
    }
  }

  Future drawRoute(RouteModel route) async {
    if (_drawedRoutes.where((r) => r == route.id).isNotEmpty) {
      return;
    }
    var _difficulty = route.difficulty.toString().toLowerCase();
    drawPoint(route.points[0], _difficulty);

    for (var i = 1; i < route.points.length; i++) {
      await drawLine(route.points[i - 1], route.points[i], _difficulty);
    }
    _drawedRoutes.add(route.id);
  }

  Future drawRouteRun(RouteModel route) async {
    var _difficulty = route.difficulty.toString().toLowerCase();
    drawCircleRunNext(route.points[0]);

    for (var i = 1; i < route.points.length; i++) {
      drawCircleRun(route.points[i]);
      await drawLineRun(route.points[i - 1], route.points[i], _difficulty);
    }
  }

  Future drawCircleRunNext(PointModel point) async {
    var _geometry = LatLng(point.latitude, point.longitude);
    await mapController.addCircle(CircleOptions(
        geometry: _geometry,
        circleColor: "#0000FF",
        circleOpacity: 0.9,
        circleRadius: 8));
  }

  Future drawCircleRun(PointModel point) async {
    var _geometry = LatLng(point.latitude, point.longitude);
    await mapController.addCircle(CircleOptions(
        geometry: _geometry,
        circleColor: "#808080",
        circleOpacity: 0.9,
        circleRadius: 6));
  }

  Future drawCircleRunCompleted(PointModel point) async {
    var _geometry = LatLng(point.latitude, point.longitude);
    await mapController.addCircle(CircleOptions(
        geometry: _geometry,
        circleColor: "#00FF00",
        circleOpacity: 0.9,
        circleRadius: 8));
  }

  Future drawLineRun(
      PointModel previousPoint, PointModel point, String difficulty) async {
    var _previousGeometry =
    LatLng(previousPoint.latitude, previousPoint.longitude);
    var _geometry = LatLng(point.latitude, point.longitude);

    var color = "#ff0000";
    switch (difficulty) {
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
        color = '#000000';
        break;
    }

    await mapController.addLine(LineOptions(
        geometry: [_previousGeometry, _geometry],
        lineColor: color,
        lineJoin: "round",
        lineWidth: 2.5,
        lineOpacity: 0.5));
  }

  Future drawPoint(PointModel point, String difficulty) async {
    var _geometry = LatLng(point.latitude, point.longitude);
    await mapController.addSymbol(SymbolOptions(
        geometry: _geometry,
        iconImage: 'marker-${difficulty}',
        iconAnchor: "bottom",
        iconSize: 1.4));
  }

  Future drawLine(
      PointModel previousPoint, PointModel point, String _difficulty) async {
    var _previousGeometry =
    LatLng(previousPoint.latitude, previousPoint.longitude);
    var _geometry = LatLng(point.latitude, point.longitude);

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
        color = '#000000';
        break;
    }
    await mapController.addLine(LineOptions(
        geometry: [_previousGeometry, _geometry],
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
        const SymbolOptions(
          iconSize: 1.7,
        ),
      );
    });

    var geometry = _selectedSymbol!.options.geometry;
    var result = _routeModels
        .where((route) =>
    route.points[0].latitude == geometry!.latitude &&
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
    mapController.updateSymbol(_selectedSymbol!, changes);
  }

  @override
  void dispose() {
    mapController.removeListener(_onMapChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MapboxMap mapboxMap = MapboxMap(
      accessToken: Application.ACCESS_TOKEN,
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      trackCameraPosition: false,
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
      onMapLongClick: (point, latLng) async {
        if (_isInCreatorMode) {
          var locationCount = _locations.length;
          var location = LocationModel(
              latLng.latitude, latLng.longitude, 15, locationCount);
          if (_locations.isNotEmpty) {
            var prevoius = _locations[locationCount - 1];
            var distance = calculateDistance(prevoius.Latitude,
                prevoius.Longitude, latLng.latitude, latLng.longitude)
                .toInt();
            print("Distance: $distance");
            if (distance > 500) {
              Helper.toastFailShort("Zbyt duży dystans między puntami");
              return;
            }

            if (distance < 100) {
              Helper.toastFailShort("Zbyt mały dystans między puntami");
              return;
            }
            addLocation(location, latLng);
            mapController.addLine(LineOptions(geometry: [
              LatLng(prevoius.Latitude, prevoius.Longitude),
              latLng
            ], lineColor: "#ff0000", lineWidth: 10.0, lineOpacity: 0.5));
          } else {
            addLocation(location, latLng);
          }
        }
      },
      onCameraTrackingDismissed: () {
        setState(() {
          disableMapTracking();
        });
      },
    );

    Stack onRouteMarkerClickSection() {
      return Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                setState(() {
                  prepareRun();
                });
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
                heroTag: null,
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/route/details', arguments: _selectedRoute);
                },
                label: const Text('Szczególy'),
                icon: const Icon(Icons.details),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      );
    }

    Stack onRouteRunPreparingSection() {
      return Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                onRunStart();
              },
              label: const Text('Start'),
              icon: const Icon(Icons.play_circle_fill),
              backgroundColor: Colors.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {
                  onRunPreparingCancelled();
                },
                label: const Text('Powrtót'),
                icon: const Icon(Icons.arrow_back),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      );
    }

    Stack onRouteRunPreparingGettingLocationSection() {
      return Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {},
                label: const Text('Trwa pobieranie aktualnej lokalizacji'),
                icon: const Icon(Icons.gps_not_fixed),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      );
    }

    FloatingActionButton onRouteAddNewSection() {
      return FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Dodawanie nowej trasy'),
              content: const Text(
                  'Wybierz kolejno kilka punktów na mapie przytrzymując dłużej palec, a następnie naciśnij zapisz'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'anuluj'),
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
      );
    }

    Stack onRouteAddNewSaveSection() {
      return Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                if (_locations.length < 4) {
                  Helper.toastFail("Wymagane są co najmniej 4 punkty");
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
                heroTag: null,
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
      );
    }

    Stack onInRun() {
      return Stack(
        children: <Widget>[
          _cameraTracking == false
              ? Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                enableMapTracking();
              },
              label: const Text('Wznów'),
              icon: const Icon(Icons.assistant_navigation),
              backgroundColor: Colors.blue,
            ),
          )
              : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {
                  onRunCancelled();
                },
                label: const Text('Anuluj'),
                icon: const Icon(Icons.cancel),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      );
    }

    FloatingActionButton onNotLoggedIn() {
      return FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.of(context).pushNamed('/login');
        },
        label: const Text('Zaloguj się'),
        icon: const Icon(Icons.login),
        backgroundColor: Colors.amber,
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Mapa"),
        ),
        body: mapboxMap,
        floatingActionButton: AuthService.userIsAuthorized == true
            ? _isInCreatorMode == true
            ? onRouteAddNewSaveSection()
            : _isRouteSelected == true
            ? _isPreparingRunGettingLocation == true
            ? onRouteRunPreparingGettingLocationSection()
            : _isPreparingRun == true
            ? _isInRun == true
            ? onInRun()
            : onRouteRunPreparingSection()
            : onRouteMarkerClickSection()
            : onRouteAddNewSection()
            : onNotLoggedIn());
  }
  Future<bool> validateUserDistance() async {
    _currentLocation = await _location.getLocation();
    var distance = calculateDistance(
        _selectedRoute?.points[0].latitude,
        _selectedRoute?.points[0].longitude,
        _currentLocation!.latitude,
        _currentLocation!.longitude);

    if (distance > 250) {
      return false;
    }
    return true;
  }

  Future prepareRun() async {
    setState(() => {_isPreparingRunGettingLocation = true});

    bool isUserInGoodDistance = await validateUserDistance();

    setState(() => {_isPreparingRunGettingLocation = false});

    if (isUserInGoodDistance) {
      setState(() => {_isPreparingRun = true});
      await removeSymbolsLinesCircles();
      await drawRouteRun(_selectedRoute!);

      if (hubConnection == null) {
        initSignalR();
      }
    } else {
      Helper.toastFailShort("Jesteś za daleko");
      setState(() => {_isPreparingRun = false});
      return;
    }
  }

  Future onRunStart() async {
    if (_currentLocation == null) {
      print("_currentLocation: NULL");
      return;
    }
    if (_selectedRoute == null) {
      print("_selectedRoute: NULL");
      return;
    }

    final _response =
    await _runService.addRunRequest(_currentLocation!, _selectedRoute!.id);
    if (_response == null) {
      print("_response: NULL");
      return;
    }

    if (_response.statusCode == 201) {
      enableMapTracking();
      setState(() {
        _isInRun = true;
      });
      LocalisationService.setLocation(true);
      Helper.toastSuccess("Rozpoczęto wyścig!");
    }
  }

  enableMapTracking() {
    mapController.animateCamera(CameraUpdate.zoomTo(16));
    Future.delayed(const Duration(milliseconds: 300), () {
      mapController
          .updateMyLocationTrackingMode(MyLocationTrackingMode.TrackingCompass);
    });
    setState(() {
      _cameraTracking = true;
    });
  }

  disableMapTracking() {
    mapController.animateCamera(CameraUpdate.zoomTo(13));
    Future.delayed(const Duration(milliseconds: 300), () {
      mapController.updateMyLocationTrackingMode(MyLocationTrackingMode.None);
    });

    setState(() {
      _cameraTracking = false;
    });
  }

  onRunCompleted() {
    setState(() {
      _isInRun = false;
      _selectedRoute = null;
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.4),
      );
      _selectedSymbol = null;
    });
    LocalisationService.setLocation(false);
    disableMapTracking();
    Helper.toastSuccess("Ukończono wyścig");
  }

  onRunCancelled() {
    setState(() {
      _isInRun = false;
    });
    LocalisationService.setLocation(false);
    disableMapTracking();
    Helper.toastFailShort("Anulowano wyścig");
  }

  void addLocation(LocationModel location, LatLng current) {
    _locations.add(location);
    mapController.addSymbol(SymbolOptions(
        geometry: current, iconImage: "rating-v2", iconAnchor: "bottom"));
    Helper.toastSuccessShort("Dodano punkt #${_locations.length}");
  }

  void setSelectedRoute(RouteModel? model) {
    _selectedRoute = model;
    onRouteSelected();
  }

  void onRouteSelected() {
    if (_isPreparingRun || _isPreparingRunGettingLocation) {
      print("Cannot select route when in run preparing");
      return;
    }

    setState(() {
      if (_selectedRoute == null) {
        _isRouteSelected = false;
        return;
      }
      _isRouteSelected = true;
    });
    print("Route selected: $_isRouteSelected");
  }

  Future removeSymbolsLinesCircles() async {
    await mapController.removeSymbols(mapController.symbols);
    await mapController.removeLines(mapController.lines);
    await mapController.removeCircles(mapController.circles);
    print("Circles removed");
    _drawedRoutes.clear();
  }

  Future onCreateRoute() async {
    Navigator.pop(context, 'OK');
    await removeSymbolsLinesCircles();
    setState(() {
      _isInCreatorMode = true;
      _selectedRoute = null;
      _locations.clear();
    });
  }

  Future onRunPreparingCancelled() async {
    setState(() {
      _isPreparingRun = false;
    });
    await removeSymbolsLinesCircles();
    await drawRoutes();
  }

  Future onCreateRouteCancelled() async {
    setState(() {
      _isInCreatorMode = false;
      _isPreparingRun = false;
      _selectedRoute = null;
      _isRouteSelected = false;
      _locations.clear();
    });
    await removeSymbolsLinesCircles();
    await drawRoutes();
  }

  Future onMapCreated(MapboxMapController controller) async {
    Future.delayed(const Duration(milliseconds: 1000), () async{
      mapController = controller;
      _mapInitalized = true;
      mapController.addListener(_onMapChanged);
      await _extractVisibleRegion();

      var _myLocation = await _location.getLocation();
      mapController.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_myLocation.latitude!, _myLocation.longitude!), 13));
      controller.onSymbolTapped.add(_onSymbolTapped);
    });
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
