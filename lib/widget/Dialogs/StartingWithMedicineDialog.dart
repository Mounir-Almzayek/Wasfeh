import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Constants/Address.dart';
import '../Button/BlackButton.dart';

class StartingWithMedicineDialog {
  static Future<void> showMedicationDialog({
    required BuildContext context,
    required int medicationId,  // Medication ID passed as a parameter
    required VoidCallback onConfirm,  // Callback function to call upon confirmation
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
                'Start Medication',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: Color(0xFF000000),
                ),
              ),
              content: Text(
                'Take the first pill and begin the notification schedule for future doses.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: Color(0xFF8391A1),
                ),
              ),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cancel Button
                    BlackButton(
                      text: 'Cancel',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      backgroundColor: Colors.grey[200],
                      textColor: Colors.black,
                    ),
                    SizedBox(height: 20.h),
                    // Confirm Button
                    BlackButton(
                      text: 'Confirm',
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        final prefs = await SharedPreferences.getInstance();
                        String? authToken = prefs.getString('auth_token');

                        final String apiUrl = '$BASE_URL/prescription_item/${medicationId}';

                        try {
                          var request = http.MultipartRequest('GET', Uri.parse(apiUrl));
                          request.headers['Authorization'] = 'Bearer $authToken';
                          request.headers['Accept'] = 'application/json';

                          var response = await request.send();

                          if (response.statusCode == 200) {
                            setState(() {
                              onConfirm();
                            });
                            Navigator.of(context).pop();
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        } finally {
                          setState(() {
                            isLoading = false;
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
