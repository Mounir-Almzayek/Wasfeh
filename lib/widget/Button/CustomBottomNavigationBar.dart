import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final BuildContext context;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 70.h,
      color: Color(0xFFF5F7F8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomBottomNavigationBarItem(
            label: 'Home',
            icon: 'assets/svgs/Home.svg',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          CustomBottomNavigationBarItem(
            label: 'Archive',
            icon: 'assets/svgs/Archive.svg',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          CustomBottomNavigationBarItem(
            label: 'Profile',
            icon: 'assets/svgs/Profile.svg',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavigationBarItem extends StatelessWidget {
  final String label;
  final String icon;
  final bool isActive;
  final VoidCallback onTap;

  CustomBottomNavigationBarItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(0.w, 15.h,0.w,0.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: SvgPicture.asset(
                  icon,
                  height: 20.h, // Adjust icon height
                  key: ValueKey<bool>(isActive),
                  color: isActive ? Color(0xFF35C2C1) : Colors.grey,
                ),
              ),
              SizedBox(height: 10.h), // Adjust spacing
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp, // Adjust font size
                  height: 1.2,
                  letterSpacing: 0,
                  color: isActive ? Color(0xFF35C2C1) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
