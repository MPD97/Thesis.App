import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';

class CompleteRegistrationProcessPage extends StatefulWidget {
  @override
  _CompleteRegistrationProcessPageState createState() =>
      _CompleteRegistrationProcessPageState();
}

class _CompleteRegistrationProcessPageState
    extends State<CompleteRegistrationProcessPage> {
  final AuthService _authService = AuthService.getInstance();
  bool _isLoading = false;

  final TextEditingController pseudonymController = new TextEditingController();
  final String? Function(String?)? pseudonymValidator = (value) {
    if (value!.isEmpty)
      return "Pseudonim nie może być pusty";
    else if (value.length < 5)
      return "Pseudonim jest za krótki";
    else if (value.length > 15)
      return "Pseudonim jest za długi";
    else if(RegExp(r"^[a-zA-Z]\w*$").hasMatch(value) == false){
      return "Pseudonim zawiera niedozwolone znaki";
    }
    return null;
  };


  Widget getTextField(
      {required String hint,
        required TextEditingController controller,
        required String? Function(String?)? validator,
        bool obscureText = false}) {

    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: obscureText,
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
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: FloatingActionButton(
            child: const Icon(
              Icons.arrow_back_ios,
            ),
            backgroundColor: Colors.grey,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Scaffold(
          backgroundColor: Colors.white,
          body: _isLoading ? const Center(child: CircularProgressIndicator(),) :
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.h),
              child: Form(
                key: _key,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 52.h,
                      ),
                      Text(
                        "Dokończ rejestrację konta",
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                          "Wybierz swój pseudonim który będzie wyświetlany w aplikacji",
                          style: TextStyle(
                            fontSize: 12.sp,
                            letterSpacing: 1.15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          )),
                      SizedBox(
                        height: 24.h,
                      ),
                      Text(
                        "Pseudonim",
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
                          controller: pseudonymController,
                          hint: "Wprowadź pseudonim",
                          validator: pseudonymValidator),
                      SizedBox(
                        height: 20.h,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            if (_key.currentState!.validate()) {
                              _completeRegistration(pseudonymController.text);
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
                              textStyle: MaterialStateProperty.all(TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ))),
                          child: Text("Zapisz pseudonim"),
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

  void _completeRegistration(String pseudonym) async {
    setState(() {
      _isLoading = true;
    });
    var response = await _authService.completeRegistration(pseudonym);
    setState(() {
      _isLoading = false;
    });

    if (response == null) {
      Helper.toastFail("Coś poszło nie tak");
      return;
    }

    if (response.statusCode == 201) {
      Helper.toastSuccess("Pseudonim zapisany");
      Navigator.of(context).pushNamed('/');
    } else if (response.statusCode == 400) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      switch (jsonResponse['code']) {
        case 'user_already_registered':
          Helper.toastFail('Pseudonim jest zajęty');
          break;
        case 'invalid_user_pseudonym_length':
          Helper.toastFail('Pseudonim jest za krótki, lub za długi');
          break;
        case 'invalid_user_pseudonym':
          Helper.toastFail('Pseudonim jest nieprawidłowy');
          break;
        default:
          print(jsonResponse['code']);
          Helper.toastFail('Wystąpił nieznany błąd');
          break;
      }
    }else if (response.statusCode == 404) {
      Helper.toastFail('Serwer nie odpowiada');
    }else {
      Helper.toastFail('Wystąpił nieznany błąd');
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      margin: const EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: pseudonymController.text == ""
            ? null
            : () {
                _completeRegistration(pseudonymController.text);
              },
        child: Text("Zapisz", style: const TextStyle(color: Colors.white70)),
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

}
