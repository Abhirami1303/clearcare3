// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'dart:convert';
import 'package:clearcare/models/medicine_model.dart';
import 'package:clearcare/utils/constants.dart';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicineService {
  // Uri.parse('${Constants.uri}/api/medicines'),
  Future<bool> addMedicine(String token, Medicine medicine) async {
    final response = await http.post(
      Uri.parse('${Constants.uri}/api/medicines'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'name': medicine.name,
        'quantity': medicine.quantity,
        'expiryDate': medicine.expiryDate.toIso8601String(),
        'timings': medicine.timings,
      }),
    );
    bool responseStatus = false;
    if (response.statusCode == 200) {
      // Medicine added successfully
      responseStatus = true;
    } else {
      print("response ${response.body}");
      responseStatus = false;
      throw Exception(
          'Failed to add medicine. Status code: ${response.statusCode}');
    }
    return responseStatus;
  }

  // Future<List<Medicine>> fetchMedicines(String token) async {
  //   final response = await http.get(
  //     Uri.parse('${Constants.uri}/api/medicines'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'x-auth-token': token,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonData = jsonDecode(response.body);
  //     return jsonData
  //         .map((medicineJson) => Medicine.fromJson(medicineJson))
  //         .toList();
  //   } else {
  //     throw Exception(
  //         'Failed to load medicines. Status code: ${response.statusCode} $response ');
  //   }
  // }

  Future<List<Medicine>> fetchMedicines(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.uri}/api/getmedicines'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      List<Medicine> data = jsonData
          .map((medicineJson) => Medicine.fromJson(medicineJson))
          .toList();
      //scheduleNotifications(data);
      return jsonData
          .map((medicineJson) => Medicine.fromJson(medicineJson))
          .toList();
    } else {
      throw Exception(
          'Failed to load medicines. Status code: ${response.statusCode} $response ');
    }
  }

  void scheduleNotifications(List<Medicine> medicine) {
    if (medicine == null) {
      return;
    }
    int quantity = medicine[0].quantity;
    while (quantity > 0) {
      int dayCount = 0;
      for (String timeString in medicine[0].timings) {
        List<String> parts = timeString.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]);
        String meridiem = parts[1].split(' ')[1];
        if (meridiem == 'PM' && hour != 12) {
          hour += 12;
        } else if (meridiem == 'AM' && hour == 12) {
          hour = 0;
        }

        DateTime now = DateTime.now();

        DateTime scheduledDateTime =
            DateTime(now.year, now.month, now.day, hour, minute);
        scheduledDateTime.add(Duration(days: dayCount));
        print("scheduled Time : $scheduledDateTime");
        if (quantity > 0) {
          quantity--;
          /* int notificationId = scheduleNotification(timeString, Med, medicineSchedule.name);
      medicineSchedule.notificationIds.add(notificationId);*/
        } else {
          break;
        }
      }
      dayCount++;
    }
  }
}
