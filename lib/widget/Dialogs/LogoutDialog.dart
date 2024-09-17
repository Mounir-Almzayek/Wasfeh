import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/Address.dart';
import '../../presentation/LoginAndRegister/LoginScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Button/BlackButton.dart';

class LogoutDialog {
  static Future<void> showLogoutDialog({
    required BuildContext context,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                'Confirm Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp, // Increased font size for better readability
                  color: Color(0xFF000000),
                ),
              ),
              content: Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, // Slightly increased font size
                  color: Color(0xFF8391A1),
                ),
              ),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons take full width
                  children: [
                    // Cancel Button
                    BlackButton(
                      text: 'Cancel',
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      backgroundColor: Colors.grey[200],
                      textColor: Colors.black,
                    ),
                    SizedBox(height: 20.h), // Add vertical spacing between buttons
                    // Confirm Button
                    BlackButton(
                      text: 'Log Out',
                      onPressed: () async {
                        setState(() {
                          isLoading = true; // Set loading state to true
                        });

                        final prefs = await SharedPreferences.getInstance();
                        String? authToken = prefs.getString('auth_token');

                        try {

                          final response = await http.post(
                            Uri.parse('$BASE_URL/logout'),
                            headers: {
                              'Authorization': 'Bearer $authToken',
                              'Content-Type': 'application/json',
                            },
                          );

                          if (response.statusCode == 200) {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.clear();

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                                  (Route<dynamic> route) => false,
                            );
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
                              errorMessage = 'Log out failed: ${response.reasonPhrase}';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Log out failed: ${response.reasonPhrase}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Log out failed: ${e.toString()}')),
                          );
                        } finally {
                          setState(() {
                            isLoading = false; // Set loading state to false
                          });
                        }
                      },
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
