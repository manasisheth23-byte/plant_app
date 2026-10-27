import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/models/so_table_model.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../../provider/sotable_provider.dart';
import '../../provider/themecontroller.dart';

class SOReport extends StatefulWidget {
  const SOReport({super.key});

  @override
  State<SOReport> createState() => _SOReportState();
}

class _SOReportState extends State<SOReport> {
  bool _showFilterFields = false;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SoReportProvider>(context, listen: false);
      provider.fetchSoData(context);
    });
    _verticalController.addListener(_onScroll);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _onScroll() {
    if (_verticalController.position.pixels == _verticalController.position.maxScrollExtent) {
      Provider.of<SoReportProvider>(context, listen: false).fetchSoData(context,loadMore: true);
    }
  }

  // Check and request storage permissions
// Also update the _checkPermission function for Android 10+ compatibility
  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      // For Android 10 (API 29) and above, we need different permissions
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        // Show a message explaining why storage permission is needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to save files.'),
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }
    } else {
      return true; // iOS doesn't need runtime permission for storage
    }
  }

  // Generate and download Excel file
  // Generate and download Excel file
  Future<void> _exportToExcel(List<Data> data) async {
    try {
      if (await _checkPermission()) {
        // Create Excel workbook
        final excel = xl.Excel.createExcel();
        final sheet = excel['SO Report'];

        // Define headers
        final headers = [
          'Priority',
          'Sr. No.',
          'SO. No.',
          'SO. Line No.',
          'SO. Date',
          'Customer',
          'Project No.',
          'Product Code',
          'Product Description',
          'PO. No.',
          'PO. Date',
          'PO Diff. Days',
        ];

        // Add headers to sheet
        for (var i = 0; i < headers.length; i++) {
          sheet.cell(xl.CellIndex.indexByColumnRow(
            columnIndex: i,
            rowIndex: 0,
          )).value = xl.TextCellValue(headers[i]);
        }

        // Add data rows
        for (var i = 0; i < data.length; i++) {
          final row = i + 1; // Start from row 1 (after headers)
          final item = data[i];

          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
              .value = xl.TextCellValue(item.aSSIGNPRIORITY.toString());
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value = xl.TextCellValue(item.sRNO.toString());
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
              .value = xl.TextCellValue(item.sONO ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
              .value = xl.TextCellValue(item.sOLineNo.toString());
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
              .value = xl.TextCellValue(item.sODATE ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
              .value = xl.TextCellValue(item.customer ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
              .value = xl.TextCellValue(item.pROJNO ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
              .value = xl.TextCellValue(item.dISPITEMCODE ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
              .value = xl.TextCellValue(item.itemDescription ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
              .value = xl.TextCellValue(item.pONO ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row))
              .value = xl.TextCellValue(item.pODATE ?? '');
          sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row))
              .value = xl.TextCellValue(item.podiffdays.toString());
        }

        // Save to Downloads folder (accessible to users)
        final downloadsDir = Directory('/storage/emulated/0/Download');
        // Make sure the directory exists
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName = 'SO_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final filePath = path.join(downloadsDir.path, fileName);

        final bytes = excel.encode();
        if (bytes != null) {
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          // Try to open the file
          final result = await OpenFile.open(filePath);

          if (result.type != ResultType.done) {
            // Fallback: Show user where file is saved
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Excel file saved to Downloads folder: $fileName'),
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Excel file opened successfully!')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting to Excel: ${e.toString()}')),
      );
    }
  }

  // Generate and download PDF file
  Future<void> _exportToPdf(List<Data> data) async {
    try {
      if (await _checkPermission()) {
        // Create PDF document
        final pdf = pw.Document();

        // Add page with landscape orientation
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a3.landscape,
            build: (pw.Context context) {
              // Define headers
              final headers = [
                'Priority',
                'Sr. No.',
                'SO. No.',
                'SO Line',
                'SO Date',
                'Customer',
                'Project',
                'Product Code',
                'Product Desc',
                'PO. No.',
                'PO Date',
                'PO Days',
              ];

              // Create table data
              final tableData = <List<String>>[];
              tableData.add(headers); // Add headers as first row

              // Add data rows
              for (var item in data) {
                tableData.add([
                  item.aSSIGNPRIORITY.toString(),
                  item.sRNO.toString(),
                  item.sONO ?? '',
                  item.sOLineNo.toString(),
                  item.sODATE ?? '',
                  item.customer ?? '',
                  item.pROJNO ?? '',
                  item.itemCode ?? '',
                  item.itemDescription ?? '',
                  item.pONO ?? '',
                  item.pODATE ?? '',
                  item.podiffdays.toString(),
                ]);
              }

              // Create table
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SO Report',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Generated on: ${DateTime.now().toString().substring(0, 19)}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Table.fromTextArray(
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                    cellHeight: 30,
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.centerLeft,
                      2: pw.Alignment.centerLeft,
                      3: pw.Alignment.centerLeft,
                      4: pw.Alignment.centerLeft,
                      5: pw.Alignment.centerLeft,
                      6: pw.Alignment.centerLeft,
                      7: pw.Alignment.centerLeft,
                      8: pw.Alignment.centerLeft,
                      9: pw.Alignment.centerLeft,
                      10: pw.Alignment.centerLeft,
                      11: pw.Alignment.centerLeft,
                    },
                    data: tableData,
                  ),
                ],
              );
            },
          ),
        );

        // Save to Downloads folder (accessible to users)
        final downloadsDir = Directory('/storage/emulated/0/Download');
        // Make sure the directory exists
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName = 'SO_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = path.join(downloadsDir.path, fileName);

        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        // Try to open the file
        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          // Fallback: Show user where file is saved
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF file saved to Downloads folder: $fileName'),
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF file opened successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting to PDF: ${e.toString()}')),
      );
    }
  }


  // Show export options dialog
  void _showExportDialog(List<Data> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Options'),
          content: const Text('Choose a format to export data:'),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.table_chart),
              label: const Text('Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _exportToExcel(data);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _exportToPdf(data);
              },
            ),
          ],
        );
      },
    );
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final soReportProvider = Provider.of<SoReportProvider>(context);
    final sampleData = soReportProvider.soData;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        final provider = Provider.of<SoReportProvider>(context, listen: false);
        provider.reset(context);
        return true;
      },
      child: Center(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(

            backgroundColor: themeController.primaryColor,
            foregroundColor: Colors.white,
            centerTitle: false,

            title:  Text(
              'SO Table',
              style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              )
            ),
          ),
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
                if (index == 3) {
                  showDialog( context: context, builder: (context) =>
                      AlertDialog( title: const Text("Coming Soon 🚀"),
                        content: const Text( "This feature is under development and will be available soon.", ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text("OK"), ), ], ), ); return; }
                final plantName = context.read<PlantProvider>().plantName;
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        AppShell(
                          role: "Admin",
                          plant: plantName,
                          selectedIndex: index,

                        ),
                    transitionsBuilder: (_, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
           /*     Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppShell(
                      role: "Admin",
                      plant: plantName,
                      selectedIndex: index,

                    ),
                  ),
                );*/
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
                  ),*/

              ],
            ),
          ),
          body: Stack(
            children: [
              if (soReportProvider.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
                )
              else
                Column(
                  children: [
                    Expanded(
                      child: _buildTableTab(sampleData, _showFilterFields, soReportProvider),
                    ),
                  ],
                ),
              // Positioned(
              //   bottom: 16,
              //   right: 16,
              //   child: Row(
              //     children: [
              //       _showFilterFields != true
              //           ? ElevatedButton(
              //         onPressed: () {
              //           setState(() {
              //             soReportProvider.fetchDropdownData();
              //             _showFilterFields = !_showFilterFields;
              //           });
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blue,
              //           foregroundColor: Colors.white,
              //         ),
              //         child: const Text('Filter'),
              //       )
              //           : ElevatedButton(
              //         onPressed: () {
              //           setState(() {
              //             soReportProvider.reset();
              //             _showFilterFields = !_showFilterFields;
              //           });
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.red,
              //           foregroundColor: Colors.white,
              //         ),
              //         child: const Text('Remove Filter'),
              //       ),
              //       const SizedBox(width: 10),
              //       _showFilterFields
              //           ? ElevatedButton(
              //         onPressed: () {
              //           soReportProvider.applyFilter();
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blue,
              //           foregroundColor: Colors.white,
              //         ),
              //         child: const Text('Apply Filter'),
              //       )
              //           : const SizedBox(),
              //       // const SizedBox(width: 10),
              //       // ElevatedButton(
              //       //   onPressed: () {
              //       //     // Export action with dialog
              //       //     _showExportDialog(sampleData);
              //       //   },
              //       //   style: ElevatedButton.styleFrom(
              //       //     backgroundColor: Colors.green,
              //       //     foregroundColor: Colors.white,
              //       //   ),
              //       //   child: const Text('Export'),
              //       // ),
              //       // const SizedBox(width: 10),
              //       // ElevatedButton(
              //       //   onPressed: () {
              //       //     // Upload action
              //       //   },
              //       //   style: ElevatedButton.styleFrom(
              //       //     backgroundColor: Colors.orange,
              //       //     foregroundColor: Colors.white,
              //       //   ),
              //       //   child: const Text('Upload'),
              //       // ),
              //     ],
              //   ),
              // ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Row(
                  children: [
                    _showFilterFields != true
                        ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          soReportProvider.fetchDropdownData().then((_) {
                            soReportProvider.storeInitialFilterState();
                          });
                          _showFilterFields = !_showFilterFields;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Filter'),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (soReportProvider.hasFiltersChanged) {
                            soReportProvider.resetToDefaults(context);
                          }
                          _showFilterFields = !_showFilterFields;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Remove Filter'),
                    ),
                    const SizedBox(width: 10),
                    _showFilterFields
                        ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (soReportProvider.hasFiltersChanged) {
                            soReportProvider.applyFilter();
                          }
                          _showFilterFields = !_showFilterFields;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply Filter'),
                    )
                        : const SizedBox(),
                  ],
                ),
              ),

              // Add this new Positioned widget for loading more indicator
              if (soReportProvider.isLoadingMore)
                Positioned(
                  bottom: 25,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: SizedBox(
                      width: 20, // Set width
                      height: 20, // Set height
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                        strokeWidth: 2.5, // Make the line thinner
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableTab(List<Data> sampleData, bool showFilter, SoReportProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              const Text('Plant: '),
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildPlantDropdown(provider),
              ),
            ],
          ),
        ),
        showFilter
            ? Container(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 150, child: _buildExWorkColorDropdown(provider)),
                    const SizedBox(width: 4),
                    SizedBox(width: 150, child: _buildCddColorDropdown(provider)),
                    const SizedBox(width: 4),
                    SizedBox(width: 150, child: _buildCustomerDropdown(provider)),
                    const SizedBox(width: 4),
                    SizedBox(width: 150, child: _buildFgCodeDropdown(provider)),
                    const SizedBox(width: 4),
                    SizedBox(width: 150, child: _buildSoNoDropdown(provider)),
                    const SizedBox(width: 4),
                    SizedBox(width: 150, child: _buildProjectDropdown(provider)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 150, child: _buildItemSubgroupDropdown(provider)),
                    const SizedBox(width: 4),
                    SizedBox(width: 150, child: _buildAlertsDropdown(provider)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 300,
                      height: 32,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search PONO And Customer Part No.',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 109, 109, 109), fontSize: 12.5),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            : const SizedBox(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalController,
            child: SizedBox(
              width: 1510,
              child: Column(
                children: [
                  Container(
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        _buildHeaderCell('Priority', 80),
                        _buildHeaderCell('Sr. No.', 80),
                        _buildHeaderCell('SO. No.', 150),
                        _buildHeaderCell('SO. Line No.', 100),
                        _buildHeaderCell('SO. Date', 100),
                        _buildHeaderCell('Customer', 200),
                        _buildHeaderCell('Project No.', 100),
                        _buildHeaderCell('Product Code', 150),
                        _buildHeaderCell('Product Description', 200),
                        _buildHeaderCell('PO. No.', 150),
                        _buildHeaderCell('PO. Date', 100),
                        _buildHeaderCell('PO Diff. Days', 100),
                      ],
                    ),
                  ),
                  Expanded(
                    child: sampleData.isEmpty && !provider.isLoading
                        ? const Center(
                      child: Text(
                        'No records found',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : SingleChildScrollView(
                      controller: _verticalController,
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          ...sampleData.map((item) {
                            return Row(
                              children: [
                                _buildDataCell(item.aSSIGNPRIORITY.toString(), 80),
                                _buildDataCell(item.sRNO.toString(), 80),
                                _buildDataCell(item.sONO ?? '', 150),
                                _buildDataCell(item.sOLineNo.toString(), 100),
                                _buildDataCell(item.sODATE ?? '', 100),
                                _buildDataCell(item.customer ?? '', 200),
                                _buildDataCell(item.pROJNO ?? '', 100),
                                _buildDataCell(item.itemCode ?? '', 150),
                                _buildDataCell(item.itemDescription ?? '', 200),
                                _buildDataCell(item.pONO ?? '', 150),
                                _buildDataCell(item.pODATE ?? '', 100),
                                _buildDataCell(item.podiffdays.toString(), 100),
                              ],
                            );
                          }).toList(),
                          if (provider.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
          right: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
          right: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPlantDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Select plant', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectplant,
                items: provider.dropdownData?.data?.plant.map((plant) {
                      return DropdownMenuItem<String>(
                        value: plant.orgstrucid.toString(),
                        child: Text(plant.description ?? 'Unknown',
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updatePlant(value);
                },
              ),
            ),
    );
  }

  // Custom dropdown implementations
  Widget _buildExWorkColorDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Ex-Work Color', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedExWorkColor,
                items: provider.dropdownData?.data?.exWorkColor.map((color) {
                      return DropdownMenuItem<String>(
                        value: color.id.toString(),
                        child: Text(color.text ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateExWorkColor(value);
                },
              ),
            ),
    );
  }

  Widget _buildCddColorDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('CDD Color', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedCddColor,
                items: provider.dropdownData?.data?.cddColor.map((color) {
                      return DropdownMenuItem<String>(
                        value: color.id.toString(),
                        child: Text(color.text ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateCddColor(value);
                },
              ),
            ),
    );
  }

  Widget _buildCustomerDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Customer', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedCustomer,
                items: provider.dropdownData?.data?.customer.map((customer) {
                      return DropdownMenuItem<String>(
                        value: customer.custid.toString(),
                        child: Text(customer.customer ?? 'Unknown',
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateCustomer(value);
                },
              ),
            ),
    );
  }

  Widget _buildFgCodeDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('FG Code', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedFgCode,
                items: provider.dropdownData?.data?.fgCode.map((fgCode) {
                      return DropdownMenuItem<String>(
                        value: fgCode.itemid.toString(),
                        child: Text(fgCode.itemcode ?? 'Unknown',
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateFgCode(value);
                },
              ),
            ),
    );
  }

  Widget _buildSoNoDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('SO No.', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedSoNo,
                items: provider.dropdownData?.data?.soNo.map((soNo) {
                      return DropdownMenuItem<String>(
                        value: soNo.usoid.toString(),
                        child: Text(soNo.sono.toString(), style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateSoNo(value);
                },
              ),
            ),
    );
  }

  Widget _buildProjectDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Project', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedProject,
                items: provider.dropdownData?.data?.project.map((project) {
                      return DropdownMenuItem<String>(
                        value: project.projectId.toString(),
                        child: Text(project.name.toString(), style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateProject(value);
                },
              ),
            ),
    );
  }

  Widget _buildItemSubgroupDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Item Subgroup', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedItemSubgroup,
                items: provider.dropdownData?.data?.itemSubgroup.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.grpid.toString(),
                        child:
                            Text(item.grpdesc ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateItemSubgroup(value);
                },
              ),
            ),
    );
  }

  Widget _buildAlertsDropdown(SoReportProvider provider) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: provider.isLoadingDropdown
          ? const Center(
              child:
                  SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('Alerts', style: TextStyle(fontSize: 13)),
                isExpanded: true,
                value: provider.selectedAlert,
                items: provider.dropdownData?.data?.alerts.map((alert) {
                      return DropdownMenuItem<String>(
                        value: alert.statusid.toString(),
                        child: Text(alert.name ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList() ??
                    [],
                onChanged: (value) {
                  provider.updateAlert(value);
                },
              ),
            ),
    );
  }
}
