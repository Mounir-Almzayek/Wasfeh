import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/Address.dart';
import '../../widget/CardWidget.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/Field/SearchField.dart';
import '../../widget/SectionHeader.dart';
import 'DoctorPrescriptionScreen.dart';

class DoctorArchivePage extends StatefulWidget {
  final VoidCallback navigateToHome;

  const DoctorArchivePage({super.key, required this.navigateToHome});

  @override
  _DoctorArchivePageState createState() => _DoctorArchivePageState();
}

class _DoctorArchivePageState extends State<DoctorArchivePage> {
  late List<Map<String, dynamic>> fullTreatmentHistory;
  late List<Map<String, dynamic>> displayedTreatmentHistory;
  String sortType = 'date';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fullTreatmentHistory = [];
    displayedTreatmentHistory = [];
    _loadData();
    _fetchData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('doctorArchive');

    if (cachedData != null) {
      setState(() {
        fullTreatmentHistory = List<Map<String, dynamic>>.from(
          (json.decode(cachedData)['data'] as List<dynamic>).map(
                (item) => Map<String, dynamic>.from(item),
          ),
        );
        displayedTreatmentHistory = List.from(fullTreatmentHistory);
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      final String? role = prefs.getString('role');

      final String apiUrl = '$BASE_URL/$role/prescriptions';
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body)['data'];

        await prefs.setString('doctorArchive', jsonEncode(jsonResponse));

        setState(() {
          fullTreatmentHistory = List<Map<String, String>>.from(
            jsonResponse.map(
                  (item) => {
                'id': item['id'].toString(),
                'patient_name': item['patient_name'].toString(),
                'created_at': item['created_at'].toString(),
              },
            ),
          );
          displayedTreatmentHistory = List.from(fullTreatmentHistory);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${response.reasonPhrase}')),
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

  void _onSearchChanged(String query) {
    setState(() {
      displayedTreatmentHistory = fullTreatmentHistory.where((treatment) {
        final patient = treatment['patient_name']!.toLowerCase();
        final input = query.toLowerCase();
        return patient.contains(input);
      }).toList();
    });
  }

  void _onSortSelected(String value) {
    setState(() {
      sortType = value;
      if (sortType == 'date') {
        displayedTreatmentHistory.sort((a, b) {
          final dateA = DateTime.parse(a['created_at']!);
          final dateB = DateTime.parse(b['created_at']!);
          return dateB.compareTo(dateA);
        });
      } else if (sortType == 'patient') {
        displayedTreatmentHistory.sort((a, b) => a['patient_name']!.compareTo(b['patient_name']!));
      }
    });
  }

  String? formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 20.h),
            child: PageHeaderWithBackButton(
              title: 'Doctor Archive',
              onTap: widget.navigateToHome,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            child: SearchField(
              onSearchChanged: _onSearchChanged,
              onSortSelected: _onSortSelected,
              sortType: sortType,
              menuItems: const [
                PopupMenuItem<String>(
                  value: 'date',
                  child: Text('Sort by Date'),
                ),
                PopupMenuItem<String>(
                  value: 'patient',
                  child: Text('Sort by Patient'),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
              child: const SectionHeader(
                title: 'History of previous treatments:',
              )),
          Expanded(
            child: displayedTreatmentHistory.isNotEmpty
                ? Container(
              margin: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 5.h),
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 10.h),
                itemCount: displayedTreatmentHistory.length,
                itemBuilder: (context, index) {
                  final item = displayedTreatmentHistory[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                    ),
                    child: CardWidget(
                      title: item['patient_name']!,
                      subtitle: formatDateTime(item['created_at'])!,
                      iconAsset: 'assets/svgs/treatment.svg',
                      arrowAsset: 'assets/svgs/arrow.svg',
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DoctorPrescriptionScreen(
                              prescriptionId: item['id']!,
                            )));
                      },
                    ),
                  );
                },
              ),
            )
                : Center(
              child: Container(
                width: 280.w,
                child: Text(
                  'No records available at the moment. Please check back after your next consultation with a patient.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    fontSize: 11.sp,
                    color: Color(0xFF9B9B9B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
