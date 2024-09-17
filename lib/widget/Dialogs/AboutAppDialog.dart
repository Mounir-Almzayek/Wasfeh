import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Button/BlackButton.dart';
import '../InitialsAvatar.dart';

class AboutAppDialog {
  static Future<void> showAboutAppDialog({
    required BuildContext context,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InitialsAvatar(
                          initials: '?',
                          size: 60.w,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'About This App',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18.h,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Target Audience
                  Text(
                    'Target Audience:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '1. Doctors: Who want to issue digital prescriptions easily and securely.\n'
                        '2. Patients: Who need a simplified way to manage and track their prescriptions.\n'
                        '3. Pharmacies: That require a quick and secure way to receive prescriptions.',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: Color(0xFF8391A1),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // App Goals
                  Text(
                    'App Goals:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '1. Issue digital prescriptions with QR codes for doctors.\n'
                        '2. Enable patients to access their prescriptions by scanning the QR code, simplifying medication tracking.\n'
                        '3. Speed up the medication dispensing process in pharmacies through QR code scanning.\n'
                        '4. Enhance security and privacy by using QR codes for safe prescription exchanges.',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: Color(0xFF8391A1),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // QR Code Feature
                  Text(
                    'QR Code Feature:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'For Doctors:\n'
                        'When issuing a prescription, the system generates a unique QR code containing all prescription details.\n'
                        'The QR code is sent to the patient’s electronic prescription database and stored in the system records for future access.\n\n'
                        'For Patients:\n'
                        'Patients can access the QR code for their prescription through the app.\n'
                        'At the pharmacy, patients simply scan the QR code to allow the pharmacist to view the details quickly.\n'
                        'Receive medication reminders.\n\n'
                        'For Pharmacies:\n'
                        'Pharmacists can scan the QR code using a mobile device or an integrated system to view the prescription directly.\n'
                        'After scanning, they can confirm medication dispensing and update prescription status in the system (availability and remaining quantity).',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: Color(0xFF8391A1),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Developers
                  Text(
                    'Developers:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Developers
                  Text(
                    'Frontend: Mounir Almzayek\n'
                        'Backend: Mouaz Zakaria',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: Color(0xFF8391A1),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // Exit Button
                  BlackButton(
                    text: "Close",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
