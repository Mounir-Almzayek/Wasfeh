import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Constants/Address.dart';
import '../../widget/CardWidget.dart';
import '../../widget/PageHeaderWithBackButton.dart';
import '../../widget/Field/SearchField.dart';
import '../../widget/SectionHeader.dart';
import 'PrescriptionScreen.dart';

class PatientArchivePage extends StatefulWidget {
  final VoidCallback navigateToHome;

  const PatientArchivePage({super.key, required this.navigateToHome});

  @override
  _PatientArchivePageState createState() => _PatientArchivePageState();
}

class _PatientArchivePageState extends State<PatientArchivePage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
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
    // Step 1: Load cached data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('patientArchive');


    if (cachedData != null) {
      // If cached data exists, use it to populate the list
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

      final String apiUrl = '$BASE_URL/${role}/prescriptions';
      var request = http.MultipartRequest('GET', Uri.parse(apiUrl));

      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody)['data'];

        await prefs.setString('patientArchive', jsonEncode(jsonResponse));

        setState(() {
          fullTreatmentHistory = List<Map<String, String>>.from(
            jsonResponse.map(
                  (item) => {
                'id': item['id'].toString(),
                'doctor_name': item['doctor_name'].toString(),
                'created_at': item['created_at'].toString(),
              },
            ),
          );
          displayedTreatmentHistory = List.from(fullTreatmentHistory);
        });
      } else if (response.statusCode == 422) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        final errors = jsonResponse['errors'];
        String errorMessage = '';

        if (errors != null && errors is Map<String, dynamic>) {
          errors.forEach((key, value) {
            errorMessage += '$key: ${value[0]}\n';
          });
        } else {
          errorMessage = 'Failed to load data: ${response.reasonPhrase}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
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

  Future<void> _onRefresh() async {
    await _fetchData();
    _refreshController.refreshCompleted();
  }

  void _onSearchChanged(String query) {
    setState(() {
      displayedTreatmentHistory = fullTreatmentHistory.where((treatment) {
        final doctor = treatment['doctor_name']!.toLowerCase();
        final input = query.toLowerCase();
        return doctor.contains(input);
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
      } else if (sortType == 'doctor') {
        displayedTreatmentHistory.sort((a, b) => a['doctor_name']!.compareTo(b['doctor_name']!));
      }
    });
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 20.h),
            child: PageHeaderWithBackButton(
              title: 'Patient Archive',
              onTap: widget.navigateToHome,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            child: SearchField(
              onSearchChanged: _onSearchChanged,
              onSortSelected: _onSortSelected,
              sortType: sortType,
              menuItems: [
                PopupMenuItem<String>(
                  value: 'date',
                  child: Text('Sort by Date'),
                ),
                PopupMenuItem<String>(
                  value: 'doctor',
                  child: Text('Sort by Doctor'),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
              child: SectionHeader(
                title: 'History of previous treatments:',
              )),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
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
                        title: 'Dr. ' + item['doctor_name']!,
                        subtitle: formatDateTime(item['created_at']),
                        iconAsset: 'assets/svgs/treatment.svg',
                        arrowAsset: 'assets/svgs/arrow.svg',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PrescriptionScreen(prescriptionId: '${item['id']}')));
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
                    'No records available at the moment. Please use the app regularly to update your treatment history or check back after your next doctor visit.',
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
          ),
        ],
      ),
    );
  }
}