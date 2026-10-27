import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/physical_operation_response.dart';
import '../models/workoder_item.dart';
import '../models/physical_barcode_itemdata.dart';
import '../repositories/barcode_repository.dart';

class ProductionBarcodeViewModel extends ChangeNotifier {
  final BarcodeRepository _repository = BarcodeRepository();

  ProductionBarcodeViewModel() {
    loadWorkOrders();
  }

  // State Variables
  List<WorkOrderItem> workOrders = [];
  List<WorkOrderItem> filteredWorkOrders = [];
  WorkOrderItem? selectedWorkOrder;

  List<PhysicalBarcodeOperation> operations = [];
  List<PhysicalBarcodeOperation> filteredOperations = [];
  PhysicalBarcodeOperation? selectedOperation;

  List<TransactionDetail> barcodeTableData = [];

  bool isLoading = false;
  bool isLoadingWorkOrder = false;
  bool isLoadingOperation = false;

  final TextEditingController woSearch = TextEditingController();
  final TextEditingController opSearch = TextEditingController();

  bool _workOrdersLoaded = false;

  PhysicalBarcodeOperation placeholder = PhysicalBarcodeOperation(
    mid: "",
    docId: "",
    oprnId: "",
    oprnCode: "",
    oprnDesc: "Select Operation",
    seq: "",
    isFinal: "",
    currentOpQty: "",
    QTY: "",
    PRDTQTY: "", WOQTY: '',
  );

  // ===================== UNIVERSAL TOAST =============================
  static void _showSnackColor(String message, {Color bgColor = Colors.black}) {
    Get.snackbar(
      '', // keep empty
      '', // we will use messageText instead
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold, // ✅ makes text bold

        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }
  static void _showSnack(String message, {Color bgColor = Colors.black}) { Get.snackbar( '', message, titleText: const SizedBox.shrink(), snackPosition: SnackPosition.BOTTOM, backgroundColor: bgColor, colorText: Colors.white, duration: const Duration(seconds: 3), ); }


  // ===================== LOAD WORK ORDERS =============================

  Future<void> loadWorkOrders() async {
    if (_workOrdersLoaded) return;
    _workOrdersLoaded = true;

    isLoadingWorkOrder = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("USERID");
    String? orgId = prefs.getString("ORGSTRUCTID");

    workOrders = await _repository.getPhysicalBarcodeDetails(
      userId!,
      "12",
      orgId!,
      "0",
    );

    if (workOrders.isEmpty) {
      selectedWorkOrder = null;
      filteredWorkOrders = [];

      _showSnack("No Work Orders Found");
    } else {
      filteredWorkOrders = List.from(workOrders);
    }

    isLoadingWorkOrder = false;
    notifyListeners();
  }

  // ===================== SELECT WORK ORDER =============================

  Future<void> selectWorkOrder(WorkOrderItem item, BuildContext context) async {
    selectedWorkOrder = item;

    barcodeTableData.clear();
    notifyListeners();

    await loadOperations(item.mid, context);
  }

  // ===================== LOAD OPERATIONS =============================

  Future<void> loadOperations(String mid, BuildContext context) async {
    isLoadingOperation = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("USERID");
    String? orgId = prefs.getString("ORGSTRUCTID");

    List<PhysicalBarcodeOperation> list =
    await _repository.getOperations(userId!, orgId!, mid);

    if (list.isEmpty) {
      _showSnack("No operations found for this Work Orders");
    }

    operations = [placeholder, ...list];
    filteredOperations = List.from(operations);

    selectedOperation = placeholder;

    isLoadingOperation = false;
    notifyListeners();
  }

  // ===================== SELECT OPERATION =============================

  Future<void> selectOperation(PhysicalBarcodeOperation op, BuildContext context) async {
    selectedOperation = op;
    notifyListeners();
print(selectedOperation?.oprnId);
    await loadBarcodeTable(context);
  }

  // ===================== LOAD TABLE =============================

  Future<void> loadBarcodeTable(BuildContext context) async {
    if (selectedOperation == null || selectedOperation!.oprnId.isEmpty) return;
    print(selectedOperation?.oprnId);
    isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("USERID");
      String? orgId = prefs.getString("ORGSTRUCTID");

      barcodeTableData = await _repository.getBarcodeDetails(
        flag: "12",
        mid: selectedOperation!.mid,
        docId: selectedOperation!.docId,
        orgStructId: orgId!,
        oprnId: selectedOperation!.oprnId,
        currentOpQty: selectedOperation!.currentOpQty,
        userId: userId!,
        desc: "",
      );

      if (barcodeTableData.isEmpty) {
        _showSnack("No records found");
      }
    } catch (e) {
      barcodeTableData = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ===================== SEARCH FILTERS =============================

  void filterWorkOrders(String query) {
    filteredWorkOrders = workOrders
        .where((e) => e.workOrderNo.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void filterOperations(String query) {
    filteredOperations = operations
        .where((op) => op.oprnDesc.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  // ===================== CLEAR SELECTIONS =============================

  void clearSelections() {
    selectedWorkOrder = null;
    selectedOperation = null;
    barcodeTableData.clear();

    operations = [placeholder];
    filteredOperations.clear();

    notifyListeners();
  }
  void clearOperationSelections() {
    selectedOperation = null;
    barcodeTableData.clear();

    filteredOperations.clear();
    operations = [placeholder];

    notifyListeners();
  }
  void clearOperationOnly() {
    selectedOperation = null;
    barcodeTableData.clear();

    operations = [placeholder];
    filteredOperations.clear();

    notifyListeners();
  }
}
