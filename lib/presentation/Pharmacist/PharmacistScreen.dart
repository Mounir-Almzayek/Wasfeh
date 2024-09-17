import 'package:flutter/material.dart';
import '../../widget/Button/CustomBottomNavigationBar.dart';
import 'PharmacistArchivePage.dart';
import 'PharmacistHomePage.dart';
import 'PharmacistProfilePage.dart';

class PharmacistScreen extends StatefulWidget {

  const PharmacistScreen({super.key});

  @override
  _PharmacistScreenState createState() => _PharmacistScreenState();
}

class _PharmacistScreenState extends State<PharmacistScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      PharmacistHomePage(),
      PharmacistArchivePage(navigateToHome: () => _onItemTapped(0)),
      PharmacistProfilePage(navigateToHome: () => _onItemTapped(0)),
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
