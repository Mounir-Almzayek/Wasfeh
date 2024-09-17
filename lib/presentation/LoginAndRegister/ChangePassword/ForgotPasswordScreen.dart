import 'package:digital_prescription_management_app/presentation/LoginAndRegister/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:digital_prescription_management_app/widget/Field/TextInputField.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Constants/Address.dart';
import '../../../widget/Button/BackButtonWidget.dart';
import '../../../widget/Button/BlackButton.dart';
import '../../../widget/Button/RichTextButton.dart';
import 'OTPVerificationScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 60.h,20.w,10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButtonWidget(),
                Container(
                  margin: EdgeInsets.fromLTRB(5.w, 30.h,0.w,5.h),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                      height: 1.3,
                      letterSpacing: -0.3,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(5.w, 5.h,10.w,40.h),
                  child: const Text(
                    "Don't worry! It occurs. Please enter the email address linked with your account.",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF8391A1),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,20.h),
                    child: TextInputField(
                      hintText: 'Enter your email',
                      errorText: _emailError,
                      controller: _emailController,
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,300.h),
                  child: BlackButton(
                    text: "Send Code",
                    onPressed: () {
                      _validateInputs();
                    },
                    isLoading: _isLoading,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  alignment: Alignment.topCenter,
                  child: RichTextButton(
                    normalText: 'Remember Password? ',
                    coloredText: 'Login',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
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

  void _validateInputs() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Email is required*' : null;
    });

    if (_emailError == null) {
      // Show loading indicator or other UI feedback
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text.trim();

      final String apiUrl = '$BASE_URL/reset_password';

      try {

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..fields['email'] = email;

        request.headers.addAll({
          'Accept': 'application/json',
        });

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          // Successfully sent the reset link
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(email: email)));
        } else if (response.statusCode == 422) {
          // Read the response body from the stream
          final responseBody = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(responseBody);
          final errors = jsonResponse['errors'];
          String errorMessage = '';

          // Extract and display specific validation errors
          if (errors != null && errors is Map<String, dynamic>) {
            errors.forEach((key, value) {
              errorMessage += '$key: ${value[0]}\n';
            });
          } else {
            errorMessage = 'failed: ${response.reasonPhrase}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          // Handle other server errors or bad responses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send code: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        // Handle network or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


}
