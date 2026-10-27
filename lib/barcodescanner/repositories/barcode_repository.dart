import 'dart:async';
import 'dart:convert';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/barcodescanner/models/audit_response_model.dart';
import 'package:erpflutter/barcodescanner/models/barcode_registration_lookup.dart';
import 'package:erpflutter/barcodescanner/models/sysmsgsresponse.dart';
import 'package:erpflutter/barcodescanner/models/transactiondetailsresponse_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/api_request.dart';
import '../../models/physical_operation_response.dart';
import '../../models/syn_register_message.dart';
import '../../screens/login/login.dart';
import '../models/physical_barcode_itemdata.dart';
import '../models/workoder_item.dart';
import '../view_models/barcoderegistration_viewmodel.dart';


class BarcodeRepository {



  Future<TransactionDetailsResponse?> getBarcodeLotDetails(String userId,String strFlag) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? orgId = prefs.getString("ORGSTRUCTID");
    var controlno= prefs.getString('CONTROLNO');

    final url = Uri.parse(AppConfig.BASE_URL+'/LOTDetails/GetBarCodeScanDetails');

    // Prepare JSON body (same as your Java JSONObject)
    final Map<String, dynamic> requestBody = {
      "XMLFILE": {
        "FLAG": strFlag,
        "USERID": userId,
        "ORGSTRUCTID": orgId,
        "CONTROLNO": controlno,
      }
    };

