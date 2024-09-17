import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/CardWidget.dart';
import '../../widget/HealthcareJourneyWidget.dart';
import 'QRScanScreen.dart';
import '../../widget/UserCard.dart';

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('name');

    setState(() {
      _userName = name ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 5.h),
              child: UserCard(name: 'Dr. $_userName'),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
              child: const HealthcareJourneyWidget(
                text: 'Simplify Your Treatment Process!',
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 5.h),
              child: CardWidget(
                title: 'Write Report',
                subtitle: "Scan the patient's QR code to write report.",
                iconAsset: 'assets/svgs/AddReport.svg',
                arrowAsset: 'assets/svgs/arrow.svg',
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const QRScanScreen(isForAddingPrescription: true,))
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 5.h),
              child: CardWidget(
                title: 'View Medical Record',
                subtitle: "Scan the patient's QR code to access their medical history.",
                iconAsset: 'assets/svgs/ViewReport.svg',
                arrowAsset: 'assets/svgs/arrow.svg',
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const QRScanScreen(isForAddingPrescription: false,))
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(120.w, 40.h, 0.w, 40.h),
              child: SizedBox(
                width: 150.w,
                child: SvgPicture.asset(
                  'assets/svgs/relaxed_personality.svg',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
