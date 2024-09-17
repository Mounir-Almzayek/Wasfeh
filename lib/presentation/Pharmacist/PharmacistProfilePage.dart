import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/Dialogs/AboutAppDialog.dart';
import '../../widget/CardWidget.dart';
import '../../widget/Dialogs/LogoutDialog.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/UserCard.dart';

class PharmacistProfilePage extends StatefulWidget {
  final VoidCallback navigateToHome;

  const PharmacistProfilePage({super.key, required this.navigateToHome});

  @override
  _PharmacistProfilePageState createState() => _PharmacistProfilePageState();
}

class _PharmacistProfilePageState extends State<PharmacistProfilePage> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('name');
    final String? email = prefs.getString('email');


    setState(() {
      _userName = name ?? 'User';
      _userEmail = email ?? 'Email not set';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(10.w,40.h,10.w,0.h),
              child: PageHeaderWithBackButton(
                title: 'Pharmacist Profile',
                onTap: widget.navigateToHome,
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(20.w,10.h,20.w,20.h),
                child: UserCard(
                  name: 'Pharm.D. ${_userName}',
                  email: _userEmail,
                  avatarSize: 50,
                )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15.w,10.h,15.w,5.h),
              child: CardWidget(
                title: 'About',
                subtitle: "Read more about our app.",
                iconAsset: 'assets/svgs/About.svg',
                arrowAsset: 'assets/svgs/arrow.svg',
                onPressed: () {
                  AboutAppDialog.showAboutAppDialog(
                    context: context,
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15.w,10.h,15.w,5.h),
              child: CardWidget(
                title: 'Sign out',
                subtitle: "Log out safely; your data is saved.",
                iconAsset: 'assets/svgs/Sign_out.svg',
                arrowAsset: 'assets/svgs/arrow.svg',
                onPressed: () {
                  LogoutDialog.showLogoutDialog(
                    context: context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
