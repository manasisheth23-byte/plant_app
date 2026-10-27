import 'package:flutter/material.dart';
import '../models/SalesOrderListModel.dart';
import '../services/ApiProvider.dart';

class SoListProvider with ChangeNotifier {
  SoListModel? _soListModel;
  bool _loading = false;
  String _errorMessage = '';

  SoListModel? get soListModel => _soListModel;
  bool get loading => _loading;
  String get errorMessage => _errorMessage;

  final ApiProvider _apiService = ApiProvider();

  Future<void> fetchSoList() async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _soListModel = await _apiService.fetchSoList();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