    try {
      print("🔹 URL: $url");
      print("🔹 Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Status Code: ${response.statusCode}");
   //   print("✅ Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return TransactionDetailsResponse.fromJson(jsonResponse);
      }else if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      } else {
        print("⚠️ Request failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in getBarcodeLotDetails: $e");
      return null;
    }
  }

  Future<SysMsgsRegisterResponse> syncBarcode(
      BuildContext context, {
        required List<BarcodeRegistrationLookup> barcodeLookupList1,
        required String userId,
        required String baseUrl,
        required String flag,
      })
  async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? orgId = prefs.getString("ORGSTRUCTID");
      var controlno= prefs.getString('CONTROLNO');


      final barcodeReceipts = barcodeLookupList1.map((lookup) {
        return {
          'LOTID': lookup.lotId ?? '',
          'VARIFIED': 1,
        };
      }).toList();

      final requestBody = {
        'XMLFILE': {
          'LOTDETAILS': {
            'BARCODERECEIPTS': barcodeReceipts,
          },
          'FLAG': flag,
          'USERID': userId,
          "ORGSTRUCTID": orgId,
          "CONTROLNO": controlno,
        }
      };

      debugPrint("📤 Request JSON: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        debugPrint("❌ HTTP Error: ${response.statusCode}");
        return SysMsgsRegisterResponse(
          sysMsgs: SysMsgsRegsietr.empty(),
        );
      }else if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }

      final jsonResponse = jsonDecode(response.body);

      final data = jsonResponse["DATA"];
      final sysMsgsMap = data?["SYSMSGS"];

      if (sysMsgsMap == null) {
        debugPrint("❌ SYSMSGS missing in response");
        return SysMsgsRegisterResponse(
          sysMsgs: SysMsgsRegsietr.empty(), // 👈 fallback message
        );
      }

      debugPrint("✅ API Message: ${sysMsgsMap["ERRORMSGS"]}");

      return SysMsgsRegisterResponse.fromJson(jsonResponse);
    } catch (e) {
      debugPrint("❌ SyncBarcode Error: $e");
      return SysMsgsRegisterResponse(
        sysMsgs: SysMsgsRegsietr.empty(), // 👈 exception fallback
      );
    }
  }


  //audit
  Future<AuditResponseModel?> getAuditDetails(String userId,String strFlag,String barcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var controlno= prefs.getString('CONTROLNO');

    String? orgId = prefs.getString("ORGSTRUCTID");

    final url = Uri.parse(AppConfig.BASE_URL+'LOTDetails/GetBarCodeScanDetails');
    String serialNumber = "";
    print(barcode);
    if (barcode.contains("Serial No -")) {
      serialNumber = barcode.split("Serial No -").last.trim();
    }else
    {
      serialNumber=barcode;
    }

    print(serialNumber);
    // Prepare JSON body (same as your Java JSONObject)
    final Map<String, dynamic> requestBody = {
      "XMLFILE": {
        "USERID": userId,
        "FLAG": strFlag,
        "BARCODE": serialNumber,
        "ORGSTRUCTID": orgId,
        "CONTROLNO": controlno,
      }
    };

    try {
      print("🔹 URL: $url");
      print("🔹 Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Status Code: ${response.statusCode}");
       print("✅ Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AuditResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }else {
        print("⚠️ Request failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in getBarcodeLotDetails: $e");
      return null;
    }
  }


  // -------------------------------------------------------------
  // GET PHYSICAL BARCODE DETAILS
  // -------------------------------------------------------------
  Future<List<WorkOrderItem>> getPhysicalBarcodeDetails(
      String userId, String flag, String orgId, String mid) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var controlno= prefs.getString('CONTROLNO');

    final url =
    Uri.parse(AppConfig.BASE_URL + 'LOTDetails/GetBarCodeScanDetails');

    final Map<String, dynamic> body = {
      "XMLFILE": {
        "USERID": userId,
        "FLAG": flag,
        "ORGSTRUCID": orgId,
        "MID": mid,
        "DOCID": "0",
        "DESC": "",
        "OPRNID": "0",
        "CURRENTOPQTY": "0",
        "CONTROLNO": controlno,
      }
    };
    print(url);
    print(jsonEncode(body));
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );


      final ok = await ApiRequest.handleStatus(response);
      if (!ok) return [];

      final jsonBody = jsonDecode(response.body);
      final List list = jsonBody["TRANSACTIONDETAILS"]?["TRANSACTIONS"] ?? [];

      return list.map((e) => WorkOrderItem.fromJson(e)).toList();

    } catch (e) {
      print("❌ Error: $e");
      return [];
    }
  }

  // -------------------------------------------------------------
  // OPERATIONS LIST
  // -------------------------------------------------------------
  Future<List<PhysicalBarcodeOperation>> getOperations(
      String userId, String orgId, String mid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var controlno= prefs.getString('CONTROLNO');

    final url =
    Uri.parse(AppConfig.BASE_URL + 'LOTDetails/GetBarCodeScanDetails');

    final body = {
      "XMLFILE": {
        "FLAG": "12",
        "MID": mid,
        "DOCID": "0",
        "ORGSTRUCID": orgId,
        "DESC": "",
        "OPRNID": "0",
        "CURRENTOPQTY": "0",
        "USERID": userId,
        "CONTROLNO": controlno,
      }
    };
    print(url);
    print(jsonEncode(body));
    try {
      final response = await http
          .post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body))
          .timeout(const Duration(seconds: 25));
      print(url);
      print(jsonEncode(body));
      print(response);
      final ok = await ApiRequest.handleStatus(response);
      if (!ok) return [];

      final decoded = jsonDecode(response.body);

      if (decoded["DATA"]?["Status"] == "false") {
        throw Exception(decoded["DATA"]["Message"]);
      }

      final List transactions =
          decoded["TRANSACTIONDETAILS"]?["TRANSACTIONS"] ?? [];

      return transactions
          .map((e) => PhysicalBarcodeOperation.fromJson(e))
          .toList();

    } on TimeoutException {
      throw Exception("Server timeout. Try again.");
    } catch (e) {
      throw Exception("Unable to load operations: $e");
    }
  }

  // -------------------------------------------------------------
  // GET BARCODE DETAILS (PHYSICAL)
  // -------------------------------------------------------------
  Future<List<TransactionDetail>> getBarcodeDetails({
    required String flag,
    required String mid,
    required String docId,
    required String orgStructId,
    required String desc,
    required String oprnId,
    required String currentOpQty,
    required String userId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var controlno= prefs.getString('CONTROLNO');


    final url =
    Uri.parse(AppConfig.BASE_URL + 'LOTDetails/GetBarCodeScanDetails');

    final Map<String, dynamic> payload = {
      "XMLFILE": {
        "FLAG": flag,
        "MID": mid,
        "DOCID": docId,
        "ORGSTRUCID": orgStructId,
        "DESC": desc,
        "OPRNID": oprnId,
        "CURRENTOPQTY": currentOpQty,
        "USERID": userId,
        "CONTROLNO": controlno,
      }
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    print(url);
    print(jsonEncode(payload));
    print(response);
    final ok = await ApiRequest.handleStatus(response);
    if (!ok) return [];

    final jsonBody = jsonDecode(response.body);

    if (jsonBody["DATA"]?["Status"] == "false") {
      throw Exception(jsonBody["DATA"]["Message"]);
    }

    final parsed = PhysicalBarcodeItemResponse.fromJson(jsonBody);
    return parsed.transactions ?? [];
  }

  // -------------------------------------------------------------
  // SYNC PHYSICAL BARCODE
  // -------------------------------------------------------------
  Future<SysMsgsResponse?> syncPhysicalBarcode(
      BuildContext context, {
        required String orgStructId,
        required String userId,
        required String baseUrl,
        required String flag,
        required String barcode,
        required String opnId,
        required TransactionDetail transactions,
      }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var controlno= prefs.getString('CONTROLNO');



      String serial = barcode.contains("Serial No -")
          ? barcode.split("Serial No -").last.trim()
          : barcode;

      final receipt = [
        {
          "OPRNID": opnId,
          "ITEMID": transactions.itemid,
          "MID": transactions.mid,
          "DOCID": transactions.docid,
          "ORGSTRUCTID": orgStructId,
          "BARCODE": serial,
          "CONTROLNO": controlno,
        }
      ];

      final body = {
        "XMLFILE": {
          "LOTDETAILS": {"BARCODEISSUES": receipt},
          "FLAG": flag, // use the flag passed from calling function
          "USERID": userId,

        }
      };

      print("🔹 URL: $baseUrl");
      print("🔹 Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      final ok = await ApiRequest.handleStatus(response);
      if (!ok) return null;

      final jsonResponse = jsonDecode(response.body);

      print(response.body);
      return SysMsgsResponse.fromJson(jsonResponse);

    } catch (e) {
      print("❌ Sync Physical Barcode Error: $e");
      return null;
    }
  }

  // -------------------------------------------------------------
  // SYNC BARCODE ISSUE
  // -------------------------------------------------------------
  Future<SysMsgsResponse?> syncBarcodeIssue(
      BuildContext context, {
        required List<BarcodeRegistrationLookup> barcodeLookupList1,
        required String userId,
        required String baseUrl,
        required String flag,
        required String barcode,
        required Transactionl transactions,
      }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var controlno= prefs.getString('CONTROLNO');

      String? orgId = prefs.getString("ORGSTRUCTID");


      String serial = barcode.contains("Serial No -")
          ? barcode.split("Serial No -").last.trim()
          : barcode;

      final receipt = [
        {
          "LOTID": transactions.locId,
          "VARIFIED": 1,
          "TID": transactions.tid,
          "MID": transactions.mid,
          "DOCID": transactions.docId,
          "QTY": transactions.qty,
          "BARCODE": serial,
          "ORGSTRUCTID": orgId,
          "CONTROLNO": controlno,
        }
      ];

      final body = {
        "XMLFILE": {
          "LOTDETAILS": {"BARCODEISSUES": receipt},
          "FLAG": "3",
          "USERID": userId,

        }
      };
      print("Url: $baseUrl");
      print(jsonEncode(body));
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final ok = await ApiRequest.handleStatus(response);
      if (!ok) return null;

      final jsonResponse = jsonDecode(response.body);

      print(response.body);
      return SysMsgsResponse.fromJson(jsonResponse);


    } catch (e) {
      print("❌ syncBarcodeIssue Error: $e");
      return null;
    }
  }

}

