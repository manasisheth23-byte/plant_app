import 'dart:convert';


import 'package:erpflutter/barcodescanner/models/invoicedetailsmodel.dart';
import 'package:erpflutter/models/asset_barcode_scan_req.dart';
import 'package:erpflutter/models/invoiceDetailsModel.dart';
import 'package:erpflutter/repository/invoiceDetailsRequest.dart';
import 'package:flutter/material.dart';

class BarcodeProviderAns extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _barcodeMessage;
  String? _barcodeMessageTitle;
  String? get barcodeMessage => _barcodeMessage;
  String? get barcodeMessageTitle => _barcodeMessageTitle;
  InvoiceDetailsModel? _scannedquantity;
  InvoiceDetailsModel? get scannedquantity => _scannedquantity;

  // String? _scannedQty;
  // String? get scannedQty => _scannedQty;

  String? _scannedStatus;
  String? get scannedStatus => _scannedStatus;

  String? _barcodeId;
  String? get barcodeId => _barcodeId;
  final AsetBarcodeRequest _service = AsetBarcodeRequest();
  final InvoiceDetailsRequest _invoiceservice = InvoiceDetailsRequest();
  Future<bool> SaveSalesQrScan(
      String mId,
      String tId,
      String dId,
      String userId,
      String itemId,
      String barcode,
      String planQty,
      String avlQty,
      String key) async {
    try {
      _isLoading = true;
      // notifyListeners();
      // notifyListeners();

      final response = await _service.saveSalesQrScan(
          mId, tId, dId, userId, itemId, barcode, planQty, avlQty, key);
      print(response);

      if (response != null || response!.dATA.toString().isNotEmpty) {
        _barcodeMessage = response.dATA!.sYSMSGS!.eRRORMSGS.toString();
        // _barcodeId = response.dATA!.sYSMSGS!.iD.toString();
        print(_barcodeMessage);
        _isLoading = false;

        print('response os savesales qr scan: $response');

        notifyListeners();
        return true;
      }
    } catch (e, trace) {
      print('Error: $e');
      print(trace);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
  Future<bool> SaveSalesQrScanAns(
      String mId,
      String tId,
      String dId,
      String userId,
      String itemId,
      String barcode,
      String planQty,
      String avlQty,
      String gateentry,
      String key) async {
    try {
      _isLoading = true;
      // notifyListeners();
      // notifyListeners();

      final response = await _service.saveSalesQrScanAns(
          mId, tId, dId, userId, itemId, barcode, planQty, avlQty,gateentry, key);
      print(response);

    /*  if (response != null || response!.dATA.toString().isNotEmpty) {
        _barcodeMessage = response.dATA!.sYSMSGS!.eRRORMSGS.toString();
        // _barcodeId = response.dATA!.sYSMSGS!.iD.toString();
        print(_barcodeMessage);
        _isLoading = false;

        print('response os savesales qr scan: $response');

        notifyListeners();
        return true;
      }*/
      if (response != null &&
          response.dATA != null &&
          response.dATA!.sYSMSGS != null) {
        _barcodeMessage = response.dATA!.sYSMSGS!.eRRORMSGS ?? '';
        _barcodeMessageTitle=response.dATA!.sYSMSGS!.tITLE?? "";
        print(_barcodeMessage);

        _isLoading = false;
        notifyListeners();

        return true;
      }else{
        _barcodeMessage = response!.dATA!.message ?? "Something went wrong";
        return false;
      }
    } catch (e, trace) {
      print('Error: $e');
      print(trace);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
  Future<bool> InvoiceDetailsProvider(
      String mid,
      String docid,
      String flag,
      String slid,
      String orgid,
      // String? tId,
      String? projId) async {
    try {
      _isLoading = true;
      // notifyListeners();
      // notifyListeners();

      var response = await _invoiceservice.InvoiceDetails(
          mid, docid, flag, slid, orgid, projId);
      var data = jsonDecode(response!.body);
      print(
          "Responseeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee Of Invoiceeee Detailsssss  $response");
      print(data);

      if (response != null || response.body.isNotEmpty) {
        _scannedquantity = InvoiceDetailsModel.fromJson(data);
        print(
            "Responseeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee Of scanned quantity provider is: $_scannedquantity");
        // _scannedQty =
        //     data['TRANSACTIONDETAILS']['TRANSACTIONS'] /* [0]['Scanned'] */;
        // _scannedStatus =
        //     data['TRANSACTIONDETAILS']['TRANSACTIONS'][0]['Scan Status'];
        notifyListeners();

        print(_scannedquantity);
        _isLoading = false;

        print('response os savesales qr scan: $response');

        notifyListeners();
        return true;
      }
    } catch (e, trace) {
      print('Error: $e');
      print(trace);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
  Future<InvoiceDetailsModelAns?> getASNInvoiceDetails(
      String mid,
      String docid,
      String flag,
      String slid,
      String orgid,
      String? projId,
      ) async {
    try {
      _isLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      final response = await _invoiceservice.InvoiceDetailsANS(
        mid,
        docid,
        flag,
        slid,
        orgid,
        projId,
      );

      if (response == null || response.body.isEmpty) {
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      print("ASN Response: $data");

      final model = InvoiceDetailsModelAns.fromJson(data);

      _isLoading = false;
      notifyListeners();

      return model;
    } catch (e, stackTrace) {
      print("Error: $e");
      print(stackTrace);

      _isLoading = false;
      notifyListeners();

      return null;
    }
  }
}
