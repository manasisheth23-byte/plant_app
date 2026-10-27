import 'dart:io';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:erpflutter/app_colors.dart';
import '../../Dashboard.dart';
import '../../models/physical_operation_response.dart';
import '../../plantappscreen/app_shell.dart';
import '../../provider/themecontroller.dart';
import '../../screens/BarcodeQrcodeScanner/physical_barcode_scan.dart';
import '../models/workoder_item.dart';
import '../models/physical_barcode_itemdata.dart';
import '../repositories/barcode_repository.dart';
import '../view_models/physical_barcode_viewmodel.dart';

class ProductionBarcodePage extends StatefulWidget {
  const ProductionBarcodePage({super.key});

  @override
  State<ProductionBarcodePage> createState() => _ProductionBarcodePageState();
}

class _ProductionBarcodePageState extends State<ProductionBarcodePage> {
  final GlobalKey _workOrderKey = GlobalKey();
  OverlayEntry? _workOrderOverlay;
  bool isDropdownWorkOrderOpen = false;
  ProductionBarcodeViewModel? vm;
  late ThemeController themeController;

  final GlobalKey _operationKey = GlobalKey();
  OverlayEntry? _operationOverlay;
  bool isDropdownOperationOpen = false;
  late OverlayState overlayState;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      vm = Provider.of<ProductionBarcodeViewModel>(context, listen: false);
      vm?.clearSelections();
      vm?.loadWorkOrders();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    overlayState = Overlay.of(context);
  }

  @override
  void dispose() {
  //  vm?.woSearch.dispose();
  //  vm?.opSearch.dispose();
    _workOrderOverlay?.remove();
    _operationOverlay?.remove();
    super.dispose();
  }

  // ----------------------------- Overlays -----------------------------
  void _showWorkOrderDropdown(BuildContext context, ProductionBarcodeViewModel vm) {
    if (_workOrderOverlay != null) {
      _workOrderOverlay!.remove();
      _workOrderOverlay = null;
      setState(() => isDropdownWorkOrderOpen = false);
      return;
    }

    if (_operationOverlay != null) {
      _operationOverlay!.remove();
      _operationOverlay = null;
      isDropdownOperationOpen = false;
    }

    vm.clearOperationSelections();
    vm.woSearch.clear();
    vm.filterWorkOrders('');

    final renderBox = _workOrderKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownHeight = screenHeight - offset.dy - size.height - 20;

    _workOrderOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _workOrderOverlay?.remove();
                _workOrderOverlay = null;
                setState(() => isDropdownWorkOrderOpen = false);
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
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
                          controller: vm.woSearch,
                          decoration: const InputDecoration(
                            hintText: "Select Work Order",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            vm.filterWorkOrders(value);
                            refresh(() {});
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: vm.filteredWorkOrders.isEmpty
                            ? const Center(child: Text("No Work Orders Found"))
                            : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: vm.filteredWorkOrders.length,
                          itemBuilder: (context, index) {
                            final item = vm.filteredWorkOrders[index];
                            return ListTile(
                              title: Text(item.workOrderNo),
                              onTap: () async {
                                vm.selectWorkOrder(item, context);
                                vm.woSearch.clear();
                                _workOrderOverlay?.remove();
                                _workOrderOverlay = null;
                                setState(() => isDropdownWorkOrderOpen = false);
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
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_workOrderOverlay!);
    setState(() => isDropdownWorkOrderOpen = true);
  }

  void _showOperationDropdown(BuildContext context, ProductionBarcodeViewModel vm) {
    if (vm.selectedWorkOrder == null || vm.isLoadingOperation || vm.operations.length <= 1) return;

    if (_operationOverlay != null) {
      _operationOverlay!.remove();
      _operationOverlay = null;
      setState(() => isDropdownOperationOpen = false);
      return;
    }

    vm.opSearch.clear();
    vm.filterOperations('');

    final renderBox = _operationKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownHeight = screenHeight - offset.dy - size.height - 20;

    _operationOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _operationOverlay?.remove();
                _operationOverlay = null;
                setState(() => isDropdownOperationOpen = false);
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: size.width,
            height: dropdownHeight,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: StatefulBuilder(
                builder: (context, refresh) {
                  List<PhysicalBarcodeOperation> displayOps =
                  vm.filteredOperations.isNotEmpty
                      ? vm.filteredOperations.where((e) => e.oprnId.isNotEmpty).toList()
                      : [];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: vm.opSearch,
                          decoration: const InputDecoration(
                            hintText: "Select Operation",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            vm.filterOperations(value);
                            refresh(() {});
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: displayOps.isEmpty
                            ? const Center(child: Text("No Operations Found for this Work order"))
                            : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: displayOps.length,
                          itemBuilder: (context, index) {
                            final op = displayOps[index];
                            return ListTile(
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${op.oprnDesc} - ",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "Production Qty: ",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${op.PRDTQTY ?? ''}",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " WO Qty: ",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${op.WOQTY ?? ''} ",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              onTap: () async {
                                vm.selectOperation(op, context);
                                vm.opSearch.clear();
                                _operationOverlay?.remove();
                                _operationOverlay = null;
                                setState(() => isDropdownOperationOpen = false);
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
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_operationOverlay!);
    setState(() => isDropdownOperationOpen = true);
  }

  double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 1.15;
    if (width > 600) return 1.0;
    return 0.95;
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Consumer<ProductionBarcodeViewModel>(
      builder: (context, vm, child) {
        final s = scale(context);
        bool isWindows = Platform.isWindows;

        return  Center(
          child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: Scaffold(

                    backgroundColor: isDesktop
                        ? Colors.white // dark app background for Windows/Desktop
                        : const Color(0xFFF5F7FB),
                    appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(60),
                        child: Center(
                            child: SizedBox(
                                width: isDesktop ? 700 : double.infinity,
                                child:AppBar(
                                  title:  Text("Production Barcode",
                                      style: GoogleFonts.lato(

                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      )),
                                  centerTitle: false,
                                  backgroundColor:  themeController.primaryColor,
                                  foregroundColor: Colors.white,
                                  leading: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _workOrderOverlay?.remove();
                                        _operationOverlay?.remove();
                                        vm.clearSelections();
                                        Navigator.of(context).pop();
                                      /*  Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (_) =>  Dashboard()));*/
                                      });


                                    },
                                  ),
                                )))),
                   /*   appBar: AppBar(
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Ico
                  ns.arrow_back, color: Colors.white),
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _workOrderOverlay?.remove();
                      _operationOverlay?.remove();
                      vm.clearSelections();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) =>  Dashboard()));
                    });

                  },
                ),
                backgroundColor: AppColors.APPCOLOR,
                foregroundColor: Colors.white,
                title: const Text("Production Barcode"),
              ),*/
                bottomNavigationBar: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                          (states) {
                        if (states.contains(MaterialState.selected)) {
                          return const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          );
                        }
                        return const TextStyle(
                          fontSize: 9,
                        );
                      },
                    ),
                  ),
                  child: NavigationBar(
                    selectedIndex: _idx,
                    onDestinationSelected: (index) async {
                      final plantName = context.read<PlantProvider>().plantName;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppShell(
                            role: "Admin",
                            plant: plantName,
                            selectedIndex: index,

                          ),
                        ),
                      );
                    },
                    height: 60,

                    backgroundColor: Colors.white,
                    indicatorColor: C.bluep,
                    destinations: [
                      const NavigationDestination(
                        icon: Icon(Icons.home_outlined, size: 30),
                        selectedIcon: Icon(Icons.home, color: C.blue, size: 30),
                        label: 'Home',
                      ),

                      /* const NavigationDestination(icon: Icon(Icons.grid_view_outlined,size: 30), selectedIcon: Icon(Icons.grid_view,size: 30, color: C.blue), label: 'Shop Floor'),*/
                      NavigationDestination(
                        icon: Badge( label: Text(unreadProvider.unreadCount.toString()), child: const Icon(Icons.notifications_outlined,size: 30)),
                        selectedIcon: const Icon(Icons.notifications,size: 30, color: C.blue),
                        label: 'Alerts',
                      ),
                      const NavigationDestination(icon: Icon(Icons.bar_chart_outlined,size: 30), selectedIcon: Icon(Icons.bar_chart,size: 30, color: C.blue), label: 'Reports'),
                      const NavigationDestination(icon: Icon(Icons.chat_bubble_outline,size: 30), selectedIcon: Icon(Icons.chat_bubble,size: 30, color: C.blue), label: 'Assistant'),
                      const NavigationDestination(
                        icon: Icon(Icons.person,size: 30),
                        selectedIcon: Icon(Icons.person,size: 30, color: C.blue),
                        label: 'Profile',
                      ),

                      /* const NavigationDestination(
                     icon: Icon(Icons.menu,size: 30),
                     selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                     label: 'More',
                   ),
                   */
                    ],
                  ),
                ),
              body: vm.isLoadingWorkOrder
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      color:const Color(0xFFF5F7FB),
                      width: isDesktop ? 700 : double.infinity,
                      padding: const EdgeInsets.all(0),
                      child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                /*    Container(
                      color: themeController.primaryColor,
                      height: 80,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 20,
                        bottom: 0,
                      ),
                      //  padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [

                          GestureDetector(
                            onTap: () {
                              _workOrderOverlay?.remove();
                              _operationOverlay?.remove();
                              vm.clearSelections();

                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(role: "Admin", plant: '')));


                            },
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Production Barcode",
                            style: TextStyle(
            fontSize: 18,
                              color: Colors.white,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),*/
                    const SizedBox(height: 6),
                    if (isDesktop)...[
                        Row(
                        children: [
                          Expanded(child: Padding(
                              padding: EdgeInsets.only(left: 20,right: 0),
                              child:

                          _buildWorkOrderDropdown(context, vm, s))),
                          const SizedBox(width: 20),
                          Expanded(child: Padding(
                              padding: EdgeInsets.only(left: 0,right: 20),
                              child:_buildOperationDropdown(context, vm, s))),
                        ],
                      )

            ]
                    else...[
                      Container(
                          width: 700,
                          padding:EdgeInsets.only(left: 20,right: 20,top: 10),
                          child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWorkOrderDropdown(context, vm, s),
                          const SizedBox(height: 20),
                          _buildOperationDropdown(context, vm, s),
                        ],
                      )),

            ],

                    if (vm.isLoadingOperation)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    const SizedBox(height: 20),
                  Expanded(
                      child:   Padding(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        child:  vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vm.barcodeTableData.isEmpty
                          ? const Center(child: Text(""))
                          : SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          child: Table(
                            border: TableBorder.all(color: Colors.black54),
                            children: [
                              TableRow(
                                decoration:  BoxDecoration(color: themeController.primaryColor),
                                children: [
                                  tableCell("Item Code", true, s, align: TextAlign.center),
                                  tableCell("Item Description", true, s, align: TextAlign.center),
                                  tableCell("Required Qty", true, s, align: TextAlign.center),
                                  tableCell("Scanned Qty", true, s, align: TextAlign.center),
                                ],
                              ),
                              for (var item in vm.barcodeTableData)
                                TableRow(
                                  children: [
                                    tableCell(item.itemCode, false, s),
                                    tableCell(item.item, false, s),
                                    tableCell(
                                      (double.tryParse(item.totalRequiredItemQuantity ?? "0")?.toInt() ?? 0)
                                          .toString(),
                                      false,
                                      s,
                                      align: TextAlign.center,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if ((item.SCANNEDQTY ?? '').isNotEmpty)
                                            Text(
                                              (double.tryParse(item.SCANNEDQTY ?? "0")?.toInt() ?? 0)
                                                  .toString(),
                                            ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () async {
                                              if (Platform.isAndroid) {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PhysicalBarcodeQRView(
                                                      barcodeTableData: item,
                                                      strOpnId: vm.selectedOperation?.oprnId ?? '0',
                                                      onBarcodeScanned: () {
                                                        vm.loadBarcodeTable(context);
                                                      },
                                                    ),
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
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    )),


                  ],
                ),
              ))),
          ),
        );
      },
    );
  }

  Widget _buildWorkOrderDropdown(BuildContext context, ProductionBarcodeViewModel vm, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Work Order",
          style: TextStyle(fontSize: 14 * s, color: themeController.primaryColor, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(

              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
          key: _workOrderKey,
          onTap: () => _showWorkOrderDropdown(context, vm),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vm.selectedWorkOrder?.workOrderNo ?? "Select Work Order",
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(
                  isDropdownWorkOrderOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ))),
      ],
    );
  }

  Widget _buildOperationDropdown(BuildContext context, ProductionBarcodeViewModel vm, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Operation",
          style: TextStyle(
              fontSize: 14 * s,
              color: themeController.primaryColor,
              fontWeight: FontWeight.w700
          ),
        ),
        const SizedBox(height: 6),
        AbsorbPointer(
          absorbing: vm.selectedWorkOrder == null || vm.isLoadingOperation || vm.operations.length <= 1,
          child: Opacity(
            opacity: vm.selectedWorkOrder == null || vm.isLoadingOperation || vm.operations.length <= 1
                ? 0.5
                : 1.0,
            child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
              key: _operationKey,
              onTap: () => _showOperationDropdown(context, vm),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vm.operations.length <= 1
                            ? "No Operations"
                            : " ${vm.selectedOperation?.oprnDesc ?? 'Select Operation'}",
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(
                      isDropdownOperationOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ))),
          ),
        ),
      ],
    );
  }

  Widget tableCell(String text, bool header, double s, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.all(6 * s),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: (header ? 13 : 14) * s,
          fontWeight: header ? FontWeight.w700: FontWeight.w700,
          color: header ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
