import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erpflutter/app_colors.dart';
import '../../Dashboard.dart';
import '../../models/physical_operation_response.dart';
import '../../screens/BarcodeQrcodeScanner/physical_barcode_scan.dart';
import '../models/workoder_item.dart';
import '../models/physical_barcode_itemdata.dart';
import '../repositories/barcode_repository.dart';

class ProductionBarcodePageTest extends StatefulWidget {
  const ProductionBarcodePageTest({super.key});

  @override
  State<ProductionBarcodePageTest> createState() => _ProductionBarcodePageState();
}

class _ProductionBarcodePageState extends State<ProductionBarcodePageTest> {
  final BarcodeRepository _repository = BarcodeRepository();

  // Work Orders
  List<WorkOrderItem> workOrders = [];
  WorkOrderItem? selectedWorkOrder;
  List<WorkOrderItem> filteredWorkOrders = [];
  final TextEditingController _workOrderSearchController = TextEditingController();
  final GlobalKey _workOrderKey = GlobalKey();
  OverlayEntry? _workOrderOverlay;
  bool isDropdownWorkOrderOpen = false;

  // Operations
  List<PhysicalBarcodeOperation> operations = [];
  PhysicalBarcodeOperation? selectedOperation;
  List<PhysicalBarcodeOperation> filteredOperations = [];
  final TextEditingController _operationSearchController = TextEditingController();
  final GlobalKey _operationKey = GlobalKey();
  OverlayEntry? _operationOverlay;
  bool isDropdownOperationOpen = false;
  bool isLoadingOperation = false;

  // Table data
  List<TransactionDetail> barcodeTableData = [];

  // Loading
  bool isLoading = false;
  bool isLoadingWorkOrder = false;

  // Placeholder
  PhysicalBarcodeOperation selectOperationPlaceholder = PhysicalBarcodeOperation(
    mid: "",
    docId: "",
    oprnId: "",
    oprnCode: "",
    oprnDesc: "Select Operation",
    seq: "",
    isFinal: "",
    currentOpQty: "", QTY: '', PRDTQTY: '', WOQTY: '',
  );

  @override
  void initState() {
    super.initState();
    operations = [selectOperationPlaceholder];
    selectedOperation = selectOperationPlaceholder;

    _workOrderSearchController.addListener(_filterWorkOrders);
    _operationSearchController.addListener(_filterOperations);
    barcodeTableData = [];
    loadWorkOrders();
  }

  @override
  void dispose() {
    _workOrderSearchController.dispose();
    _operationSearchController.dispose();
    _workOrderOverlay?.remove();
    _operationOverlay?.remove();
    super.dispose();
  }

