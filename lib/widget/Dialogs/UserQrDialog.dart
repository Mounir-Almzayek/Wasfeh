import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Button/BlackButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../InitialsAvatar.dart';

class UserQrDialog {
  static Future<void> showUserInfoDialog({
    required BuildContext context,
    required String userName,
    required String qrData,
  }) {
    final initials = _getInitials(userName);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Avatar image
                InitialsAvatar(
                  initials: initials,
                  size: 60.w,
                ),
                SizedBox(height: 10.h),
                // User name
                Text(
                  userName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    height: 1.2,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 10.h),
                // QR code generated from qrData
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 225.w,
                  gapless: false,
                  embeddedImage: AssetImage('assets/images/logo.png'), // Replace with your PNG image path
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(100, 100),
                  ),
                ),
                SizedBox(height: 10.h),
                // Message
                Text(
                  'Please keep this screen open while the doctor connects.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.3,
                    color: Color(0xFF8391A1),
                  ),
                ),
                SizedBox(height: 30),
                BlackButton(
                  text: "Exit",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    for (var n in names) {
      initials += n[0].toUpperCase();
    }
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }
}
