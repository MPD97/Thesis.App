import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService.getInstance();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _key = GlobalKey<FormState>();

    final TextEditingController emailController = new TextEditingController();
    final TextEditingController passwordController = new TextEditingController();
    final TextEditingController repeatPasswordController = new TextEditingController();

    final String? Function(String?)? emailValidator = (value) {
      if (value!.isEmpty)
        return "Email nie może być pusty";
      else if (value.length < 8)
        return "Email jest za krótki";
      else if (value.length > 50)
        return "Email jest za długi";
      else if (EmailValidator.validate(value) == false)
        return "Email jest niepoprawny";
      return null;
    };

    final String? Function(String?)? passwordValidator = (value) {
      if (value!.isEmpty)
        return "Hasło nie może być puste";
      else if (value.length < 6) return "Hasło jest za krótkie";
      else if (value.length > 20) return "Hasło jest za długie";
      return null;
    };

    final String? Function(String?)? repeatPasswordValidator = (value) {
      if (value!.isEmpty)
        return "Hasła nie są identyczne";
      if (value != passwordController.text)
        return "Hasła nie są identyczne";
      return null;
    };

    void _onRedirectToLogin() {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed("/login");
    }

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
                        height: 44.h,
                      ),
                      Text(
                        "Rejestracja",
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                          "Utwórz nowe konto i korzystaj z serwisu za darmo",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          )),
                      SizedBox(
                        height: 24.h,
                      ),
                      Text(
                        "Email",
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
                          controller: emailController,
                          hint: "Wprowadź adres email",
                          validator: emailValidator),
                      SizedBox(
                        height: 16.h,
                      ),
                      Text(
                        "Hasło",
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
                          controller: passwordController,
                          hint: "Wprowadź hasło",
                          validator: passwordValidator,
                          obscureText: true),
                      SizedBox(
                        height: 16.h,
                      ),
                      Text(
                        "Powtórz hasło",
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
                          controller: repeatPasswordController,
                          hint: "Wprowadź ponownie hasło",
                          validator: repeatPasswordValidator,
                          obscureText: true),
                      SizedBox(
                        height: 20.h,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            if (_key.currentState!.validate()) {
                              register(emailController.text, repeatPasswordController.text);
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
                          child: Text("Zarejestruj"),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Center(
                        child: Wrap(
                          children: [
                            Text(
                              "Posiadasz konto? ",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: _onRedirectToLogin,
                              child: Text(
                                "Zaloguj się",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.LIGHT,
                                ),
                              ),
                            ),
                          ],
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

  void register(String email, password) async {
    setState(() {
      _isLoading = true;
    });
    var response = await _authService.registerUser(email, password);
    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      Helper.toastSuccess('Konto utworzone');
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.of(context).pushNamed('/login');
    } else if (response.statusCode == 400) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      switch (jsonResponse['code']) {
        case 'email_in_use':
          Helper.toastFail('Adres email jest zajęty');
          break;
        default:
          Helper.toastFail('Wystąpił nieznany błąd');
          print(jsonResponse);
          break;
      }
    } else if (response.statusCode == 404) {
      Helper.toastFail('Serwer nie odpowiada');
    }
    else{
      Helper.toastFail('Wystąpił nieznany błąd');
    }
  }
}
