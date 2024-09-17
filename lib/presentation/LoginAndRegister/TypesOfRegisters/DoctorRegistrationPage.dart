import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../Constants/Address.dart';
import '../../../widget/Button/BlackButton.dart';
import '../../../widget/Button/FileUploadButton.dart';
import '../../../widget/Field/PasswordInputField.dart';
import '../../../widget/Field/TextInputField.dart';
import '../../../widget/SectionHeader.dart';

class DoctorRegistrationPage extends StatefulWidget {
  const DoctorRegistrationPage({Key? key}) : super(key: key);

  @override
  _DoctorRegistrationPageState createState() => _DoctorRegistrationPageState();
}

class _DoctorRegistrationPageState extends State<DoctorRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _specialtyError;
  String? _fileError;

  PlatformFile? _selectedFile;
  bool _isLoading = false;

  void _handleFileSelection(PlatformFile? file) {
    setState(() {
      _selectedFile = file;
      _fileError = null;
    });
  }

  Future<void> _createAccount() async {
    if (_validateInputs()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String specialty = _specialtyController.text.trim();
      final String password_confirmation = _confirmPasswordController.text.trim();


      // URL of your API endpoint
      final String apiUrl = '$BASE_URL/register';

      try {
        // Create a multipart request
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..fields['name'] = name
          ..fields['email'] = email
          ..fields['password'] = password
          ..fields['password_confirmation'] = password_confirmation
          ..fields['role'] = 'pharmacist'
          ..fields['specialty'] = specialty;

        request.headers.addAll({
          'Accept': 'application/json',
        });

        // Attach the file if selected
        if (_selectedFile != null) {
          var file = http.MultipartFile(
            'certificate',
            File(_selectedFile!.path!).readAsBytes().asStream(),
            File(_selectedFile!.path!).lengthSync(),
            filename: _selectedFile!.name,
            contentType: MediaType('application', 'jpg'),
          );
          request.files.add(file);
        }

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          // Success response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful!')),
          );
          // Navigate to login page after success
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pushReplacementNamed('/login');
          });
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
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  bool _validateInputs() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name is required*' : null;
      _emailError = _emailController.text.isEmpty ? 'Email is required*' : null;
      _specialtyError = _specialtyController.text.isEmpty ? 'Specialty is required*' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Password is required*' : null;
      _confirmPasswordError = _confirmPasswordController.text.isEmpty ? 'Confirm password is required*' : null;
      _fileError = _selectedFile == null ? 'File is required*' : null;

      if (_passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match*';
        _confirmPasswordController.clear();
      }
    });

    return _nameError == null &&
        _emailError == null &&
        _specialtyError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _fileError == null;
  }

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
            child: TextInputField(
              hintText: 'Enter your specialty',
              errorText: _specialtyError,
              controller: _specialtyController,
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
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
            child: PasswordInputField(
              hintText: 'Confirm your password',
              errorText: _confirmPasswordError,
              controller: _confirmPasswordController,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
            child: SectionHeader(
              title: 'Medical certificate:',
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 30.h),
            child: FileUploadButton(
              errorText: _fileError,
              onFileSelected: _handleFileSelection,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 15.h),
            child: BlackButton(
              text: "Register",
              onPressed: _createAccount,
              isLoading: _isLoading, // Pass the loading state
            ),
          ),
        ],
      ),
    );
  }
}
