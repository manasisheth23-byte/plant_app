import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app_config.dart';
import '../../models/projectwise_detail_order_data_response.dart';
import '../../models/projectwise_response_model.dart';
import '../../services/ApiProvider.dart';


class ProjectWiseDetailtProvider with ChangeNotifier {
  ProjectWiseDetailResponse? _apiResponse;
  bool _isLoading = false;
  List<MasterProjectNo> _projList = [];
  int? _selectedProjId;

  List<MasterProjectNo> get projList => _projList;
  int? get selectedProjId => _selectedProjId;
  bool get isLoading => _isLoading;

  void resetSelectedProjId() {
    _selectedProjId = null;
    _projList = [];
    notifyListeners();
  }

  Future<void> fetchMasterProjectData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _apiResponse = await ApiProvider().fetchMasterProjectData();
      _projList = _apiResponse!.masterProjectNo;
    } catch (e) {

      print("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedProjId(int? projId) {
    _selectedProjId = projId;
    notifyListeners();
  }

  List<ProjectDetailSalesOrder> _orders = [];
  bool _isLoadingSalesOrder = false;

  List<ProjectDetailSalesOrder> get orders => _orders;
  bool get isLoadingSalesOrder => _isLoadingSalesOrder;

  Future<void> fetchOrders(Map<String, dynamic> requestData) async {
    _isLoadingSalesOrder = true;
    notifyListeners();
     const String _apiUrl = AppConfig.RAW_BASE_URL +'/erpapi/api/SalesOrder/GetProjectWiseDetails';
print(_apiUrl);
print(json.encode(requestData));
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      print(response);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Status'] == 'true') {
          List<ProjectDetailSalesOrder> loadedOrders = [];
          for (var order in data['Data']) {
            loadedOrders.add(ProjectDetailSalesOrder.fromJson(order));
          }
          _orders = loadedOrders;
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
      throw error;
    } finally {
      _isLoadingSalesOrder = false;
      notifyListeners();
    }
  }
}
