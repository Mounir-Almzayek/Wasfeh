import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:digital_prescription_management_app/widget/Button/SelectableTabs.dart';
import '../../widget/Button/BackButtonWidget.dart';
import 'TypesOfRegisters/DoctorRegistrationPage.dart';
import 'TypesOfRegisters/PatientRegistrationPage.dart';
import 'TypesOfRegisters/PharmacistRegistrationPage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _selectedTab = 'patient';

  void _handleTabSelection(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Define the pages to be displayed
    List<Widget> _pages = [
      PatientRegistrationPage(),
      DoctorRegistrationPage(),
      PharmacistRegistrationPage(),
    ];

    // Determine the index of the page based on the selected tab
    int _selectedPageIndex = {
      'patient': 0,
      'doctor': 1,
      'pharmacist': 2,
    }[_selectedTab] ?? 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 60.h,20.w,10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButtonWidget(),
                Container(
                  margin: EdgeInsets.fromLTRB(5.w, 20.h,0.w,20.h),
                  child: Text(
                    'Select your role to join and register!',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                      height: 1.3,
                      letterSpacing: -0.3,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 10.h,0.w,10.h),
                  child: SelectableTabs(
                    onTabSelected: _handleTabSelection,
                  ),
                ),
                Container(
                  child: IndexedStack(
                    index: _selectedPageIndex,
                    children: _pages,
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
