import 'dart:convert';
import 'package:clearcare/home.dart';
import 'package:clearcare/models/family_model.dart';
import 'package:clearcare/models/medicine_model.dart';
import 'package:clearcare/models/user.dart';
import 'package:clearcare/providers/user_provider.dart';
import 'package:clearcare/services/family_service.dart';
import 'package:clearcare/services/medicine_service.dart';
import 'package:clearcare/utils/constants.dart';
import 'package:clearcare/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
//import 'package:your_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'notification_Service.dart';

class AuthService {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        token: '',
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Account created! Login with the same credentials!',
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signin'),
        //Uri.parse('${Constants.uri}/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userProvider.setUser(res.body);
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data
  void getUserData(
    BuildContext context,
  ) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('${Constants.uri}/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('${Constants.uri}/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
        );

        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // to call MedicineService
  void addMedicine({
    required BuildContext context,
    required String token,
    required Medicine medicine,
  }) async {
    try {
      await NotificationService.initializeNotifications();
      MedicineService medicineService = MedicineService();
      bool response = await medicineService.addMedicine(token, medicine);
      if (response) {
        scheduleNotifications(medicine);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // to call FamilyService
  Future<bool> addFamily({
    required BuildContext context,
    required String token,
    required Family family,
  }) async {
    print("add family");
    try {
      FamilyService familyService = FamilyService();
      bool responseStatus = await familyService.addFamily(token, family);
      return responseStatus;
    } catch (e) {
      showSnackBar(context, e.toString());
      return false;
    }
  }

  void scheduleNotifications(Medicine medicine) async {
    int quantity = medicine.quantity;
    int dayCount = 0;
    while (quantity > 0) {
      for (String timeString in medicine.timings) {
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

        scheduledDateTime = scheduledDateTime.add(Duration(days: dayCount));
        print("scheduled Time : $scheduledDateTime | dayCount : $dayCount");
        if (quantity > 0) {
          quantity--;
          await NotificationService.scheduleNotification(
              0, "Time to take medicine", medicine.name, scheduledDateTime);
          /*medicineSchedule.notificationIds.add(notificationId);*/
        } else {
          break;
        }
      }
      dayCount++;
      //print("incremented dayCount : $dayCount");
    }
  }
}
