import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../Constants/Address.dart';
import '../../widget/InfoWidget.dart';
import '../../widget/MedicineDetails.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/QRWidget.dart';
import '../../widget/SectionHeader.dart';

class PrescriptionScreen extends StatefulWidget {
  final String prescriptionId;

  const PrescriptionScreen({super.key, required this.prescriptionId});

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  Map<String, dynamic>? prescription;
  bool isLoading = true;
  String? errorMessage;
  String? authToken;

  @override
  void initState() {
    super.initState();
    fetchPrescriptionData();
  }

  Future<void> fetchPrescriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');

    final String apiUrl = '$BASE_URL/prescriptions/${widget.prescriptionId}';

    try {
      var request = http.MultipartRequest('GET', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        setState(() {
          prescription = processPrescriptionData(json.decode(responseData.body));
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String? formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  Map<String, dynamic> processPrescriptionData(Map<String, dynamic> data) {
    print(data['purchased']);
    return {
      'qr_code': '${data['id']}',
      'doctorName': data['doctor']['user']['name'],
      'specialty': data['doctor']['specialization'] ?? 'Specialization not provided',
      'date': formatDateTime(data['updated_at']) ?? 'Date not provided',
      'purchased': data['purchased'],
      'medicines': (data['prescription_items'] as List).map((item) {
        return {
          'name': item['name'].toString(),
          'details': [
            {
              'title': 'Dosage:',
              'subtitle': item['dosage']?.toString() ?? 'No dosage provided',
            },
            {
              'title': 'Patient Condition:',
              'subtitle': item['patient_condition']?.toString() ?? 'Condition not specified',
            },
            {
              'title': 'Instructions:',
              'subtitle': item['instructions']?.toString() ?? 'No instructions provided',
            },
            {
              'title': 'Refills Remaining:',
              'subtitle': '${item['quantity'] - item['quantity_taken']} refills left.',
            },
            {
              'title': 'Next Reminder:',
              'subtitle': item['next_remainder']?.toString() ?? 'there is no next reminder',
            },
          ],
        };
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 0.h),
              child: PageHeaderWithBackButton(
                title: 'Patient Prescription',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            isLoading
                ? Container(height: 600.h, child: Center(child: CircularProgressIndicator()))
                : errorMessage != null
                ? Container(height: 600.h, child: Center(child: Text(errorMessage!)),)
                : Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(30.w, 40.h, 30.w, 5.h),
                  child: const SectionHeader(
                    title: 'Provide the code to your pharmacist to get your dose:',
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0.h),
                  child: QRWidget(
                    data: prescription!['qr_code'] ?? '.',
                    Status: int.tryParse(prescription!['purchased'].toString()) == 1,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0.h),
                  child: InfoWidget(
                    title: 'Prescribing Doctor:',
                    subtitle: '${prescription!['doctorName']} (${prescription!['specialty']})',
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0.h),
                  child: InfoWidget(
                    title: 'Date of Issue:',
                    subtitle: prescription!['date'],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0.h),
                  child: const SectionHeader(
                    title: 'Medication Names:',
                  ),
                ),
                ...prescription!['medicines'].map<Widget>((medicine) {
                  return MedicineDetails(
                    name: medicine['name'],
                    details: medicine['details'],
                  );
                }).toList(),
                Container(
                  padding: EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 40.h),
                  child: SizedBox(
                    width: 150.w,
                    child: SvgPicture.asset('assets/svgs/Reading.svg'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
