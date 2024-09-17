import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPInputFields extends StatefulWidget {
  final TextEditingController controller;
  final String? errorMessage;

  OTPInputFields({required this.controller, this.errorMessage});

  @override
  _OTPInputFieldsState createState() => _OTPInputFieldsState();
}

class _OTPInputFieldsState extends State<OTPInputFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0.w, 0.h,0.w,0.h),
          child: PinCodeTextField(
            appContext: context,
            length: 4,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 65.h,
              fieldWidth: 65.h,
              activeFillColor: Colors.white,
              selectedFillColor: Colors.white,
              inactiveFillColor: Colors.white,
              activeColor: Color(0xFF35C2C1),
              selectedColor: Color(0xFF35C2C1),
              inactiveColor:  widget.errorMessage==null ? Color(0xFFE8ECF4): Color(0xFF821131),
            ),
            controller: widget.controller,
            keyboardType: TextInputType.number,
            animationDuration: Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            enableActiveFill: true,
            onCompleted: (v) {
              print("Completed: $v");
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}
