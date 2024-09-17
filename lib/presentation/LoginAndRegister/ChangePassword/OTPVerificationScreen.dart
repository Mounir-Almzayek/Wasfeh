import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Constants/Address.dart';
import '../../../widget/Button/BackButtonWidget.dart';
import '../../../widget/Button/BlackButton.dart';
import '../../../widget/Field/OTPInputFields.dart';
import '../../../widget/Button/RichTextButton.dart';
import 'ResetPasswordScreen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  OTPVerificationScreen({super.key, required this.email});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _otpError;
  bool _isLoading = false;
  bool _isResendLoading = false;
  bool _isResendDisabled = false;
  int _remainingSeconds = 60;
  Timer? _timer;

  void _startResendTimer() {
    setState(() {
      _isResendDisabled = true;
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResendDisabled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
            padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButtonWidget(),
                Container(
                  margin: EdgeInsets.fromLTRB(5.w, 30.h, 0.w, 5.h),
                  child: const Text(
                    'OTP Verification',
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
                  margin: EdgeInsets.fromLTRB(5.w, 5.h, 10.w, 40.h),
                  child: const Text(
                    'Enter the verification code we just sent on your email address.',
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
                    margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                    child: OTPInputFields(
                      controller: _otpController,
                      errorMessage: _otpError,
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 300.h),
                  child: BlackButton(
                    text: "Verify",
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
                    normalText: 'Didn’t receive code? ',
                    coloredText: _isResendDisabled
                        ? 'Retry in $_remainingSeconds seconds'
                        : _isResendLoading
                        ? 'Resending...'
                        : 'Resend',
                    onPressed: _isResendDisabled || _isResendLoading ? null : _resendOTP,
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
      _otpError = _otpController.text.length < 4 ? 'Please enter the complete OTP.' : null;
    });

    if (_otpError == null) {
      setState(() {
        _isLoading = true;
      });

      final String otp = _otpController.text.trim();

      // URL of your API endpoint
      final String apiUrl = '$BASE_URL/reset_password_check';

      try {

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..fields['email'] = widget.email
          ..fields['otp'] = otp;

        request.headers.addAll({
          'Accept': 'application/json',
        });

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          // OTP verified successfully
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: widget.email, otp: otp,)));
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
          // Handle invalid OTP or server errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid OTP: ${response.reasonPhrase}')),
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

  void _resendOTP() async {
    setState(() {
      _isResendLoading = true;
    });

    final String apiUrl = '$BASE_URL/reset_password';

    try {

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['email'] = widget.email;

      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isResendLoading = false;
        _startResendTimer();
      });
    }
  }
}
