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

class PrescriptionScreen extends StatefulWidget {
  final String prescriptionId;
  final bool isArchive;

  const PrescriptionScreen({super.key, required this.prescriptionId, required this.isArchive});

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  Map<String, dynamic>? prescription;
  bool isLoading = true;
  String? errorMessage;
  String? authToken;
  bool isPurchasing = false;


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
              'title': 'Refills:',
              'subtitle': '${item['quantity']} refills.',
            },
          ],
        };
      }).toList(),
    };
  }


  Future<void> purchasePrescription() async {
    if (prescription!['purchased'] == 1) {
      _showAlreadyPurchasedMessage();
      return;
    }
    setState(() {
      isPurchasing = true;
    });

    final String apiUrl = '$BASE_URL/purchase/${widget.prescriptionId}';

    try {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('auth_token');

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        setState(() {
          errorMessage = 'Failed to complete purchase: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isPurchasing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(20.w),
        title: SvgPicture.asset(
          'assets/svgs/done.svg',
          width: 140.w,
          height: 140.w,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Purchase Completed!',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: Color(0xFF1E232C),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your purchase has been successfully completed.\nYou can now view your purchased items in the archive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                height: 1.5,
                color: Color(0xFF8391A1),
              ),
            ),
            SizedBox(height: 20.h),
            BlackButton(
              text: 'Back to Home',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAlreadyPurchasedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Already Purchased',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          'This prescription has already been purchased.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            color: Color(0xFF8391A1),
          ),
        ),
        actions: [
          BlackButton(
            text: 'OK',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
                    title: 'Here is the info:',
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
            if(!widget.isArchive)
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                child: BlackButton(
                  text: 'Purchase Prescription',
                  isLoading: isPurchasing,
                  onPressed: purchasePrescription,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
