import 'dart:convert';


import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/models/asset_scan_barcode_model.dart';
import 'package:erpflutter/models/save_sales_qr_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AsetBarcodeRequest {
  Future<AssetBarcodeModel?> getAssetBarcodeRequest(String barcodeNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("UserId");
    print("Get Yourrrrrrrrrrrrrrrrrrrr Asset Barcode UserId $getUserId");

    const url =
        "http://wilbarcode.cloud9ebiz.com/ERPAPI/API/LOTDetails/GetBarCodeScanDetails";

    // Define Json Body
    final Map<String, dynamic> requestBody = {
      "XMLFILE": {"FLAG": "5", "USERID": getUserId, "BARCODE": barcodeNo}
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
        final data = jsonDecode(response.body);
        // final myData = data['TRANSACTIONDETAILS']['TRANSACTIONS'][0]['LOTDESC'];
        // print(myData);
        return AssetBarcodeModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  //saveSalesQrScan ApI

  Future<SaveSalesQrScan?> saveSalesQrScan(
      String mId,
      String tId,
      String dId,
      String userId,
      String itemId,
      String barcode,
      String planQty,
      String avlQty,
      String key) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var getUserId = prefs.getString("UserId");
    // print("Get Yourrrrrrrrrrrrrrrrrrrr Asset Barcode UserId $getUserId");

   //const String urlbase ="http://10.0.0.223:8532/ERPAPI/API/";
    var url = "${AppConfig.BASE_URL}QRCodeScan/$key";
    print(url);

    // Define Json Body
    final Map<String, dynamic> requestBody = {
      "XMLFILE": {
        "FLAG": "I",
        "MID": mId,
        "TID": tId,
        "DOCID": dId,
        "USERID": userId,
        "ITEMID": itemId,
        "BARCODE": barcode,
        "PLANQTY": planQty,
        "AVAILABLEQTY": avlQty
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
        final data = jsonDecode(response.body);
        // final myData = data['TRANSACTIONDETAILS']['TRANSACTIONS'][0]['LOTDESC'];
        print(data);
        return SaveSalesQrScan.fromJson(data);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  Future<SaveSalesQrScan?> saveSalesQrScanAns(
      String mId,
      String tId,
      String dId,
      String userId,
      String itemId,
      String barcode,
      String planQty,
      String avlQty,
      String gateEntry,
      String key) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var getUserId = prefs.getString("UserId");
    // print("Get Yourrrrrrrrrrrrrrrrrrrr Asset Barcode UserId $getUserId");

    //const String urlbase ="http://10.0.0.223:8532/ERPAPI/API/";
    var url = "${AppConfig.BASE_URL}QRCodeScan/$key";
    print(url);

    // Define Json Body
    final Map<String, dynamic> requestBody = {
      "XMLFILE": {
        "FLAG": "I",
        "MID": mId,
        "TID": tId,
        "DOCID": dId,
        "USERID": userId,
        "ITEMID": itemId,
        "BARCODE": barcode,
        "PLANQTY": planQty,
        "AVAILABLEQTY": avlQty,
        "GATEENTRY":gateEntry,
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
        final data = jsonDecode(response.body);
        // final myData = data['TRANSACTIONDETAILS']['TRANSACTIONS'][0]['LOTDESC'];
        print(data);
        return SaveSalesQrScan.fromJson(data);
      } else {
        print("Status Code : ${response.statusCode}");
        final data = jsonDecode(response.body);
        print(data);
        return SaveSalesQrScan.fromJson(data);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
