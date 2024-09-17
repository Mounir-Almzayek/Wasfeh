import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectableTabs extends StatefulWidget {
  final void Function(String) onTabSelected;

  SelectableTabs({required this.onTabSelected,});

  @override
  _SelectableTabsState createState() => _SelectableTabsState();
}

class _SelectableTabsState extends State<SelectableTabs> {
  String _selectedTab = 'patient'; // Default selected tab

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 0.h,
        horizontal: 0.w,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(3.w,3.h,3.w,3.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTab('patient'),
              _buildTab('doctor'),
              _buildTab('pharmacist'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String tabName) {
    bool isSelected = _selectedTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabName;
            widget.onTabSelected(tabName);
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.fromLTRB(2.w,6.h,2.w,6.h),
          padding: EdgeInsets.fromLTRB(2.w,10.h,2.w,10.h),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF35C2C1) : Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Center(
            child: Text(
              tabName,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 9.sp,
                color: isSelected ? Color(0xFFFFFFFF) : Color(0xFFB2B2B2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
