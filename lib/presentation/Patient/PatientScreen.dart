import 'package:digital_prescription_management_app/presentation/Patient/PatientArchivePage.dart';
import 'package:digital_prescription_management_app/presentation/Patient/PatientHomePage.dart';
import 'package:digital_prescription_management_app/presentation/Patient/PatientProfilePage.dart';
import 'package:flutter/material.dart';
import '../../widget/Button/CustomBottomNavigationBar.dart';

class PatientScreen extends StatefulWidget {
  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      PatientHomePage(),
      PatientArchivePage(navigateToHome: () => _onItemTapped(0)),
      PatientProfilePage(navigateToHome: () => _onItemTapped(0)),
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
        duration: Duration(milliseconds: 300),
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
