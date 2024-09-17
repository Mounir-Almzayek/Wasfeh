import 'package:flutter/material.dart';
import 'package:digital_prescription_management_app/widget/Field/TextInputField.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Constants/Address.dart';
import '../../../widget/Button/BackButtonWidget.dart';
import '../../../widget/Button/BlackButton.dart';
import 'PasswordChangedScreen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmPasswordError;

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
                    'Create new password',
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
                    "Your new password must be unique from those previously used.",
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
                      hintText: 'New Password',
                      errorText: _passwordError,
                      controller: _passwordController,
                    )),
                Container(
                    margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,20.h),
                    child: TextInputField(
                      hintText: 'Confirm Password',
                      errorText: _confirmPasswordError,
                      controller: _confirmPasswordController,
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,350.h),
                  child: BlackButton(
                    text: "Reset Password",
                    onPressed: () {
                      _validateInputs();
                    },
                    isLoading: _isLoading,
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
      _passwordError = _passwordController.text.isEmpty ? 'Password is required*' : null;
      _confirmPasswordError = _confirmPasswordController.text.isEmpty ? 'Confirm password is required*' : null;
      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'The two fields must match.*';
        _confirmPasswordController.clear();
      }
    });

    if (_passwordError == null && _confirmPasswordError == null) {
      setState(() {
        _isLoading = true;
      });

      final String newPassword = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();

      final String apiUrl = '$BASE_URL/update_password';

      print(newPassword);
      print(confirmPassword);
      try {

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..fields['email'] = widget.email
        ..fields['password'] = newPassword
        ..fields['password_confirmation'] = confirmPassword;

        request.headers.addAll({
          'Accept': 'application/json',
        });

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          // Password reset successfully
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PasswordChangedScreen()));
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
          // Handle server errors or bad responses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reset password: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        // Handle network or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
