import 'package:flutter/material.dart';
import 'package:clearcare/models/medicine_model.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> _medicines = []; // Initialize with an empty list of medicines

  List<Medicine> get medicines => _medicines;

  void setMedicines(List<Medicine> medicines) {
    _medicines = medicines;
    notifyListeners();
  }

  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    notifyListeners();
  }

  void removeMedicine(String medicineId) {
    _medicines.removeWhere((medicine) => medicine.id == medicineId);
    notifyListeners();
  }
}
