import 'package:clearcare/models/medicine_model.dart';
//import 'package:clearcare/services/notification_Service.dart';
import 'package:flutter/material.dart';
import 'package:clearcare/services/medicine_service.dart'; // Import your medicine service

class ViewMedicineDetailsPage extends StatefulWidget {
  final String? token;

  const ViewMedicineDetailsPage({Key? key, this.token}) : super(key: key);

  @override
  _ViewMedicineDetailsPageState createState() =>
      _ViewMedicineDetailsPageState();
}

class _ViewMedicineDetailsPageState extends State<ViewMedicineDetailsPage> {
  List<Map<String, dynamic>> medicineDetails = [];

  Future<void> fetchMedicines(String token) async {
    //print("Inside fetchMedicine");
    //print("Active ${await NotificationService.getActiveNotifications()}");
    //await NotificationService.showNotification(id: 0,body: "Sample",title: "Sample",payLoad: "Sample");
    try {
      List<Medicine> medicines = await MedicineService().fetchMedicines(token);
      setState(() {
        medicineDetails = medicines
            .map((medicine) => {
                  'id': medicine.id,
                  'name': medicine.name,
                  'quantity': medicine.quantity,
                  'expiryDate': medicine.expiryDate.toString(),
                  'timings': medicine.timings,
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching medicines: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    print("Inside InitState : ${widget.token}");
    if (widget.token != null) {
      fetchMedicines(widget.token!);
    } else {
      // Handle token not available, e.g., redirect to login screen
    }
  }

  void editMedicine(int index) {
    //edit medicine
  }

  void updateMedicine() {
    // update medicine
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View medicines',
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
        itemCount: medicineDetails.length,
        itemBuilder: (context, index) {
          print("timing : ${medicineDetails[index]['timings']}");
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(medicineDetails[index]['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${medicineDetails[index]['id']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Quantity: ${medicineDetails[index]['quantity']}'),
                  Text('Expiry Date: ${medicineDetails[index]['expiryDate']}'),
                  Text(
                      'Timings: ${medicineDetails[index]['timings'].join(', ')}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => editMedicine(index),
              ),
            ),
          );
        },
      ),
      bottomSheet: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'ID'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Medicine Name'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Expiry Date'),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantity'),
                  ),
                  TextField(
                    decoration: InputDecoration(
                        labelText: 'Timings (Separated by comma)'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
