// lib/barcodescanner/view_models/barcode_provider.dart

import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/barcodescanner/models/barcode_registration_flagone.dart';
import 'package:erpflutter/barcodescanner/models/barcode_registration_lookup.dart';
import 'package:erpflutter/barcodescanner/models/sysmsgsresponse.dart';
import 'package:erpflutter/barcodescanner/models/transactiondetailsresponse_model.dart';
import 'package:erpflutter/barcodescanner/repositories/barcode_repository.dart';
import 'package:erpflutter/barcodescanner/view_models/physical_barcode_viewmodel.dart';
import 'package:erpflutter/database/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/barcode_provider.dart';
import '../../models/syn_register_message.dart';
import '../models/physical_barcode_itemdata.dart';
import '../views/barcoderegistration_view.dart';
import '../views/production_barcode.dart';

class BarcodeProvider with ChangeNotifier {
  // ------------------- CONTROLLERS -------------------
  final TextEditingController barcodeController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isDropdownOpen = false;

  // ------------------- REPOSITORY -------------------
  final BarcodeRepository _repository = BarcodeRepository();

  // ------------------- LOADING / PAGINATION -------------------
  bool isMoreLoading = false;
  int _page = 0;
  final int _pageSize = 20;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ------------------- TRANSACTIONS -------------------
  List<Transactionl> _transactions = [];
  List<Transactionl> _allTransactions = []; // master list for filtering
  List<Transactionl> get transactions => _transactions;

  // ------------------- LOT DETAILS -------------------
  List<LotDetail> _lotDetails = [];
  List<LotDetail> get lotDetails => _lotDetails;

  // ------------------- DOCUMENTS -------------------
  List<String> documentNoList = [];
  String? selectedDocumentNo;

  // ------------------- BARCODE LOOKUP -------------------
  List<BarcodeRegistrationLookup> barcodeLookupList = [];
  List<BarcodeRegistrationLookup> get barcodeLookupListGet => barcodeLookupList;

  // ------------------- SYS MSG -------------------
  SysMsgsResponse? lastSyncResponse;

  TransactionDetailsResponse? _details;
  TransactionDetailsResponse? get details => _details;

  // ------------------- INITIALIZATION -------------------
  void clearSelection() {
    selectedDocumentNo = null;
    documentNoList.clear();
    _transactions.clear();
    _allTransactions.clear();
    notifyListeners();
  }

  void setSelectedDocumentNo(String value) {
    selectedDocumentNo = value;
    notifyListeners();
  }

  // ------------------- LOAD DOCUMENTS -------------------
  Future<void> loadDocumentNumbers() async {
    documentNoList = await DatabaseService().getDistinctDocumentNumbers();
    notifyListeners();
  }

