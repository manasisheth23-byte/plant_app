// ignore_for_file: avoid_print

import 'dart:convert';


import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/models/invoiceDetailsModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceDetailsRequest {
  String? scanned;
  Future<InvoiceDetailsModel?> getInvoiceDetails(
      String mid,
      String docid,
      String flag,
      String slid,
      String orgid,
      // String? tId,
      String? projId) async {
   //const String urlbase ="http://10.0.0.223:8532/ERPAPI/API/";
    //const url = "${ApiEndpoints.baseUrl}LOTDetails/GetBarCodeScanDetails";
    const url = "${AppConfig.BASE_URL}LOTDetails/GetBarCodeScanDetails";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("USERID");

    // Define Json Body
    final Map<String, dynamic> requestBody = {
      "XMLFILE": {
        "FLAG": flag,
        "USERID": getUserId,
        "ORGSTRUCID": orgid,
        "MID": mid,
        "DOCID": docid,
        // "TID": tId,
        "PROJID": projId,
        "SLID": slid
      }
    };

    // Make Response
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    try {
      if (response.statusCode == 200) {
        // print(response.body);
        var data = jsonDecode(response.body);
        final model = InvoiceDetailsModel.fromJson(data);

        print(model.tRANSACTIONDETAILS);
        print(model.tRANSACTIONDETAILS?.tRANSACTIONS?.length);
        print(data);
        // scanned = data['TRANSACTIONDETAILS']['TRANSACTIONS'][0]['Scanned'];
        // print(scanned);
        return InvoiceDetailsModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response?> InvoiceDetails(
      String mid,
      String docid,
      String flag,
      String slid,
      String orgid,
      // String? tId,
      String? projId) async {
    //const String urlbase ="http://10.0.0.223:8532/ERPAPI/API/";
    const url = "${AppConfig.BASE_URL}LOTDetails/GetBarCodeScanDetails";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("USERID");
    var controlno = prefs.getString('CONTROLNO');
    late Map<String, dynamic> requestBody;
    // Define Json Body
    if(flag =="15"){
      String? orgstID = prefs.getString('ORGSTRUCTID');
      requestBody = {
        "XMLFILE": {
          "FLAG": flag,
          "USERID": getUserId,
          "ORGSTRUCID": orgstID,
          "MID": mid,
          "DOCID": docid,
          // "TID": tId,
          "CONTROLNO":controlno,
          "PROJID": "",
          "SLID": "",


        }
      };
    }else{
      requestBody = {
        "XMLFILE": {
          "FLAG": flag,
          "USERID": getUserId,
          "ORGSTRUCID": orgid,
          "MID": mid,
          "DOCID": docid,
          // "TID": tId,
          "CONTROLNO":controlno,
          "PROJID": projId,
          "SLID": slid

        }
      };
    }

print(url);
print(jsonEncode(requestBody));
    // Make Response
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    try {
      if (response.statusCode == 200) {
        print(response.body);
        // var data = jsonDecode(response.body);
        // print(data);
        // scanned = data['TRANSACTIONDETAILS']['TRANSACTIONS'][0]['Scanned'];
        // print(scanned);
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  Future<http.Response?> InvoiceDetailsANS(
      String mid,
      String docid,
      String flag,
      String slid,
      String orgid,
      // String? tId,
      String? projId) async {
    //const String urlbase ="http://10.0.0.223:8532/ERPAPI/API/";
    const url = "${AppConfig.BASE_URL}LOTDetails/GetBarCodeScanDetails";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("USERID");
    var controlno = prefs.getString('CONTROLNO');
    late Map<String, dynamic> requestBody;
    // Define Json Body
    if(flag =="15"){
      String? orgstID = prefs.getString('ORGSTRUCTID');
      requestBody = {
        "XMLFILE": {
          "FLAG": flag,
          "USERID": getUserId,
          "ORGSTRUCID": orgstID,
          "MID": "",
          "DOCID": docid,
          // "TID": tId,
          "CONTROLNO":controlno,
          "PROJID": "",
          "SLID": "",
          "BARCODE":mid,

        }
      };
    }else{
      requestBody = {
        "XMLFILE": {
          "FLAG": flag,
          "USERID": getUserId,
          "ORGSTRUCID": orgid,
          "MID": mid,
          "DOCID": docid,
          // "TID": tId,
          "CONTROLNO":controlno,
          "PROJID": projId,
          "SLID": slid

        }
      };
    }

    print(url);
    print(jsonEncode(requestBody));
    // Make Response
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    try {
      if (response.statusCode == 200) {
        print(response.body);
        // var data = jsonDecode(response.body);
        // print(data);
        // scanned = data['TRANSACTIONDETAILS']['TRANSACTIONS'][0]['Scanned'];
        // print(scanned);
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

}
