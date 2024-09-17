import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Constants/Address.dart';
import '../../utils/Medication.dart';
import '../../utils/notification_service.dart';
import '../../widget/CardWidget.dart';
import '../../widget/Dialogs/StartingWithMedicineDialog.dart';
import '../../widget/Dialogs/TakeMedicineDialog.dart';
import '../../widget/HealthcareJourneyWidget.dart';
import '../../widget/SectionHeader.dart';
import '../../widget/UserCard.dart';
import 'PrescriptionScreen.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String _userName = 'Loading...';
  List<Map<String, dynamic>> _medicineList = [];
  List<Medication> _activeMedications = [];
  List<Map<String, dynamic>> _treatmentHistory = [];
  bool _isLoadingMedicines = true;
  bool _isLoadingTreatments = true;

  bool _isRefreshingMedicines = false;
  bool _isRefreshingTreatments = false;

  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadMedicines();
    _loadTreatments();
    _sortMedicineList();
    _sortTreatmentHistory();
  }

  Future<void> _loadMedicines() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedMedicines = prefs.getString('_activeMedicines');


    if (storedMedicines != null) {
      try {
        List<dynamic> jsonResponse = jsonDecode(storedMedicines);

        setState(() {
          for (var prescription in jsonResponse) {
            for (var item in prescription['prescription_items']) {
              _medicineList.add({
                'medicine': item['name'],
                'dosage': item['dosage'],
                'last_taken': item['last_taken'],
              });
            }
          }
          _isLoadingMedicines = false;
        });
      } catch (e) {
        setState(() {
          _medicineList = [];
          _isLoadingMedicines = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing medicine data: ${e.toString()}')),
        );
      }
      _sortMedicineList();
    } else {
      _fetchMedicines();
    }
  }


  Future<void> _loadTreatments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedTreatments = prefs.getString('_activeTreatments');

    if (storedTreatments != null) {
      try {
        setState(() {
          _treatmentHistory = List<Map<String, dynamic>>.from(
            (jsonDecode(storedTreatments) as List<dynamic>).map((item) => {
              'id': item['id']?.toString() ?? 'Unknown ID',
              'doctor_name': item['doctor']['user']['name']?.toString() ?? 'Unknown Doctor',
              'created_at': item['created_at']?.toString() ?? 'Unknown Date',
            }),
          );
          _isLoadingTreatments = false;
        });
      } catch (e) {
        // Handle JSON parsing error
        setState(() {
          _treatmentHistory = [];
          _isLoadingTreatments = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing treatment data: ${e.toString()}')),
        );
      }
    } else {
      _fetchTreatments(); // Fetch from API if not available in SharedPreferences
    }
  }


  Future<void> _loadUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('name');
    setState(() {
      _userName = name ?? 'User';
    });
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoadingMedicines = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      final String apiUrl = '$BASE_URL/active_prescription_items';
      var request = http.MultipartRequest('GET', Uri.parse(apiUrl));

      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        await prefs.setString('_activeMedicines', responseBody);

        setState(() {
          _medicineList = [];
          _activeMedications = [];

          for (var prescription in jsonResponse) {
            for (var item in prescription['prescription_items']) {
              _medicineList.add({
                'medicine': item['name'],
                'dosage': item['dosage'],
                'last_taken': item['last_taken'],
                'id': item['id'],
              });
              if (item['last_taken'] != null) {
                _activeMedications.add(
                  Medication(
                    name: item['name'],
                    lastTakenTime: DateTime.parse(item['last_taken']),
                    interval: Duration(hours: item['dosage']),
                    id: item['id'],
                  ),
                );
              }
            }
          }
        });
        NotificationService().updateMedicationList(_activeMedications);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load data: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoadingMedicines = false;
        _isRefreshingMedicines = false;
        _sortMedicineList;
      });
    }
  }

  Future<void> _fetchTreatments() async {
    setState(() {
      _isLoadingTreatments = true;
    });
    await Future.delayed(Duration(seconds: 3)); // Simulated delay

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      final String apiUrl = '$BASE_URL/active_prescription_items';

      var request = http.MultipartRequest('GET', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        await prefs.setString('_activeTreatments', responseBody);

        setState(() {
          _treatmentHistory = List<Map<String, dynamic>>.from(
            (jsonResponse as List<dynamic>).map(
                  (item) => {
                'id': item['id'].toString(),
                'doctor_name': item['doctor']['user']['name'] ?? 'Unknown Doctor',
                'created_at': item['created_at'].toString(),
              },
            ),
          );
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
        _isLoadingTreatments = false;
        _isRefreshingTreatments = false;
      });
    }
  }

  // Function to sort the medicine list
  void _sortMedicineList() {
    _medicineList.sort((a, b) {
      DateTime? aLastTaken = a['last_taken'] != null ? DateTime.parse(a['last_taken']) : null;
      DateTime? bLastTaken = b['last_taken'] != null ? DateTime.parse(b['last_taken']) : null;
      int aDosage = a['dosage'];
      int bDosage = b['dosage'];

      DateTime? aNextReminder = aLastTaken != null ? aLastTaken.add(Duration(hours: aDosage)) : null;
      DateTime? bNextReminder = bLastTaken != null ? bLastTaken.add(Duration(hours: bDosage)) : null;

      // Medications not started come first
      if (aLastTaken == null && bLastTaken != null) {
        return -1;
      } else if (aLastTaken != null && bLastTaken == null) {
        return 1;
      } else if (aLastTaken == null && bLastTaken == null) {
        return 0;
      }

      // Medications that have passed their time come next, sorted by how long ago they were missed
      if (aNextReminder!.isBefore(DateTime.now()) && bNextReminder!.isBefore(DateTime.now())) {
        return bNextReminder.compareTo(aNextReminder); // Sort by the oldest missed first
      } else if (aNextReminder.isBefore(DateTime.now())) {
        return -1; // a is missed, so it comes first
      } else if (bNextReminder!.isBefore(DateTime.now())) {
        return 1; // b is missed, so it comes first
      }

      // Medications not yet due come last, sorted by the closest upcoming time
      return aNextReminder.compareTo(bNextReminder);
    });
  }

  // Function to sort treatment history (newest to oldest)
  void _sortTreatmentHistory() {
    _treatmentHistory.sort((a, b) {
      DateTime aCreatedAt = DateTime.parse(a['created_at']);
      DateTime bCreatedAt = DateTime.parse(b['created_at']);
      return bCreatedAt.compareTo(aCreatedAt); // Newest first
    });
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  bool isBeforeCurrentTime(DateTime medicationTime) {
    return medicationTime.isBefore(DateTime.now());
  }

  String timeSinceLastTaken(DateTime medicineTime) {
    Duration difference = DateTime.now().difference(medicineTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  void updateMed(){
    setState(() {
      _isRefreshingTreatments = true;
    });
    _fetchMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 5.h),
              child: UserCard(name: _userName),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
              child: HealthcareJourneyWidget(
                text: 'Simplify Your Healthcare Journey!',
              ),
            ),

            // Daily Reminders Section with Refresh Button
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader(
                    title: 'Daily Reminders:',
                  ),
                  AnimatedRotation(
                    turns: _isRefreshingMedicines ? 1 : 0,
                    duration: Duration(seconds: 1),
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _isRefreshingMedicines
                          ? null
                          : () {
                              setState(() {
                                _isRefreshingMedicines = true;
                              });
                              _fetchMedicines();
                              },
                    ),
                  ),
                ],
              ),
            ),
            _isLoadingMedicines
                ? Container(
                    padding: EdgeInsets.all(20.h),
                    child: Text(
                      'Loading medicines...',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _medicineList.isNotEmpty
                    ? Column(
                        children: _medicineList.map((item) {
                          return Container(
                            margin: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 5.h),
                            child: CardWidget(
                              title: item['medicine']!,
                              subtitle: item['last_taken'] != null
                                  ? isBeforeCurrentTime(DateTime.parse(item['last_taken']).add(Duration(hours: item['dosage'])))
                                    ? 'Medication was missed ${timeSinceLastTaken(DateTime.parse(item['last_taken']).add(Duration(hours: item['dosage'])))} ago'
                                    : 'Next reminder at ${DateFormat('h:mm a').format(DateTime.parse(item['last_taken']).add(Duration(hours: item['dosage'])))}'
                                  : 'Not taken yet',
                              iconAsset: 'assets/svgs/pill.svg',
                              arrowAsset: item['last_taken'] != null
                                  ? isBeforeCurrentTime(DateTime.parse(item['last_taken']).add(Duration(hours: item['dosage'])))
                                    ? 'assets/svgs/taken.svg'
                                    : ''
                                  : 'assets/svgs/start.svg',
                              onPressed: () {
                                if(item['last_taken'] == null){
                                  StartingWithMedicineDialog.showMedicationDialog(
                                    context: context,
                                    medicationId: item['id'],
                                    onConfirm: updateMed,
                                  );
                                }else if (isBeforeCurrentTime(DateTime.parse(item['last_taken']).add(Duration(hours: item['dosage'])))){
                                  TakeMedicineDialog.showTakeMedicineDialog(
                                      context: context,
                                      medicineName: item['medicine']!,
                                      medicationId: item['id'],
                                      timePassed: timeSinceLastTaken(DateTime.parse(item['last_taken']).add(Duration(hours: item['dosage']))),
                                      onConfirm: updateMed
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                      )
                    : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(30.w, 10.h, 30.w, 5.h),
                        child: Text(
                          'No information available at the moment. Please use the app more frequently to update and review details from your doctor.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                            color: Color(0xFF9B9B9B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
            // Treatments Section
            Container(
              padding: EdgeInsets.fromLTRB(120.w, 40.h, 0.w, 40.h),
              child: SizedBox(
                width: 150.w,
                child: SvgPicture.asset(
                  'assets/svgs/relaxed_personality.svg',
                ),
              ),
            ),
            // Active Treatments Section with Refresh Button
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader(
                    title: 'Active treatments:',
                  ),
                  AnimatedRotation(
                    turns: _isRefreshingTreatments ? 1 : 0,
                    duration: Duration(seconds: 1),
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _isRefreshingTreatments
                          ? null
                          : () {
                              setState(() {
                                _isRefreshingTreatments = true;
                              });
                              _fetchTreatments();
                            },
                    ),
                  ),
                ],
              ),
            ),
            _isLoadingTreatments
                ? Container(
                    padding: EdgeInsets.all(20.h),
                    child: Text(
                      'Loading treatments...',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _treatmentHistory.isNotEmpty
                    ? Column(
                        children: _treatmentHistory.map((item) {
                          return Container(
                            margin: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 5.h),
                            child: CardWidget(
                              title: item['doctor_name']!,
                              subtitle: formatDateTime(item['created_at']),
                              iconAsset: 'assets/svgs/treatment.svg',
                              arrowAsset: 'assets/svgs/arrow.svg',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PrescriptionScreen(
                                      prescriptionId: item['id'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      )
                    : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(30.w, 10.h, 30.w, 5.h),
                        child: Text(
                          'There are currently no records to display. To see more information, please check back after your next doctor visit or use the app regularly.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                            color: Color(0xFF9B9B9B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
            SizedBox(
              height: 200.h,
            ),
          ],
        ),
      ),
    );
  }
}