  // ------------------- LOAD TRANSACTIONS -------------------
  Future<void> loadAllTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _allTransactions = await DatabaseService().getAllTransactions();
      _transactions = [..._allTransactions];
    } catch (e) {
      print('Provider Load Error: $e');
      _transactions = [];
      _allTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllTransactionsSelected(String value) async {
    try {
      _isLoading = true;
      notifyListeners();

      _allTransactions = await DatabaseService().getAllTransactionsSelected(value);
      _transactions = [..._allTransactions];
    } catch (e) {
      print('Provider Load Error: $e');
      _transactions = [];
      _allTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------- FILTER TRANSACTIONS -------------------
  Future<void> filterTransactions(String query) async {
    if (query.isEmpty) {
      _transactions = [..._allTransactions];
    } else {
      _transactions = _allTransactions.where((lot) {
        final code = lot.invcNumb?.toLowerCase() ?? '';
        final desc = lot.itemDesc?.toLowerCase() ?? '';
        return code.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // ------------------- INSERT TRANSACTIONS -------------------
  Future<void> insertTransactionList(List<Transactionl> transactionList) async {
    _isLoading = true;
    notifyListeners();
    try {
      await DatabaseService().insertTransactions(transactionList);
      _allTransactions.addAll(transactionList);
      _transactions = [..._allTransactions];
      print('Transactions inserted via Provider');
    } catch (e) {
      print('Provider insert error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertLotDetailList(List<LotDetail> lotList) async {
    _isLoading = true;
    notifyListeners();
    try {
      await DatabaseService().insertLotDetails(lotList);
      _lotDetails.addAll(lotList);
      print('Lot details inserted via Provider');
    } catch (e) {
      print('Provider insert error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ------------------- FETCH FROM API -------------------
  Future<void> fetchBarcodeDetails(String strFlag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('USERID');
    _isLoading = true;
    notifyListeners();
    try {

      final response = await _repository.getBarcodeLotDetails(userId!, strFlag);

      final apiTransactions = response!.transactionDetails?.transactions ?? [];
      final lotDetails = response.transactionDetails?.lotDetails ?? [];

      // Update provider-level lists (so UI can directly read it if you prefer)
      _allTransactions = apiTransactions;
      _transactions = [..._allTransactions];

      final List<BarcodeLotDetail> barcodeLotDetails = lotDetails.map((lot) {
        return BarcodeLotDetail(
          invcType: lot.invcType,
          invcNumb: lot.invcNumb,
          itemCode: lot.itemCode,
          itemDesc: lot.itemDesc,
          qty: lot.qty,
          lotId: lot.lotId,
          barcode: lot.barcode,
          barcodeQty: lot.barcodeQty,
          balanceQty: lot.balanceQty,
          tid: lot.tid,
          mid: lot.mid,
          docId: lot.docId,
        );
      }).toList();

      if (strFlag == "2") {
      /*  if (apiTransactions.isNotEmpty) await DatabaseService().insertTransactions(apiTransactions);
        if (lotDetails.isNotEmpty) await DatabaseService().insertLotDetails(lotDetails);

   */
         await DatabaseService().insertTransactions(apiTransactions);
         await DatabaseService().insertLotDetails(lotDetails);

      } else if (strFlag == "1") {
      /*  if (apiTransactions.isNotEmpty) await DatabaseService().insertTransactionsRegistration(apiTransactions);
        if (barcodeLotDetails.isNotEmpty) await DatabaseService().insertLotRegisterDetails(barcodeLotDetails);*/

         await DatabaseService().insertTransactionsRegistration(apiTransactions);
        await DatabaseService().insertLotRegisterDetails(barcodeLotDetails);
      }

      _details = response;
    } catch (e) {
      print('Error fetching/inserting barcode details: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ------------------- LOAD BARCODE LOOKUP -------------------
  Future<void> loadBarcodeRegistrationLookup(String barcode) async {
    try {
      _isLoading = true;
      barcodeLookupList = [];
      notifyListeners();

      final data = await DatabaseService().getBarcodeRegistrationLookup(
        barcode: barcode,
        limit: _pageSize,
        offset: _page * _pageSize,
      );

      barcodeLookupList = data;
      print("Loaded ${barcodeLookupList.length} barcode lookup records");
    } catch (e) {
      print('Provider Lookup Load Error: $e');
      barcodeLookupList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------- SYNC -------------------
  Future<ScanResult> syncBarcodeIssueList(
      BuildContext safeContext,
      List<BarcodeRegistrationLookup> barcodeLookupList1,
      String? flag,
      Transactionl transactions,
      String barcode,
      String? documentNo,
      ) async {
    if (flag != null && flag != "3") {
      if (barcodeLookupList1.isEmpty) {
        return ScanResult(
          isSuccess: false,
          message: "No barcode data available.",
        );
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('USERID');

    if (userId == null) {
      return ScanResult(
        isSuccess: false,
        message: "User not logged in",
      );
    }

    final String baseUrl =
        AppConfig.BASE_URL + "LOTDetails/PostLotDetails";

    _isLoading = true;
    notifyListeners();

    try {
      final SysMsgsResponse? res =
      await _repository.syncBarcodeIssue(
        safeContext,
        barcodeLookupList1: barcodeLookupList1,
        userId: userId,
        barcode: barcode,
        baseUrl: baseUrl,
        flag: flag ?? "3", // ✅ FIXED
        transactions: transactions,
      );

      _isLoading = false;
      notifyListeners();
      /// ❌ No response from server
      if (res == null) {
        return ScanResult(
          isSuccess: false,
          message: "No response from server",
        );
      }

      final SysMsgs? sys = res.sysMsgs;

      /// ❌ FAILURE CASE
      if (sys?.id == '-1' || sys?.type == 'E') {
        return ScanResult(
          isSuccess: false,
          message: sys!.errorMsgs.isNotEmpty
              ? sys.errorMsgs
              : "Invalid QR / Barcode",
          title: sys.title,
        );
      }

      barcodeController.clear();
      barcodeLookupList.clear();

      if (sys?.id != '-1') {
        _loadBarcodeData(safeContext);
      }
      return ScanResult(
        isSuccess: true,
        message: sys!.errorMsgs.isNotEmpty
            ? sys.errorMsgs
            : "Barcode scanned successfully",
        title: sys.title,
      );
/*      if (res?.sysMsgs == null) {
        return ScanResult(
          isSuccess: false,
          message: "Invalid server response",
        );
      }

      final bool? isError = res?.isError;
      final String? message = res?.message;

      barcodeController.clear();
      barcodeLookupList.clear();

      if (isError!) {
        _loadBarcodeData(safeContext);
      }

      if (documentNo != null) {
        await loadAllTransactionsSelected(documentNo); // ✅ FIXED
      }

      return ScanResult(
        isSuccess: isError!,
        message: message!,
      );*/
    } catch (e, stack) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Provider error: $e");
      debugPrintStack(stackTrace: stack);
      return ScanResult(
        isSuccess: false,
        message: "Error: $e",
      );
    }
  }


  Future<void> syncBarcodeList(BuildContext context, List<BarcodeRegistrationLookup> barcodeLookupList1, String? flag) async {
    if (flag != null && flag == "3") {
      if (transactions.isEmpty) return;
    } else {
      if (barcodeLookupList.isEmpty) return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('USERID');
    String baseUrl = AppConfig.BASE_URL + "LOTDetails/PostLotDetails";

    _isLoading = true;
    notifyListeners();

    try {
      final SysMsgsRegisterResponse? response =
      await _repository.syncBarcode(
        context,
        barcodeLookupList1: barcodeLookupList1,
        userId: userId!,
        baseUrl: baseUrl,
        flag: flag ?? "1",
      );

      /// ✅ CORRECT NULL-SAFE CHECK
      if (response?.sysMsgs != null) {
        final msg = response!.sysMsgs!.errorMsgs;
print(msg);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor:
            response.sysMsgs!.type == 'S'
                ? Colors.green
                : Colors.red,
          ),
        );
      } else {
        debugPrint("❌ sysMsgs is null");
      }

      barcodeController.clear();
      barcodeLookupList1.clear();

    } catch (e, s) {
      debugPrint("❌ Provider syncBarcodeList error: $e");
      debugPrintStack(stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------- PAGINATION -------------------
  Future<void> loadAllTransactionsRegistration() async {
    try {
      _isLoading = true;
      _page = 0;
      notifyListeners();

      final data = await DatabaseService().getAllTransactionsRegistration(
        limit: _pageSize,
        offset: _page * _pageSize,
      );

      _transactions = data;
    } catch (e) {
      print('Provider Load Error: $e');
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isMoreLoading) return;

    try {
      isMoreLoading = true;
      notifyListeners();

      _page++;
      final data = await DatabaseService().getAllTransactionsRegistration(
        limit: _pageSize,
        offset: _page * _pageSize,
      );

      if (data.isNotEmpty) {
        _transactions.addAll(data);
      } else {
        _page--;
      }
    } catch (e) {
      print('Pagination Error: $e');
    } finally {
      isMoreLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreBarcodeRegisterTransactions() async {
    if (isMoreLoading) return;

    try {
      isMoreLoading = true;
      notifyListeners();

      _page++;
      final data = await DatabaseService().getAllTransactionsRegistration(
        limit: _pageSize,
        offset: _page * _pageSize,
      );

      if (data.isNotEmpty) {
        _transactions.addAll(data);
      } else {
        _page--;
      }
    } catch (e) {
      print('Pagination Error: $e');
    } finally {
      isMoreLoading = false;
      notifyListeners();
    }
  }

  // ------------------- DISPOSE -------------------
  @override
  void dispose() {
    barcodeController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<ScanResult> syncPhysicalBarcodeList(
      BuildContext safeContext,
      String? flag,
      TransactionDetail transactions,
      String barcode,
      String opnId,
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('USERID');
    String? orgStructId = prefs.getString('ORGSTRUCTID');

    String baseUrl = AppConfig.BASE_URL + "LOTDetails/PostLotDetails";

    _isLoading = true;
    notifyListeners();

    try {
      final SysMsgsResponse? response =
      await _repository.syncPhysicalBarcode(
        safeContext,
        orgStructId: orgStructId!,
        userId: userId!,
        barcode: barcode,
        baseUrl: baseUrl,
        flag: flag!,
        opnId: opnId,
        transactions: transactions,
      );

      /// If API returned null, show generic error
      if (response == null) {
        return ScanResult(
          isSuccess: false,
          message: "Server returned no data. Please try again.",
        );
      }

      final SysMsgs? sys = response.sysMsgs;

      /// If API returned a SYSMSGS object
      if (sys != null) {
        if (sys.id == '-1' || sys.type == 'E') {
          // ❌ FAILURE CASE
          return ScanResult(
            isSuccess: false,
            message: sys.errorMsgs.isNotEmpty
                ? sys.errorMsgs
                : "Invalid QR / Barcode",
            title: sys.title.isNotEmpty ? sys.title : null,
          );
        } else {
          // ✅ SUCCESS CASE
          barcodeController.clear();
          barcodeLookupList.clear();

          return ScanResult(
            isSuccess: true,
            message: sys.errorMsgs.isNotEmpty
                ? sys.errorMsgs
                : "Barcode scanned successfully",
            title: sys.title.isNotEmpty ? sys.title : null,
          );
        }
      }

      /// Fallback if SYSMSGS is null
      return ScanResult(
        isSuccess: false,
        message: "Unexpected response from server",
      );
    } catch (e) {
      print("❌ syncPhysicalBarcodeList error: $e");
      return ScanResult(
        isSuccess: false,
        message: "Server error. Please try again",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> _loadBarcodeData(BuildContext safeContext) async {
    final provider = Provider.of<BarcodeProvider>(safeContext, listen: false);

    try {

      await Future.wait([

        provider.fetchBarcodeDetails("2"),
      ]);
    } catch (e) {
      print("Error while loading barcode data: $e");
    }
  }
  void setDropdownOpen(bool value) {
    isDropdownOpen = value;
    notifyListeners();
  }
}
