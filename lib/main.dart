import 'package:digital_prescription_management_app/presentation/LoginAndRegister/LoginScreen.dart';
import 'package:digital_prescription_management_app/presentation/OnboardingScreen.dart';
import 'package:digital_prescription_management_app/presentation/Doctor/DoctorScreen.dart';
import 'package:digital_prescription_management_app/presentation/Patient/PatientScreen.dart';
import 'package:digital_prescription_management_app/presentation/Pharmacist/PharmacistScreen.dart';
import 'package:digital_prescription_management_app/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initNotification();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _determineInitialScreen();
    FlutterNativeSplash.remove();
  }

  Future<void> _determineInitialScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    final String? role = prefs.getString('role');

    Widget screen;

    if (authToken != null && role != null) {
      switch (role) {
        case 'doctor':
          screen = DoctorScreen();
          break;
        case 'pharmacist':
          screen = PharmacistScreen();
          break;
        case 'patient':
        default:
          screen = PatientScreen();
          break;
      }
    } else {
      bool? isFirstTime = prefs.getBool('first_time');
      if (isFirstTime == null || isFirstTime == true) {
        prefs.setBool('first_time', false);
        screen = OnboardingScreen();
      } else {
        screen = LoginScreen();
      }
    }

    setState(() {
      _initialScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: globalNavigatorKey,
          debugShowCheckedModeBanner: false,
          home: _initialScreen ?? const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
