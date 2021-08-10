import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/route_service.dart';

class RouteAddPage extends StatefulWidget {
  late List<LocationModel> locations;

  RouteAddPage(this.locations, {Key? key}) : super(key: key);

  @override
  _RouteAddPageState createState() => _RouteAddPageState(locations);
}

class _RouteAddPageState extends State<RouteAddPage> {
  late List<LocationModel> _locations;

  _RouteAddPageState(List<LocationModel> locations) {
    _locations = locations;
  }

  final AuthService _authService = AuthService.getInstance();
  final RouteService _routeService = RouteService.getInstance();

  bool _isLoading = false;

  final TextEditingController nameController = new TextEditingController();
  final TextEditingController descriptionController =
      new TextEditingController();
  final String? Function(String?)? nameValidator = (value) {
    if (value!.isEmpty)
      return "Nazwa nie może być pusta";
    else if (value.length < 6)
      return "Nazwa jest za krótka";
    else if (value.length > 100) return "Nazwa jest za długa";
    return null;
  };
  final String? Function(String?)? descriptionValidator = (value) {
    if (value!.isEmpty && value.length > 1024) return "Opis jest za długi";
    return null;
  };

  final List<String> difficulties = [
    "Zielony",
    "Niebieski",
    "Czerwony",
    "Czarny"
  ];
  String selectedDifficulty = "Zielony";

  final List<Activity> activities = [
    Activity(name: "Spacer", value: 1),
    Activity(name: "Hiking", value: 2),
    Activity(name: "Bieganie", value: 4),
    Activity(name: "Jazda rowerem", value: 8)
  ];
  List<Activity> selectedActivity = [];

  Future<void> _addRoute() async {
    final String routeName = nameController.text;
    final String routeDescription = descriptionController.text;
    String difficulty = '';
    switch (selectedDifficulty) {
      case "Zielony":
        difficulty = "green";
        break;
      case 'Niebieski':
        difficulty = 'blue';
        break;
      case 'Czerwony':
        difficulty = 'red';
        break;
      case 'Czarny':
        difficulty = 'black';
        break;
      default:
        throw Exception();
    }
    int activityType = 0;
    for (var activity in selectedActivity) {
      activityType |= activity.value;
    }
    setState(() {
      _isLoading = true;
    });

    var response = await _routeService.addRouteRequest(
        routeName, routeDescription, difficulty, activityType, _locations);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      Helper.toastSuccess("Trasa została dodana i czeka na akceptację");
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushNamed('/map');
      });
    } else if (response.statusCode == 400) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      print(jsonResponse);

      if (jsonResponse['code'] == 'route_already_exists') {
        Helper.toastFail("Trasa z tą nazwą już istnieje");
      } else if (jsonResponse['code'] == 'route_name_too_short') {
        Helper.toastFail("Nazwa trasy jest za krótka.");
      } else {
        Helper.toastFail("Wystąpił błąd: ${jsonResponse['code']}");
      }
    } else {
      Helper.toastFail("Wystąpił nieznany błąd");
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      print(jsonResponse);
    }
  }

  Widget getTextField(
      {required String hint,
      required TextEditingController controller,
      required String? Function(String?)? validator,
      bool obscureText = false,
      int maxLines = 1}) {
    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.transparent, width: 0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.transparent, width: 0),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          filled: true,
          fillColor: AppColors.FILL_COLOR,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _key = GlobalKey<FormState>();

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.arrow_back_ios,
          ),
          backgroundColor: Colors.grey,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        body: Scaffold(
          backgroundColor: Colors.white,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22.h),
                    child: Form(
                      key: _key,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 44.h,
                            ),
                            Text(
                              "Dodawanie trasy",
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                                "Podaj nazwę, opis, poziom trudności i przeznaczenie trasy",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                )),
                            SizedBox(
                              height: 24.h,
                            ),
                            Text(
                              "Nazwa",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            getTextField(
                                controller: nameController,
                                hint: "Wprowadź nazwę trasy",
                                validator: nameValidator,
                                maxLines: 2),
                            SizedBox(
                              height: 16.h,
                            ),
                            Text(
                              "Opis",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            getTextField(
                                controller: descriptionController,
                                hint: "Wprowadź opis trasy",
                                validator: descriptionValidator,
                                maxLines: 5),
                            SizedBox(
                              height: 16.h,
                            ),
                            Text(
                              "Poziom trudności",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButton<String>(
                                  isExpanded: true,
                                  items: difficulties
                                      .map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem(
                                        child: Text(
                                          value,
                                          style: TextStyle(fontSize: 16.sp),
                                        ),
                                        value: value);
                                  }).toList(),
                                  value: selectedDifficulty,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDifficulty = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16.h,
                            ),
                            Text(
                              "Rodzaj aktywości",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            MultiSelectDialogField(
                              buttonText: Text("Wybierz rodzaj aktywności"),
                              items: activities
                                  .map((e) => MultiSelectItem(e.value, e.name))
                                  .toList(),
                              listType: MultiSelectListType.CHIP,
                              onConfirm: (values) {
                                setState(() {
                                  selectedActivity = values as List<Activity>;
                                });
                              },
                              chipDisplay: MultiSelectChipDisplay(
                              ),
                              validator: (values) {
                                if (values == null || values.isEmpty) {
                                  return "Musisz podać rodzaj aktywności";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  if (_key.currentState!.validate()) {
                                    _addRoute();
                                  }
                                },
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    )),
                                    backgroundColor: MaterialStateProperty.all(
                                        AppColors.PRIMARY),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.symmetric(vertical: 14.h)),
                                    textStyle:
                                        MaterialStateProperty.all(TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ))),
                                child: Text("Dodaj trasę"),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ));
  }
}

class Activity {
  final int value;
  final String name;

  Activity({
    required this.value,
    required this.name,
  });
}