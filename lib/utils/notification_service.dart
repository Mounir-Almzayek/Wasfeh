import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../main.dart';
import '../widget/Dialogs/MedicationNotiDialog.dart';
import 'Medication.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    // Create notification channel
    await _createNotificationChannel();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_channel_id',
      'Medication Reminders',
      description: 'Reminders to take your medications on time',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleNotificationTap(String? payload) async {
    final context = globalNavigatorKey.currentContext;
    if (context != null && payload != null) {
      // Extract medication details from the payload
      final data = jsonDecode(payload);
      final medicineName = data['medicine'];
      final medicationId = data['id'];

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MedicationNotiDialog(
            medicineName: medicineName ?? 'Unknown',
            medicationId: medicationId ?? 0,
          ),
        ),
      );
    }
  }

  Future<void> scheduleNextMedicationNotification({
    required String medicineName,
    required DateTime lastTakenTime,
    required Duration interval,
    required int id,
  }) async {
    DateTime nextDoseTime = lastTakenTime.add(interval);
    final now = DateTime.now();

    if (nextDoseTime.isBefore(now)) {
      nextDoseTime = now.add(interval);
    }

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Medication Reminder',
      'It\'s time to take your $medicineName.',
      tz.TZDateTime.from(nextDoseTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel_id',
          'Medication Reminders',
          channelDescription: 'Reminders to take your medications on time',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'medicine': medicineName, 'id': id}),
    );

    // Store the notification details in SharedPreferences
    await _storeMedicationReminder(medicineName, id, nextDoseTime);
  }

  Future<void> cancelNotificationsForMedication(int id, int totalDoses) async {
    for (int i = 0; i < totalDoses; i++) {
      await flutterLocalNotificationsPlugin.cancel(id + i);
    }
  }

  Future<void> updateMedicationList(List<Medication> medications) async {
    await flutterLocalNotificationsPlugin.cancelAll();

    for (var medication in medications) {
      final lastTakenTime = medication.lastTakenTime;
      final interval = medication.interval;
      final id = medication.id;

      await scheduleNextMedicationNotification(
        medicineName: medication.name,
        lastTakenTime: lastTakenTime,
        interval: interval,
        id: id,
      );
    }
  }

  void scheduleNextMedicationReminder(String medicineName) {
    final lastTakenTime = DateTime.now(); // Last taken time
    final interval = Duration(hours: 1); // Interval between doses
    final id = -1;

    scheduleNextMedicationNotification(
      medicineName: medicineName,
      lastTakenTime: lastTakenTime,
      interval: interval,
      id: id,
    );
  }

  Future<void> testNotification() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel_id',
          'Medication Reminders',
          channelDescription: 'Reminders to take your medications on time',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }

  Future<void> _storeMedicationReminder(String medicineName, int medicationId, DateTime time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? medicationsTaken = prefs.getStringList('medications_taken') ?? [];

    // Remove existing entry with the same medication ID
    medicationsTaken.removeWhere((entry) {
      final decodedEntry = jsonDecode(entry) as Map<String, dynamic>;
      return decodedEntry['medication_id'] == medicationId;
    });

    // Add the new entry
    Map<String, dynamic> newEntry = {
      'time': time.toIso8601String(),
      'medicine': medicineName,
      'medication_id': medicationId, // Store the medication ID
    };

    medicationsTaken.add(jsonEncode(newEntry));
    await prefs.setStringList('medications_taken', medicationsTaken);
  }

  Future<List<Map<String, dynamic>>> getStoredMedicationsTaken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? medicationsTaken = prefs.getStringList('medications_taken') ?? [];
    return medicationsTaken.map((entry) => jsonDecode(entry) as Map<String, dynamic>).toList();
  }
}