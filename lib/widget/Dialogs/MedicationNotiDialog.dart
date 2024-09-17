import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/Address.dart';
import '../../utils/notification_service.dart';
import 'package:http/http.dart' as http;
import '../Button/BlackButton.dart';

class MedicationNotiDialog extends StatefulWidget {
  final String medicineName;
  final int medicationId;

  MedicationNotiDialog({required this.medicineName, required this.medicationId});

  @override
  _MedicationNotiDialogState createState() => _MedicationNotiDialogState();
}

class _MedicationNotiDialogState extends State<MedicationNotiDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text(
        'Medication Reminder',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16.sp, // Adjusted font size
          color: Color(0xFF000000),
        ),
      ),
      content: Text(
        'Have you taken your ${widget.medicineName}?',
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          color: Color(0xFF8391A1),
        ),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Full-width buttons
          children: [
            // "No" button
            BlackButton(
              text: 'No',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                NotificationService().scheduleNextMedicationReminder(widget.medicineName); // Schedule reminder
              },
              backgroundColor: Colors.grey[200], // Grey background for "No"
              textColor: Colors.black,
            ),
            SizedBox(height: 20.h),
            // "Yes" button
            BlackButton(
              text: 'Yes',
              onPressed: () async {
                setState(() {
                  isLoading = true; // Start loading
                });
                setState(() {
                  isLoading = true;
                });

                final prefs = await SharedPreferences.getInstance();
                String? authToken = prefs.getString('auth_token');

                final String apiUrl = '$BASE_URL/prescription_item/${widget.medicationId}';

                try {
                  var request = http.MultipartRequest('GET', Uri.parse(apiUrl));
                  request.headers['Authorization'] = 'Bearer $authToken';
                  request.headers['Accept'] = 'application/json';

                  var response = await request.send();

                  if (response.statusCode == 200) {
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
                Navigator.of(context).pop(); // Close dialog
              },
              isLoading: isLoading,
            ),
          ],
        ),
      ],
    );
  }
}
