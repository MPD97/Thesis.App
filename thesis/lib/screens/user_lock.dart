import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/user_service.dart';

class LockUserPage extends StatefulWidget {
  late String userId;

  LockUserPage(this.userId) {}

  @override
  _LockUserPageState createState() => _LockUserPageState(userId);
}

class _LockUserPageState extends State<LockUserPage> {
  late String _userId;

  _LockUserPageState(this._userId) {}

  final AuthService _authService = AuthService.getInstance();
  final UserService _userService = UserService.getInstance();
  bool _isLoading = false;

  final TextEditingController reasonController = new TextEditingController();
  final String? Function(String?)? reasonValidator = (value) {
    if (value!.isEmpty)
      return "Powód blokady nie może być pusty";
    else if (value.length < 10)
      return "Powód blokady jest za krótki";
    else if (value.length > 400) return "Powód blokady jest za długi";

    return null;
  };

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
                              "Zablokuj konto użytkownika",
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                                "Jeżeli użytkownik rażąco naruszył przepisy dobrym pomysłem może być blokada konta",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                )),
                            SizedBox(
                              height: 24.h,
                            ),
                            Text(
                              "Powód blokady",
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
                                controller: reasonController,
                                hint: "Opisz powód blokady",
                                validator: reasonValidator),
                            SizedBox(
                              height: 20.h,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  if (_key.currentState!.validate()) {
                                    _lockUser(_userId, reasonController.text);
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
                                child: Text("Zablokuj użytkownika"),
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

  Future<void> _lockUser(String userId, String reason) async {
    setState(() {
      _isLoading = true;
    });

    var response = await _userService.lockUserRequest(userId, reason);

    setState(() {
      _isLoading = false;
    });
    if (response == null) {
      return;
    }

    if (response.statusCode == 204) {
      Helper.toastSuccess("Użytkownik został zablokowany");
      Future.delayed(const Duration(milliseconds: 1500),
            () => Navigator.of(context).pop()
      );
    } else if (response.statusCode == 400) {
      Helper.toastFail("Niepoprawne dane");
    } else if (response.statusCode == 401) {
      Helper.toastFail('Nie jestes zalogowany');
    } else if (response.statusCode == 403) {
      Helper.toastFail('Brak uprawnień');
    } else if (response.statusCode == 404) {
      Helper.toastFail('Serwer nie odpowiada');
    } else {
      Helper.toastFail('Wystąpił nieznany błąd');
    }
  }

  Future<void> _getMeAsUser() async {
    setState(() {
      _isLoading = true;
    });
    var response = await _authService.userMeRequest();
    setState(() {
      _isLoading = false;
    });

    if (response == null) {
      Helper.toastFail("Coś poszło nie tak");
      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      var state = jsonResponse['state'];
      if (state == 'valid') {
        print("User state is valid");
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.of(context).pushNamed('/');
      } else if (state == 'incomplete') {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.of(context).pushNamed('/complete-registration-process');
        print("User state is incomplete");
      } else if (state == 'locked') {
        Helper.toastFail("Konto zostało zablokowane");
      } else {
        Helper.toastFail("Konto posiada nieznany status");
      }
    } else if (response.statusCode == 404) {
      Helper.toastFail('Serwer nie odpowiada');
    } else {
      Helper.toastFail('Wystąpił nieznany błąd');
    }
  }
}
