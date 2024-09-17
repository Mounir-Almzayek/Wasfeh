import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Constants/Address.dart';
import '../../../widget/Field/BirthdateField.dart';
import '../../../widget/Button/BlackButton.dart';
import '../../../widget/Button/GenderSelectionWidget.dart';
import '../../../widget/Button/BloodTypeSelectionWidget.dart';
import '../../../widget/Field/PasswordInputField.dart';
import '../../../widget/Field/TextInputField.dart';
import '../../Patient/PatientScreen.dart';

class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({Key? key}) : super(key: key);

  @override
  _PatientRegistrationPageState createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController(); // إضافة المتحول الخاص برقم الهاتف
  final TextEditingController _birthdateController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneNumberError;
  String? _birthdateError;
  String? _selectedGender;
  String? _genderError;
  String? _selectedBloodType;
  String? _bloodTypeError;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.w, 10.h, 0.w, 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 10.h, 0.w, 15.h),
            child: TextInputField(
              hintText: 'Enter your name',
              errorText: _nameError,
              controller: _nameController,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: TextInputField(
              hintText: 'Enter your email',
              errorText: _emailError,
              controller: _emailController,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: PasswordInputField(
              hintText: 'Enter your password',
              errorText: _passwordError,
              controller: _passwordController,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: PasswordInputField(
              hintText: 'Confirm your password',
              errorText: _confirmPasswordError,
              controller: _confirmPasswordController,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: TextInputField(
              hintText: 'Enter your phone number',
              errorText: _phoneNumberError,
              controller: _phoneNumberController,
              isNumeric: true,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: BirthdateField(
              hintText: 'Enter your date of birth',
              errorText: _birthdateError,
              controller: _birthdateController,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: GenderSelectionWidget(
              selectedGender: _selectedGender,
              onGenderChanged: (String? gender) {
                setState(() {
                  _selectedGender = gender;
                  _genderError = null;
                });
              },
              errorText: _genderError,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 30.h),
            child: BloodTypeSelectionWidget(
              selectedBloodType: _selectedBloodType,
              onBloodTypeChanged: (String? bloodType) {
                setState(() {
                  _selectedBloodType = bloodType;
                  _bloodTypeError = null;
                });
              },
              errorText: _bloodTypeError,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: BlackButton(
              text: "Register",
              onPressed: _createAccount,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  bool _validateInputs() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name is required*' : null;
      _emailError = _emailController.text.isEmpty ? 'Email is required*' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Password is required*' : null;
      _confirmPasswordError = _confirmPasswordController.text.isEmpty ? 'Confirm password is required*' : null;
      _phoneNumberError = _phoneNumberController.text.isEmpty ? 'Phone number is required*' : null;
      _birthdateError = _birthdateController.text.isEmpty ? 'Birthdate is required*' : null;
      _genderError = _selectedGender == null ? 'Gender is required*' : null;
      _bloodTypeError = _selectedBloodType == null ? 'Blood type is required*' : null;

      if (_passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text != _confirmPasswordController.text) {

        _confirmPasswordError = 'Passwords do not match*';
        _confirmPasswordController.clear();
      }
    });

    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _phoneNumberError == null &&
        _birthdateError == null &&
        _genderError == null &&
        _bloodTypeError == null;
  }

  Future<void> _createAccount() async {
    if (_validateInputs()) {
      setState(() {
        _isLoading = true;
      });

      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String password_confirmation = _confirmPasswordController.text.trim();
      final String phoneNumber = _phoneNumberController.text.trim();
      final String birthdate = _birthdateController.text.trim();
      final String gender = _selectedGender!;
      final String bloodType = _selectedBloodType!;

      // URL of your API endpoint
      final String apiUrl = '$BASE_URL/register';

      try {

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..fields['name'] = name
          ..fields['email'] = email
          ..fields['password'] = password
          ..fields['password_confirmation'] = password_confirmation
          ..fields['role'] = 'patient'
          ..fields['gender'] = gender
          ..fields['blood_type'] = bloodType
          ..fields['phone_number'] = phoneNumber
          ..fields['DOB'] = birthdate;

        request.headers.addAll({
          'Accept': 'application/json',
        });

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          // Success response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful!')),
          );
          final responseBody = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(responseBody);
          final Map<String, dynamic> userData = jsonResponse['user'];
          final String authToken = jsonResponse['access_token'];
          final String userRole = 'patient';
          final String userName = userData['name'];
          final String userEmail = userData['email'];
          final String userID = userData['id'].toString();

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', authToken);
          await prefs.setString('role', userRole);
          await prefs.setString('name', userName);
          await prefs.setString('email', userEmail);
          await prefs.setString('userID', userID);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => PatientScreen()),
                (Route<dynamic> route) => false,
          );

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
            errorMessage = 'Registration failed: ${response.reasonPhrase}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          // Handle other statuses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.reasonPhrase}')),
          );
        }

      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
