import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config.dart';
import '../models/sotable_dropdown_nodel.dart';


class ApiServiceFilterDropDown {
  static const String _baseUrl = '${AppConfig.RAW_BASE_URL}/erpapi/api/SalesOrder/';

  Future<SoTableDropdownModel> fetchSOTableDropdownData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? UserID = prefs.getString('USERID');

    final url = Uri.parse('${_baseUrl}GetSOTable/')
        .replace(queryParameters: {
      'Orgstrucid': '4',
      'USERID': UserID,
      'FLAG': '0'
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("So Table DropDown Data Call Successfully***********");
      print("Dropdown data status: ${response.statusCode}");
      return SoTableDropdownModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load dropdown data: ${response.statusCode}');
    }
  }
}