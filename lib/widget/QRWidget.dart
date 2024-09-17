import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRWidget extends StatelessWidget {
  final String data;
  final bool Status;

  QRWidget({
    required this.data,
    required this.Status,
  });

  @override
  Widget build(BuildContext context) {
    Widget statusWidget;

    if (!Status) {
      statusWidget = Container(
        decoration: BoxDecoration(
          color: Color(0x1A25B865),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 0.9, 8.1, 0.9),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Make the row take up only necessary width
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 10.1, 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF25B865),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: 8,
                  height: 8,
                ),
              ),
              Text(
                'Medication available for pickup',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xFF25B865),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      statusWidget = Container(
        decoration: BoxDecoration(
          color: Color(0x1AF71010),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 3, 8.1, 3),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Make the row take up only necessary width
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 10.1, 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF71010),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: 8,
                  height: 8,
                ),
              ),
              Text(
                'Medication already taken.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xFFF71010),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 320.w,
      height: 360.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A434343),
            offset: Offset(0, 10),
            blurRadius: 10.w,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10.w, 10.w, 10.w, 10.w),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 250.w,
              gapless: false,
              embeddedImage: AssetImage('assets/images/logo.png'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(100, 100),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
              padding: EdgeInsets.fromLTRB(10.w, 5.w, 10.w, 5.w),
              child: IntrinsicWidth( // Ensures the width is only as wide as needed
                child: statusWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
