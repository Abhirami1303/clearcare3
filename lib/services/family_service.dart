// family_service.dart
import 'dart:convert';
import 'package:clearcare/models/family_model.dart';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class FamilyService {
  static const String baseUrl = 'http://{Constants.uri}/api/add-family-member';

  Future<bool> addFamily(String token, Family family) async {
    final response = await http.post(
      Uri.parse('${Constants.uri}/api/add-family-member'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'name': family.name,
        'email': family.email,
        'phoneNumber': family.phoneNumber
      }),
    );

    if (response.statusCode == 201) {
      // Family added successfully
      return true;
    } else {
      throw Exception('Failed to add family');
    }
  }

  Future<List<Family>> fetchFamilyDetails(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.uri}/api/family-members'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print("fetchfamily : $jsonData");
      return jsonData.map((familyJson) => Family.fromJson(familyJson)).toList();
    } else {
      throw Exception(
          'Failed to load families. Status code: ${response.statusCode} $response ');
    }
  }
}
