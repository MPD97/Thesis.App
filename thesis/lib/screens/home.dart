import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/services/auth_service.dart';

import 'main_drawer.dart';

class HomePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Gra geolokalizacyjna"),
        ),
        drawer: MainDrawer(),
        body: SafeArea(
            child: Stack(
              children: [
                Container(
                  child: Image.asset('assets/images/home.png',
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      fit: BoxFit.cover),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 470.h,),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              AuthService.userIsAuthorized ?
                              Navigator.of(context).pushNamed('/map')
                                  : Navigator.of(context).pushNamed('/login');
                            },
                            style: ButtonStyle(
                                shape:MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),)),
                                elevation: MaterialStateProperty.all(12),
                                backgroundColor:
                                MaterialStateProperty.all(AppColors.PRIMARY),
                                foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        horizontal: 50.h, vertical: 10.w)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: 14.sp, fontWeight: FontWeight
                                    .bold))),
                            child: Text(
                              AuthService.userIsAuthorized ? "Mapa" : "Logowanie",
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )));
  }
}
