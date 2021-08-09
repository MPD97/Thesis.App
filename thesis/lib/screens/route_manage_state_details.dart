import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/main.dart';
import 'package:thesis/models/PointModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/models/RouteStatusModel.dart';
import 'package:thesis/services/route_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RouteAcceptDetailsPage extends StatefulWidget {
  late RouteModel _model;

  RouteAcceptDetailsPage(this._model, {Key? key}) : super(key: key) {}

  @override
  _RouteAcceptDetailsPageState createState() =>
      _RouteAcceptDetailsPageState(_model);
}

class _RouteAcceptDetailsPageState extends State<RouteAcceptDetailsPage> {
  final _routeService = RouteService.getInstance();
  late final RouteModel _model;
  late LatLngBounds _routeBounds;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MapboxMapController? mapController;

  _RouteAcceptDetailsPageState(this._model) {
    List<LatLng> _pointLocations = [];
    for (var point in _model.points) {
      _pointLocations.add(LatLng(point.latitude, point.longitude));
    }
    _routeBounds = boundsFromLatLngList(_pointLocations);
    print("Bounds: $_routeBounds");
  }

  @override
  Widget build(BuildContext context) {
    final MapboxMap mapboxMap = MapboxMap(
      accessToken: Application.ACCESS_TOKEN,
      onMapCreated: onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(52.23172889914352, 21.019465047569224),
        zoom: 12.0,
      ),
      trackCameraPosition: false,
      compassEnabled: false,
      cameraTargetBounds: _cameraTargetBounds,
      minMaxZoomPreference: MinMaxZoomPreference.unbounded,
      styleString: 'mapbox://styles/mpd97/ckrs8eh4l148w17o2ply5voho',
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      zoomGesturesEnabled: true,
      myLocationEnabled: false,
      myLocationTrackingMode: MyLocationTrackingMode.None,
      myLocationRenderMode: MyLocationRenderMode.NORMAL,
    );


    return Scaffold(
        appBar: AppBar(title: const Text("Szczegóły trasy")),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 150.0.h,
                  child: mapboxMap,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.h),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nazwa:",
                        style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Text(
                          _model.name,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      Text(
                        "Opis:",
                        style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Text(_model.description,
                          maxLines: 30,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      Text(
                        "Poziom trudności:",
                        style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Text(
                          getDifficulty(),
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      Text(
                        "Ilośc punktów:",
                        style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Text(
                          _model.points.length.toString(),
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      Text(
                        "Długość trasy:",
                        style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Text(
                          "${_model.length} m",
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: () {
                  AcceptRoute();
                },
                label: const Text('Zaakceptuj'),
                icon: const Icon(Icons.check),
                backgroundColor: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton.extended(
                  onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Odrzuć trasę'),
                        content: Text(
                            'Czy na pewno chcesz odrzucić trasę: "${_model.name}"?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'anuluj'),
                            child: const Text('anuluj'),
                          ),
                          TextButton(
                            onPressed: () => {RejectRoute()},
                            child: const Text('Odrzuć'),
                          ),
                        ],
                      )),
                  label: const Text('Odrzuć'),
                  icon: const Icon(Icons.clear),
                  backgroundColor: Colors.red,
                ),
              ),
            )
          ],
        ));
  }



  Future RejectRoute() async {
    var _response = await _routeService.changeRouteStatusRequest(
        _model.id, RouteStatusModel.Rejected);
    print(_response!.body);
    print("Code: ${_response.statusCode}");
    if (_response.statusCode == 204) {
      Helper.toastSuccessShort("Trasa zostałą odrzucona");
    } else if (_response.statusCode == 400) {
      var _json = json.decode(_response.body);
      Helper.toastFail("Niepowodzenie: ${_json['code']}");
    } else if (_response.statusCode == 401) {
      Helper.toastFailShort("Brak autoryzacji");
    } else {
      var _json = json.decode(_response.body);
      Helper.toastFail("Wystąpił nieznany błąd: ${_json['code']}");
    }
    Navigator.pop(context, "Odrzuć");
    Navigator.pop(context);
  }

  Future AcceptRoute() async {
    var _response = await _routeService.changeRouteStatusRequest(
        _model.id, RouteStatusModel.Accepted);
    print(_response!.body);
    print("Code: ${_response.statusCode}");
    if (_response.statusCode == 204) {
      Helper.toastSuccessShort("Trasa została zaakceptowana");
    } else if (_response.statusCode == 400) {
      var _json = json.decode(_response.body);
      Helper.toastFail("Niepowodzenie: ${_json['code']}");
    } else if (_response.statusCode == 401) {
      Helper.toastFailShort("Brak autoryzacji");
    } else {
      var _json = json.decode(_response.body);
      Helper.toastFail("Wystąpił nieznany błąd: ${_json['code']}");
    }
    Navigator.pop(context);
  }

  Future onMapCreated(MapboxMapController controller) async {
    mapController = controller;
    setState(() {
      _cameraTargetBounds = CameraTargetBounds(_routeBounds);
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      drawRoute();
    });
  }

  Future drawRoute() async {
    var _difficulty = _model.difficulty.toString().toLowerCase();
    await drawPoint(_model.points[0], _difficulty);

    for (var i = 1; i < _model.points.length; i++) {
      await drawLine(_model.points[i - 1], _model.points[i], _difficulty);
    }
  }

  Future drawPoint(PointModel point, String difficulty) async {
    var _geometry = LatLng(point.latitude, point.longitude);
    mapController!.addSymbol(SymbolOptions(
        geometry: _geometry,
        iconImage: 'marker-$difficulty',
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
    await mapController!.addLine(LineOptions(
        geometry: [_previousGeometry, _geometry],
        lineColor: color,
        lineWidth: 6.0,
        lineOpacity: 0.5));
  }

  String getDifficulty() {
    switch (_model.difficulty.toLowerCase()) {
      case 'green':
        return "Zielony";
      case 'blue':
        return "Niebieski";
      case 'red':
        return "Czerwony";
      case 'black':
        return "Czarny";
      default:
        return "Nieznany";
    }
  }
}

LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  assert(list.isNotEmpty);
  double? x0, x1, y0, y1;
  for (LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1!) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1!) y1 = latLng.longitude;
      if (latLng.longitude < y0!) y0 = latLng.longitude;
    }
  }
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}
