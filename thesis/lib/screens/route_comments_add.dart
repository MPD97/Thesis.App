import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/comments_service.dart';

class RouteAddCommentPage extends StatefulWidget {
  late RouteModel model;
  RouteAddCommentPage(RouteModel this.model){}

  @override
  _RouteAddCommentPageState createState() =>
      _RouteAddCommentPageState(model);
}

class _RouteAddCommentPageState
    extends State<RouteAddCommentPage> {
  late RouteModel model;
  _RouteAddCommentPageState( RouteModel this.model){}
  bool _isLoading = false;
  final _commentService = CommentsService.getInstance();

  final TextEditingController textResorceController = new TextEditingController();
  final String? Function(String?)? textResorceValidator = (value) {
    if (value!.isEmpty)
      return "Komentarz nie może być pusty";
    else if (value.length < 3)
      return "Komentarz jest za krótki";
    else if (value.length > 400)
      return "Komentarz jest za długi";
    return null;
  };


  Widget getTextField(
      {required String hint,
        required TextEditingController controller,
        required String? Function(String?)? validator,
        bool obscureText = false, int maxLines = 1}) {

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
                        "Dodaj komentarz",
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                          "Komentarze mogą być cennym źródłem opinni o danej trasie",
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
                        "Treść komentarza",
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
                          controller: textResorceController,
                          hint: "Wprowadź wiadomość",
                          validator: textResorceValidator,
                          maxLines: 4),
                      SizedBox(
                        height: 20.h,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            if (_key.currentState!.validate()) {
                              _addComment(textResorceController.text);
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
                          child: Text("Dodaj"),
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

  Future _addComment(String text) async {
    setState(() {
      _isLoading = true;
    });
    var response = await _commentService.addCommentRequest(model.id, text);
    setState(() {
      _isLoading = false;
    });

    if (response == null) {
      Helper.toastFail("Coś poszło nie tak");
      return;
    }
    if (response.statusCode == 201) {
      Helper.toastSuccess("Komentarz został dodany");
      Navigator.of(context).pop();
    } else if (response.statusCode == 400) {
      Helper.toastFail('Wprowadzono błedny komentarz');

    }else if (response.statusCode == 404) {
      Helper.toastFail('Serwer nie odpowiada');
    }else {
      Helper.toastFail('Wystąpił nieznany błąd');
    }
  }
}
