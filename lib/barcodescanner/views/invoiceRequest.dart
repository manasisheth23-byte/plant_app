import 'dart:convert';


import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/barcodescanner/models/invoiceModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceRequest {
  Future<InvoiceModel?> getInvoice(
      String orgID15, String invoiceFlag, String mId, String docId) async {
    const url = "${AppConfig.BASE_URL}LOTDetails/GetBarCodeScanDetails";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("UserId");

    // Define Json Body
    final Map<String, dynamic> requestBody = {
      "XMLFILE": {
        "FLAG": invoiceFlag,
        "USERID": getUserId,
        "ORGSTRUCID": orgID15,
        "MID": mId,
        "DOCID": docId,
      }
    };
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
        var data = jsonDecode(response.body);
        return InvoiceModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
