import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/Button/BlackButton.dart';
import 'LoginAndRegister/LoginScreen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          buildOnboardingPage(
            context,
            image: 'assets/svgs/doctorsbro_x2.svg',
            title:
            'Welcome to our digital prescription app! Connecting doctors, patients, and pharmacies seamlessly.',
            currentIndex: 0,
          ),
          buildOnboardingPage(
            context,
            image: 'assets/svgs/medical_prescriptionbro_x2.svg',
            title:
            'Doctors can easily create and share digital prescriptions with secure QR codes.',
            currentIndex: 1,
          ),
          buildOnboardingPage(
            context,
            image: 'assets/svgs/health_professional_teambro_x2.svg',
            title:
            'Join our network to enhance prescription accuracy, speed, and security',
            isLast: true,
            currentIndex: 2,
          ),
        ],
      ),
    );
  }

  Widget buildOnboardingPage(BuildContext context,
      {required String image,
        required String title,
        required int currentIndex,
        bool isLast = false}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 100.h, 0, 0.h),
                  child: SizedBox(
                    width: 300.w,
                    height: 400.h,
                    child: SvgPicture.asset(
                      image,
                    ),
                  ),
                ),
                SizedBox(
                  width: 34.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDot(currentIndex >= 0),
                      SizedBox(width: 5.w),
                      buildDot(currentIndex >= 1),
                      SizedBox(width: 5.w),
                      buildDot(currentIndex >= 2),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 40.h, 0, 70.h),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                if (isLast)
                  BlackButton(
                    text: "Let's Go",
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget buildDot(bool isActive) {
    return Container(
      width: 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF35C2C1) : Color(0xFFC4C4C4),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
