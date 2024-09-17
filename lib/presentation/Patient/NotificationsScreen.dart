import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../widget/InfoWidget.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/SectionHeader.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedNotifications = prefs.getStringList('notifications') ?? [];
    setState(() {
      notifications = storedNotifications
          .map((notification) => jsonDecode(notification) as Map<String, dynamic>)
          .toList();
    });
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 0.h),
              child: PageHeaderWithBackButton(
                title: 'Notifications',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 30.h),
              child: SectionHeader(
                title: 'Upcoming Medication Reminders:',
              ),
            ),
            ...notifications.map<Widget>((notification) {
              return Container(
                margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoWidget(
                      title: formatDateTime(notification['time']),
                      subtitle: 'Reminder to take ${notification['medicine']}.',
                    ),
                  ],
                ),
              );
            }).toList(),
            Container(
              padding: EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 40.h),
              child: SizedBox(
                width: 150.w,
                child: SvgPicture.asset(
                  'assets/svgs/GetNotified.svg',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
