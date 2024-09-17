import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../Constants/Address.dart';
import '../../widget/Button/BlackButton.dart';
import '../../widget/InfoWidget.dart';
import '../../widget/MedicineDetails.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/SectionHeader.dart';
import 'EditPrescriptionScreen.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  final String prescriptionId;

  const DoctorPrescriptionScreen({super.key, required this.prescriptionId});

  @override
  _DoctorPrescriptionScreenState createState() =>
      _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState extends State<DoctorPrescriptionScreen> {
  Map<String, dynamic>? prescription;
  Map<String, dynamic>? fullPrescription;
  bool isLoading = true;
  bool isDeleting = false;
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

    final String apiUrl =
        '$BASE_URL/prescriptions/${widget.prescriptionId}';

    try {
      var request = http.MultipartRequest('GET', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        setState(() {
          prescription =
              processPrescriptionData(json.decode(responseData.body));
          fullPrescription = json.decode(responseData.body);
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
    return {
      'patientName': data['patient']['user']['name'],
      'date': formatDateTime(data['updated_at']) ?? 'Date not provided',
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
              'subtitle': item['patient_condition']?.toString() ??
                  'Condition not specified',
            },
            {
              'title': 'Instructions:',
              'subtitle': item['instructions']?.toString() ??
                  'No instructions provided',
            },
            {
              'title': 'Refills:',
              'subtitle':
                  '${item['quantity']} refills.',
            },
          ],
        };
      }).toList(),
    };
  }

  Future<void> deletePrescription() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final String apiUrl =
        '$BASE_URL/prescriptions/${widget.prescriptionId}';

    setState(() {
      isDeleting = true;
    });

    try {
      var request = http.MultipartRequest('DELETE', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      var response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete prescription: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
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
                ? Container(
                    height: 600.h,
                    child: Center(child: CircularProgressIndicator()))
                : errorMessage != null
                    ? Container(
                        height: 600.h,
                        child: Center(child: Text(errorMessage!)),
                      )
                    : Column(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(30.w, 40.h, 30.w, 5.h),
                            child: const SectionHeader(
                              title:
                                  'Provide the code to your pharmacist to get your dose:',
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0.h),
                            child: InfoWidget(
                              title: 'Patient:',
                              subtitle:
                                  '${prescription!['patientName']}',
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
                            padding: EdgeInsets.fromLTRB(25.w, 40.h,25.w,0.h),
                            child: BlackButton(
                              text: 'Edit',
                              backgroundColor: Colors.white,
                              textColor: Colors.black54,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => EditPrescriptionScreen(prescriptionId: widget.prescriptionId, prescriptionData: fullPrescription!,)),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(25.w, 20.h,25.w,0.h),
                            child: BlackButton(
                              text: 'Delete',
                              onPressed: deletePrescription,
                              isLoading: isDeleting,
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 40.h),
                            child: SizedBox(
                              width: 150.w,
                              child:
                                  SvgPicture.asset('assets/svgs/Reading.svg'),
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

