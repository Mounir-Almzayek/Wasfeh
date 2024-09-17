import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BloodTypeSelectionWidget extends StatefulWidget {
  final String? selectedBloodType;
  final ValueChanged<String?> onBloodTypeChanged;
  final String? errorText;

  BloodTypeSelectionWidget({
    required this.selectedBloodType,
    required this.onBloodTypeChanged,
    this.errorText,
  });

  @override
  _BloodTypeSelectionWidgetState createState() => _BloodTypeSelectionWidgetState();
}

class _BloodTypeSelectionWidgetState extends State<BloodTypeSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    final List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    return Container(
      margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(5.w, 10.h,10.w,10.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Blood type:',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                  color: Color(0xFF2F3C4E),
                ),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.w,
              childAspectRatio: 1.5,
            ),
            itemCount: bloodTypes.length,
            itemBuilder: (context, index) {
              String bloodType = bloodTypes[index];
              return _buildBloodTypeOption(bloodType, isSelected: widget.selectedBloodType == bloodType);
            },
          ),
          if (widget.errorText != null)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                widget.errorText!,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12.sp,
                  color: Color(0xFF821131),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeOption(String type, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        widget.onBloodTypeChanged(type);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xFF35C2C1) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: Color(0xFFF7F8F9),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(10.w, 10.h,10.w,10.h),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: isSelected ? Color(0xFF35C2C1) : Color(0xFF8391A1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
