import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/Button/BlackButton.dart';
import '../../widget/Field/HourPickerField.dart';
import '../../widget/Field/TextInputField.dart';
import '../../widget/InitialsAvatar.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/SectionHeader.dart';
import 'QRScanScreen.dart';
import 'package:digital_prescription_management_app/Constants/Address.dart';

class AddPrescriptionScreen extends StatefulWidget {
  final dynamic scanData;

  const AddPrescriptionScreen({super.key, required this.scanData});

  @override
  _AddPrescriptionScreenState createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final List<GlobalKey<FormState>> _formKeys = [];
  final List<Map<String, TextEditingController>> _medicineControllers = [];
  final List<Map<String, String?>> _errorMessages = [];
  bool _isLoading = false;
  late String _patientName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _addMedicineField();
    _fetchAndSetPatientName();
  }

  void _fetchAndSetPatientName() async {
    final patientId = splitString(widget.scanData)['id'].toString();
    final patientName = await fetchPatientName(patientId);
    setState(() {
      _patientName = patientName;
    });
  }

  Future<String> fetchPatientName(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final String apiUrl = '$BASE_URL/patient/$patientId';

    try {
      var request = http.MultipartRequest('GET', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        return jsonResponse['patient_name'];
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Map<String, String> splitString(String input) {
    int spaceIndex = input.indexOf(' ');

    if (spaceIndex != -1) {
      String id = input.substring(0, spaceIndex);
      String token = input.substring(spaceIndex + 1);
      return {
        'id': id,
        'token': token,
      };
    } else {
      return {
        'id': '',
        'token': '',
      };
    }
  }

  void _addMedicineField() {
    final formKey = GlobalKey<FormState>();
    _formKeys.add(formKey);

    _medicineControllers.add({
      'name': TextEditingController(),
      'condition': TextEditingController(),
      'dosage': TextEditingController(),
      'instructions': TextEditingController(),
      'refills': TextEditingController(),
    });

    _errorMessages.add({
      'name': null,
      'condition': null,
      'dosage': null,
      'instructions': null,
      'refills': null,
    });

    setState(() {});
  }

  void _removeMedicineField() {
    if (_medicineControllers.length > 1) {
      _formKeys.removeLast();
      _medicineControllers.removeLast();
      _errorMessages.removeLast();
      setState(() {});
    }
  }

  Widget _buildMedicineForm(int index) {
    final controllers = _medicineControllers[index];
    final formKey = _formKeys[index];
    final errors = _errorMessages[index];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Medication #${index + 1}',
          ),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField('Medication Name', controllers['name']!, errors['name']),
                _buildTextFormField('Patient Condition', controllers['condition']!, errors['condition']),
                _buildHourPickerFormField('Dosage Interval', controllers['dosage']!, errors['dosage']),
                _buildTextFormField('Instructions', controllers['instructions']!, errors['instructions']),
                _buildTextFormField('Refills', controllers['refills']!, errors['refills'], isNumeric: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String hintText, TextEditingController controller, String? errorText,{bool isNumeric = false} ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextInputField(
            controller: controller,
            hintText: hintText,
            errorText: errorText,
            isNumeric: isNumeric,
          ),
        ],
      ),
    );
  }

  Widget _buildHourPickerFormField(String hintText, TextEditingController controller, String? errorText) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HourPickerField(
            hintText: hintText,
            errorText: errorText,
            selectedValue: int.tryParse(controller.text),
            onChanged: (newValue) {
              controller.text = newValue?.toString() ?? '';
            },
          ),
        ],
      ),
    );
  }


  void _validateFields() {
    bool isValid = true;

    for (int i = 0; i < _medicineControllers.length; i++) {
      final controllers = _medicineControllers[i];
      final errors = _errorMessages[i];

      errors['name'] = controllers['name']!.text.isEmpty ? 'Medication Name is required*' : null;
      errors['condition'] = controllers['condition']!.text.isEmpty ? 'Patient Condition is required*' : null;
      errors['dosage'] = controllers['dosage']!.text.isEmpty ? 'Dosage is required*' : null;
      errors['instructions'] = controllers['instructions']!.text.isEmpty ? 'Instructions are required*' : null;
      errors['refills'] = controllers['refills']!.text.isEmpty ? 'Refills are required*' : null;

      isValid = isValid && (errors['name'] == null) && (errors['condition'] == null) &&
          (errors['dosage'] == null) && (errors['instructions'] == null) &&
          (errors['refills'] == null);
    }

    setState(() {});

    if (isValid) {
      _submitPrescription();
    }
  }

  Future<void> _submitPrescription() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('auth_token');

    final String apiUrl = '$BASE_URL/prescriptions';

    try {

      // Extract patient ID and prescription items from scanData
      final scanDataParts = splitString('${widget.scanData}');
      final patientId = scanDataParts['id'] ?? '';

      // Build the JSON payload
      final prescriptionPayload = buildPrescriptionJson(patientId);

      Map<String, String> headers = {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Send the POST request with the JSON body
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({
          'patient_id': patientId.toString(),
          'prescription_items': prescriptionPayload['prescription_items'],
        }),
      );

      if (response.statusCode == 200) {
        // Handle success response here
        _showSuccessDialog();
      } else if (response.statusCode == 422) {
        // Read the response body from the stream
        final jsonResponse = jsonDecode(response.body);
        final errors = jsonResponse['errors'];
        String errorMessage = '';

        // Extract and display specific validation errors
        if (errors != null && errors is Map<String, dynamic>) {
          errors.forEach((key, value) {
            errorMessage += '$key: ${value[0]}\n';
          });
        } else {
          errorMessage = 'Submission failed: ${response.reasonPhrase}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        // Handle other statuses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
              'Prescription Submitted!',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: Color(0xFF1E232C),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your prescription has been successfully submitted.\n If you need to make any changes, please visit your archive and press on the information you wish to modify.',
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

  Map<String, dynamic> buildPrescriptionJson(String patientId) {
    List<Map<String, dynamic>> prescriptionItems = [];

    for (int i = 0; i < _medicineControllers.length; i++) {
      final controllers = _medicineControllers[i];

      Map<String, dynamic> item = {
        'name': controllers['name']!.text,
        'patient_condition': controllers['condition']!.text,
        'dosage': _extractNumbers(controllers['dosage']!.text),
        'quantity': controllers['refills']!.text,
      };

      // Add instructions if present
      if (controllers['instructions']!.text.isNotEmpty) {
        item['instructions'] = controllers['instructions']!.text;
      }

      prescriptionItems.add(item);
    }

    return {
      'patient_id': patientId,
      'prescription_items': prescriptionItems,
    };
  }

  String _extractNumbers(String text) {
    final RegExp numberRegExp = RegExp(r'\d+');
    final Iterable<Match> matches = numberRegExp.allMatches(text);

    return matches.map((match) => match.group(0)!).join('');
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    for (var n in names) {
      initials += n[0].toUpperCase();
    }
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0.h),
          child: Column(
            children: [
              PageHeaderWithBackButton(
                title: 'Patient Prescription',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QRScanScreen(isForAddingPrescription: true),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              InitialsAvatar(
                initials: _getInitials(_patientName),
                size: 80.w,
                backgroundColor: Colors.deepPurple,
                textColor: Colors.white,
              ),
              SizedBox(height: 10.h),
              Text(
                _patientName,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  color: Color(0xFF1E232C),
                ),
              ),
              SizedBox(height: 20.h),
              for (int i = 0; i < _medicineControllers.length; i++)
                _buildMedicineForm(i),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _addMedicineField,
                    icon: Icon(Icons.add),
                    color: Color(0xFF35C2C1),
                    iconSize: 30.sp,
                  ),
                  IconButton(
                    onPressed: _removeMedicineField,
                    icon: Icon(Icons.remove),
                    color: _medicineControllers.length > 1
                        ? Colors.red
                        : Colors.grey,
                    iconSize: 30.sp,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              BlackButton(
                text: _isLoading ? 'Submitting...' : 'Submit Prescription',
                onPressed: _isLoading ? (){} : _validateFields,
                isLoading: _isLoading,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
