import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/web_view_model.dart';



class Konowledgeprovider extends ChangeNotifier {
  bool? _isLoading;
  bool? get isLoading => _isLoading;


  WebViewModel? _webViewModel;
  WebViewModel? get webViewModel => _webViewModel;


  Future<void> webViewAPi(int id, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print(token);

    //  final response = await http.get(Uri.parse('KnowledgeBase/GetSolution?SOLID=$id&DESC=""'),
      final response = await http.get(Uri.parse('http://koelconnectapi.kirloskar.com/API/KnowledgeBase/GetSolution?SOLID=$id&DESC=""'),

        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
         // 'X-Auth-Token': token.toString(),
          'X-Auth-Token': "ce288443-02c8-4621-8aca-30d493eccdc4",
          HttpHeaders.acceptEncodingHeader: 'gzip',
        },
      );

      print(response);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        // Check if the response is Gzip-encoded
        if (response.headers.containsKey(HttpHeaders.contentEncodingHeader) ||
            response.headers[HttpHeaders.contentEncodingHeader] == 'Gzip') {
          // Decode the Gzip-encoded response
          final List<int> gzipBytes = response.bodyBytes;
          final List<int> resultBytes = GZipCodec().decode(gzipBytes);

          final result = utf8.decode(resultBytes);
          var data = jsonDecode(result);

          // Now 'result' contains the decoded response
          print(result);
          print(data);
          _webViewModel = WebViewModel.fromJson(data);
          notifyListeners();
        } else {
          // If the response is not Gzip-encoded, you can handle it accordingly
          print(response.body);
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}