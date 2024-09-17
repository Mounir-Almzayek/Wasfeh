import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Constants/Address.dart';
import '../Button/BlackButton.dart';

class TakeMedicineDialog {
  static Future<void> showTakeMedicineDialog({
    required BuildContext context,
    required String medicineName,
    required int medicationId,
    required String timePassed,
    required VoidCallback onConfirm,
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
                'Have you taken $medicineName?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: Color(0xFF000000),
                ),
              ),
              content: Text(
                'It has been $timePassed since your last dose. Please take your medicine now.',
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

                        final String apiUrl = '$BASE_URL/confirm_medication/${medicationId}';

                        try {
                          var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
                          request.headers['Authorization'] = 'Bearer $authToken';
                          request.headers['Accept'] = 'application/json';

                          var response = await request.send();

                          if (response.statusCode == 200) {
                            setState(() {
                              onConfirm();
                            });
                            Navigator.of(context).pop();
                          } else {
                            // Handle other statuses
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to confirm medication: ${response.reasonPhrase}')),
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
