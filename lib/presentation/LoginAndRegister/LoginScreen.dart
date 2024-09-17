import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digital_prescription_management_app/widget/Button/SelectableTabs.dart';
import 'package:digital_prescription_management_app/widget/Field/TextInputField.dart';
import '../../Constants/Address.dart';
import '../../widget/Button/BlackButton.dart';
import '../../widget/Field/PasswordInputField.dart';
import '../../widget/Button/RichTextButton.dart';
import '../Doctor/DoctorScreen.dart';
import '../Patient/PatientScreen.dart';
import '../Pharmacist/PharmacistScreen.dart';
import 'ChangePassword/ForgotPasswordScreen.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedTab = 'patient';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  void _handleTabSelection(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 110.h, 20.w, 50.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 30.h),
                  child: Text(
                    'Welcome back! Glad to see you, Again!',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                      height: 1.3,
                      letterSpacing: -0.3,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                  child: SelectableTabs(
                    onTabSelected: _handleTabSelection,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                  child: TextInputField(
                    hintText: 'Enter your email',
                    errorText: _emailError,
                    controller: _emailController,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                  child: PasswordInputField(
                    hintText: 'Enter your password',
                    errorText: _passwordError,
                    controller: _passwordController,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 30.h),
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen())
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF6A707C),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 200.h),
                  child: BlackButton(
                    text: "Login",
                    onPressed: _validateInputs,
                    isLoading: _isLoading,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  alignment: Alignment.topCenter,
                  child: RichTextButton(
                    normalText: 'Don’t have an account? ',
                    coloredText: 'Register Now',
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RegisterScreen())
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _validateInputs() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Email is required*' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Password is required*' : null;
    });

    if (_emailError == null && _passwordError == null) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String role = _selectedTab;

      try {
        final response = await http.post(
          Uri.parse('$BASE_URL/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
            'role': role,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final Map<String, dynamic> userData = responseData['user'];
          final String authToken = responseData['access_token'];
          final String userRole = _selectedTab;
          final String userName = userData['name'];
          final String userEmail = userData['email'];
          final String userID = userData['id'].toString();

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', authToken);
          await prefs.setString('role', userRole);
          await prefs.setString('name', userName);
          await prefs.setString('email', userEmail);
          await prefs.setString('userID', userID);

          _navigateToHomePage();

        } else if (response.statusCode == 422) {
          // Validation error response (422 Unprocessable Entity)
          final jsonResponse = jsonDecode(response.body);
          final errors = jsonResponse['errors'];
          String errorMessage = '';

          // Extract and display specific validation errors
          if (errors != null && errors is Map<String, dynamic>) {
            errors.forEach((key, value) {
              errorMessage += '$key: ${value[0]}\n';
            });
          } else {
            final jsonResponse = jsonDecode(response.body);
            print(jsonResponse);
            errorMessage = 'Login failed: ${response.reasonPhrase}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          // Handle other statuses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) {
        switch (_selectedTab) {
          case 'doctor':
            return DoctorScreen();
          case 'pharmacist':
            return PharmacistScreen();
          case 'patient':
          default:
            return PatientScreen();
        }
      }),
          (Route<dynamic> route) => false,
    );
  }
}
