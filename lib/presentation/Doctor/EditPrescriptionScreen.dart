import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../Constants/Address.dart';
import '../../widget/Button/BlackButton.dart';
import '../../widget/Field/TextInputField.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/SectionHeader.dart';

class EditPrescriptionScreen extends StatefulWidget {
  final String prescriptionId;
  final Map<String, dynamic> prescriptionData;

  const EditPrescriptionScreen({
    super.key,
    required this.prescriptionId,
    required this.prescriptionData,
  });

  @override
  _EditPrescriptionScreenState createState() => _EditPrescriptionScreenState();
}

class _EditPrescriptionScreenState extends State<EditPrescriptionScreen> {
  final List<GlobalKey<FormState>> _formKeys = [];
  final List<Map<String, TextEditingController>> _medicineControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFieldsWithData();
  }

  void _initializeFieldsWithData() {
    for (dynamic medicine in widget.prescriptionData['prescription_items']) {
      final formKey = GlobalKey<FormState>();
      _formKeys.add(formKey);

      _medicineControllers.add({
        'id': TextEditingController(text: '${medicine['id'] ?? ''}'),
        'name': TextEditingController(text: medicine['name']),
        'condition': TextEditingController(text: medicine['patient_condition']),
        'dosage': TextEditingController(text: '${medicine['dosage']}'),
        'instructions': TextEditingController(text: medicine['instructions'] ?? ''),
        'refills': TextEditingController(text: '${medicine['quantity']}'),
      });
    }

    setState(() {});
  }

  Widget _buildMedicineForm(int index) {
    final controllers = _medicineControllers[index];
    final formKey = _formKeys[index];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionHeader(
                title: 'Medication #${index + 1}',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black12),
                onPressed: () {
                  if (_medicineControllers.length > 1) {
                    setState(() {
                      _medicineControllers.removeAt(index);
                      _formKeys.removeAt(index);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot delete the last medication')),
                    );
                  }
                },
              ),
            ],
          ),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField('Medication Name', controllers['name']!),
                _buildTextFormField('Patient Condition', controllers['condition']!),
                _buildTextFormField('Dosage', controllers['dosage']!),
                _buildTextFormField('Instructions', controllers['instructions']!),
                _buildTextFormField('Refills', controllers['refills']!, isNumeric: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String hintText, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: TextInputField(
        controller: controller,
        hintText: hintText,
        isNumeric: isNumeric,
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> prescriptionItems = _medicineControllers.map((controllers) {
      return {
        'id': controllers['id']!= null ? int.tryParse(controllers['id']!.text) : null,
        'name': controllers['name']!.text,
        'patient_condition': controllers['condition']!.text,
        'dosage': controllers['dosage']!.text,
        'instructions': controllers['instructions']!.text.isNotEmpty ? controllers['instructions']!.text : null,
        'quantity': controllers['refills']!.text,
      };
    }).toList();

    Map<String, dynamic> updatedPrescription = {
      'prescription_items': prescriptionItems,
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('auth_token');

      final String apiUrl = '$BASE_URL/prescriptions/${widget.prescriptionId}';

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updatedPrescription),
      );


      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription updated successfully')),
        );
        Navigator.pop(context);
        Navigator.pop(context);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update prescription')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addNewMedicine() {
    final formKey = GlobalKey<FormState>();
    _formKeys.add(formKey);

    _medicineControllers.add({
      'name': TextEditingController(),
      'condition': TextEditingController(),
      'dosage': TextEditingController(),
      'instructions': TextEditingController(),
      'refills': TextEditingController(),
    });

    setState(() {}); // Refresh the UI to show the new medicine form
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0.h),
          child: Column(
            children: [
              PageHeaderWithBackButton(
                title: 'Edit Prescription',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20.h),
              for (int i = 0; i < _medicineControllers.length; i++)
                _buildMedicineForm(i),
              SizedBox(height: 20.h),
              // Button to add a new medication
              BlackButton(
                text: 'Add New Medication',
                onPressed: _addNewMedicine,
                backgroundColor: Colors.white,
                textColor: Colors.black54,
              ),
              SizedBox(height: 20.h),
              BlackButton(
                text: 'Save Changes',
                onPressed: _saveChanges,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
