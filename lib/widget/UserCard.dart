import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'InitialsAvatar.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String? email;
  final double? avatarSize;

  UserCard({
    super.key,
    required this.name,
    this.email,
    this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    return Container(
      color: Color(0xFFF8F8F6),
      margin: EdgeInsets.fromLTRB(5.w,30.h,0.w,5.h),
      padding: EdgeInsets.fromLTRB(0.w, 0.h,0.w,0.h),
      child: Row(
        children: [
          InitialsAvatar(
            initials: initials,
            size: avatarSize != null ? avatarSize!.w : 40.w,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email != null ? name : 'Hey, $name!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 1.2,
                    color: Color(0xFF000000),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 5.h),
                Text(
                  email ?? 'How can I help you?',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 1.2,
                    color: Color(0xFF8C8C8C),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    for (var n in names) {
      initials += n[0].toUpperCase();
    }
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }
}