  // ---------------------------- API Calls ----------------------------
  Future<void> loadWorkOrders() async {
    setState(() => isLoadingWorkOrder = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('USERID');
    String? orgId = prefs.getString('ORGSTRUCTID');
    if (userId == null || orgId == null) return;

    workOrders = await _repository.getPhysicalBarcodeDetails(userId, "12", orgId, "0");
    filteredWorkOrders = List.from(workOrders);
    setState(() => isLoadingWorkOrder = false);
  }

  Future<void> loadOperations(String mid) async {
    setState(() => isLoadingOperation = false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('USERID');
    String? orgId = prefs.getString('ORGSTRUCTID');
    if (userId == null || orgId == null) return;

    List<PhysicalBarcodeOperation> apiOps = await _repository.getOperations(userId, orgId, mid);

    if (apiOps.isEmpty) {
      // No operations available
      operations = [selectOperationPlaceholder];
      filteredOperations = List.from(operations);
      selectedOperation = selectOperationPlaceholder;
      setState(() => isLoadingOperation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No operations available for selected Work Order')),
      );
      return;
    }

    operations = [selectOperationPlaceholder, ...apiOps];
    filteredOperations = List.from(operations);
    setState(() {
      selectedOperation = selectOperationPlaceholder;
      isLoadingOperation = false;
    });
  }

  Future<void> loadBarcodeTable() async {
    if (selectedOperation == null || selectedOperation!.oprnId.isEmpty) return;

    setState(() => isLoading = true); // Show loader

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('USERID');
      String? orgId = prefs.getString('ORGSTRUCTID');
      if (userId == null || orgId == null) return;

      // API call
      List<TransactionDetail> result = await _repository.getBarcodeDetails(
        flag: "12",
      //  mid: "16",
        mid: selectedOperation!.mid,
        docId: selectedOperation!.docId,
        orgStructId: orgId,
        oprnId: selectedOperation!.oprnId,
        currentOpQty: selectedOperation!.currentOpQty,
        userId: userId,
        desc: '',
      );

      if (result.isEmpty) {
        // API returned empty list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No data available")),
        );
      }

      barcodeTableData = result;
    } catch (e) {
      // Handle API error
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data: $e")),
      );
      barcodeTableData = []; // Ensure table shows empty list
    } finally {
      setState(() => isLoading = false); // Hide loader in all cases
    }
  }


  // ---------------------------- Filter Functions ----------------------------
  void _filterWorkOrders() {
    final q = _workOrderSearchController.text.toLowerCase();
    setState(() {
      filteredWorkOrders = workOrders.where((e) => e.workOrderNo.toLowerCase().contains(q)).toList();
    });
  }

  void _filterOperations() {
    final q = _operationSearchController.text.toLowerCase();
    setState(() {
      filteredOperations = [selectOperationPlaceholder, ...operations.sublist(1).where((op) => op.oprnDesc.toLowerCase().contains(q)).toList()];
    });
  }

  // ---------------------------- Overlay Dropdowns ----------------------------
  void _showWorkOrderDropdown() {
    if (_workOrderOverlay != null) {
      _workOrderOverlay!.remove();
      _workOrderOverlay = null;
      setState(() => isDropdownWorkOrderOpen = false);
      return;
    }

    final renderBox = _workOrderKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownHeight = screenHeight - offset.dy - size.height - 20;

    _workOrderOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          width: size.width,
          height: dropdownHeight,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: StatefulBuilder(
              builder: (context, refresh) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _workOrderSearchController,
                        decoration: const InputDecoration(
                          hintText: "Search Work Order",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) => refresh(() => _filterWorkOrders()),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: filteredWorkOrders.isEmpty
                          ? const Center(child: Text("No Work Orders Found"))
                          : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredWorkOrders.length,
                        itemBuilder: (context, index) {
                          final item = filteredWorkOrders[index];
                          return ListTile(
                            title: Text(item.workOrderNo),
                            onTap: () {
                              setState(() {
                                selectedWorkOrder = item;
                                filteredWorkOrders = List.from(workOrders);
                                isDropdownWorkOrderOpen = false;
                                barcodeTableData = [];
                              });
                              loadOperations(item.mid);
                              _workOrderOverlay?.remove();
                              _workOrderOverlay = null;
                              _workOrderSearchController.clear();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_workOrderOverlay!);
    setState(() => isDropdownWorkOrderOpen = true);
  }

  void _showOperationDropdown() {
    if (selectedWorkOrder == null || isLoadingOperation || operations.length <= 1) return;

    if (_operationOverlay != null) {
      _operationOverlay!.remove();
      _operationOverlay = null;
      setState(() => isDropdownOperationOpen = false);
      return;
    }

    final renderBox = _operationKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownHeight = screenHeight - offset.dy - size.height - 20;

    _operationOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          width: size.width,
          height: dropdownHeight,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: StatefulBuilder(
              builder: (context, refresh) {
                List<PhysicalBarcodeOperation> displayOps = filteredOperations.length > 1 ? filteredOperations.sublist(1) : [];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _operationSearchController,
                        decoration: const InputDecoration(
                          hintText: "Search Operation",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) => refresh(() => _filterOperations()),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: displayOps.isEmpty
                          ? const Center(child: Text("No Operations Found"))
                          : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: displayOps.length,
                        itemBuilder: (context, index) {
                          final op = displayOps[index];
                          return ListTile(
                          //  title: Text("${op.oprnId} - ${op.oprnDesc}"),
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  // Operation Description
                                  TextSpan(
                                    text: "${op.oprnDesc} ",
                                    style: const TextStyle(
                                      color: Colors.black, // color for description
                                      fontWeight: FontWeight.normal,

                                    ),
                                  ),
                                  // Quantity
                                  TextSpan(
                                    text: "Qty: ",
                                    style: const TextStyle(
                                      color: Colors.blue, // color for quantity
                                      fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                  TextSpan(
                                    text: "${op.QTY} ",
                                    style: const TextStyle(
                                      color: Colors.red, // color for quantity
                                      fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                  // Pending Quantity
                                  TextSpan(
                                    text: "ProQty: ",
                                    style: const TextStyle(
                                      color: Colors.blue, // color for pending quantity
                                      fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                  TextSpan(
                                    text: "${op.PRDTQTY ?? 0}",
                                    style: const TextStyle(
                                      color: Colors.red, // color for pending quantity
                                      fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedOperation = op;
                                isDropdownOperationOpen = false;
                              });
                              _operationOverlay?.remove();
                              _operationOverlay = null;
                              _operationSearchController.clear();
                              loadBarcodeTable();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_operationOverlay!);
    setState(() => isDropdownOperationOpen = true);
  }

  // ---------------------------- Scaling ----------------------------
  double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 1.15;
    if (width > 600) return 1.0;
    return 0.95;
  }

  // ---------------------------- Build ----------------------------
  @override
  Widget build(BuildContext context) {
    final s = scale(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        foregroundColor: Colors.white,
        title: const Text("Production Barcode"),
      ),
      body: isLoadingWorkOrder
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Work Order Dropdown
            Text(
              "Work Order",
              style: TextStyle(
                  fontSize: 14 * s,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              key: _workOrderKey,
              onTap: _showWorkOrderDropdown,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedWorkOrder?.workOrderNo ?? "Select Work Order",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Icon(
                      isDropdownWorkOrderOpen
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Operation Dropdown
            Text(
              "Operation",
              style: TextStyle(
                  fontSize: 14 * s,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            AbsorbPointer(
              absorbing: selectedWorkOrder == null || isLoadingOperation || operations.length <= 1,
              child: Opacity(
                opacity: selectedWorkOrder == null || isLoadingOperation || operations.length <= 1 ? 0.5 : 1.0,
                child: GestureDetector(
                  key: _operationKey,
                  onTap: _showOperationDropdown,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            operations.length <= 1
                                ? "No Operations"
                                : " ${selectedOperation?.oprnDesc ?? 'Select Operation'}",
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Icon(
                          isDropdownOperationOpen
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isLoadingOperation) const SizedBox(height: 10),
            if (isLoadingOperation)
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(height: 20),

            // Table
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // Show loader while loading
                  : barcodeTableData.isEmpty
                  ? const Center(child: Text("")) // Show message if empty
                  : SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.black54),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Colors.blue),
                      children: [
                        tableCell("Item Code", true, s, align: TextAlign.center),
                        tableCell("Item Desc", true, s, align: TextAlign.center),
                        tableCell("Required Qty", true, s, align: TextAlign.center),
                        tableCell("Scanned Qty", true, s, align: TextAlign.center),
                      ],
                    ),
                    for (var item in barcodeTableData)
                      TableRow(children: [
                        tableCell(item.itemCode, false, s),
                        tableCell(item.item, false, s),
                        tableCell(
                            (double.tryParse(item.totalRequiredItemQuantity ?? "0")?.toInt() ?? 0)
                                .toString(),
                            false,
                            s,
                            align: TextAlign.center),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if ((item.totalRequiredItemQuantity ?? '').isNotEmpty)
                                Text(
                                  (double.tryParse(item.pendingIssueAdvQuantity ?? "0")?.toInt() ?? 0)
                                      .toString(),
                                ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async{
                                  if(Platform.isAndroid) {
                                    final scannedCode = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhysicalBarcodeQRView(barcodeTableData:item, strOpnId: selectedOperation?.oprnId ?? '0',),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(Icons.qr_code_2, size: 20 * s),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  // ---------------------------- Table Cell ----------------------------
  Widget tableCell(String text, bool header, double s,
      {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.all(10 * s),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: (header ? 13 : 14) * s,
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
          color: header ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
