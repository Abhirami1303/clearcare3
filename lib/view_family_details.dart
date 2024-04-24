import 'package:clearcare/services/family_service.dart';
import 'package:flutter/material.dart';

import 'models/family_model.dart';

class ViewFamilyMembersPage extends StatefulWidget {
  final String? token;

  const ViewFamilyMembersPage({Key? key, this.token}) : super(key: key);

  @override
  _ViewFamilyMembersPageState createState() => _ViewFamilyMembersPageState();
}

class _ViewFamilyMembersPageState extends State<ViewFamilyMembersPage> {
  List<Map<String, dynamic>> familyMembers = [];

  Future<void> fetchFamilyDetails(String token) async {
    print("Inside fetchFamilyDetails");
    try {
      List<Family> family = await FamilyService().fetchFamilyDetails(token);
      for (var element in family) {
        print(
            "${element.id} ${element.name} ${element.email} ${element.phoneNumber}");
      }
      setState(() {
        familyMembers = family
            .map((family) => {
                  'id': family.id,
                  'name': family.name,
                  'email': family.email,
                  'phoneNumber': family.phoneNumber
                })
            .toList();
      });
      for (var element in familyMembers) {
        print(
            "${element["id"]} ${element["name"]} ${element["email"]} ${element["phoneNumber"]}");
      }
    } catch (e) {
      print('Error fetching medicines: $e');
    }
  }

  void editFamilyMember(int index) {
    // Implement edit functionality if needed (future enhancement)
  }
  @override
  void initState() {
    super.initState();
    print("Inside InitState : ${widget.token}");
    if (widget.token != null) {
      fetchFamilyDetails(widget.token!);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View family',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF6899CA),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: familyMembers.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(familyMembers[index]['name'] ?? ""),
              subtitle: Text(
                'Email: ${familyMembers[index]['email'] ?? ""}\nPhone Number: ${familyMembers[index]['phoneNumber'] ?? ""}',
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => editFamilyMember(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
