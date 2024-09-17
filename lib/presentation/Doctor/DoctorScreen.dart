import 'package:flutter/material.dart';
import '../../widget/Button/CustomBottomNavigationBar.dart';
import 'DoctorArchivePage.dart';
import 'DoctorHomePage.dart';
import 'DoctorProfilePage.dart';

class DoctorScreen extends StatefulWidget {
  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      DoctorHomePage(),
      DoctorArchivePage(navigateToHome: () => _onItemTapped(0)),
      DoctorProfilePage(navigateToHome: () => _onItemTapped(0)),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        context: context,
      ),
    );
  }
}
