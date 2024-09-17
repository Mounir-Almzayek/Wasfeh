import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widget/Button/BlackButton.dart';
import '../LoginScreen.dart';

class PasswordChangedScreen extends StatefulWidget {
  @override
  _PasswordChangedScreenState createState() => _PasswordChangedScreenState();
}

class _PasswordChangedScreenState extends State<PasswordChangedScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 60.h,20.w,10.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120.w,
                  height: 110.w,// Responsive width
                  child: SvgPicture.asset(
                    'assets/svgs/done.svg',
                  ),
                ),
                SizedBox(height: 20.h), // Responsive height
                Text(
                  'Password Changed!',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp, // Responsive text size
                    color: Color(0xFF1E232C),
                  ),
                ),
                SizedBox(height: 10.h), // Responsive height
                Text(
                  'Your password has been changed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp, // Responsive text size
                    height: 1.5,
                    color: Color(0xFF8391A1),
                  ),
                ),
                SizedBox(height: 30.h), // Responsive height
                Container(
                    margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,30.h),
                  child: BlackButton(
                    text: "Back to Login",
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}