import 'package:flutter/material.dart';

class PlantProvider extends ChangeNotifier {
  String _plantName = '';

  String get plantName => _plantName;
  String _companyName = '';

  String get companyName => _companyName;
  void setPlantName(String name) {
    _plantName = name;
    notifyListeners();
  }
  void setCompanyName(String name) {
    _companyName = name;
    notifyListeners();
  }
  void clearPlant() {
    _plantName = '';
    notifyListeners();
  }
}
