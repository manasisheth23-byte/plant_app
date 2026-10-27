import 'dart:io';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:erpflutter/barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import '../../Dashboard.dart';
import '../../app_colors.dart';
import '../../plantappscreen/app_shell.dart';
import '../../provider/themecontroller.dart';
import '../../screens/BarcodeQrcodeScanner/brcodeissuescanqrcode.dart';

class BarcodeRegistrationView extends StatefulWidget {
  const BarcodeRegistrationView({super.key});

  @override
  State<BarcodeRegistrationView> createState() =>
      _BarcodeRegistrationViewState();
}

class _BarcodeRegistrationViewState extends State<BarcodeRegistrationView> {
  final GlobalKey _documentDropdownKey = GlobalKey();
  OverlayEntry? _documentOverlayEntry;
  var item;
  bool isDocumentDropdownOpen = false;
  TextEditingController _docSearchController = TextEditingController();
  List<String> _filteredDocumentList = [];
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BarcodeProvider>(context, listen: false);

      provider.clearSelection();
      provider.loadDocumentNumbers();


      provider.loadAllTransactions();
    });
  }

  @override
  void dispose() {
  //  _removeDocumentOverlay();
    _docSearchController.dispose();
    super.dispose();
  }

  // -----------------------------
  // DOCUMENT DROPDOWN
  // -----------------------------
  Widget _buildDocumentDropdown(BuildContext context, BarcodeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "Document No",
          style: TextStyle(
            color:  themeController.primaryColor,
            fontWeight: FontWeight.w700,
          ),
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
                child:   GestureDetector(
          key: _documentDropdownKey,
          onTap: () => _toggleDocumentDropdown(context, provider),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider.selectedDocumentNo ?? "Select Document No",
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isDocumentDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ))),
      ],
    );
  }

  void _toggleDocumentDropdown(context, provider) {
    if (isDocumentDropdownOpen) {
      _removeDocumentOverlay();
    } else {
      _showDocumentOverlay(context, provider);
    }
  }

  void _showDocumentOverlay(BuildContext context, BarcodeProvider provider) {
    final renderBox =
    _documentDropdownKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    _filteredDocumentList = List<String>.from(provider.documentNoList);
    _docSearchController.text = "";

    _documentOverlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeDocumentOverlay,
          child: Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy ,
                width: size.width,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        position.dy -
                        size.height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Search Box
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: TextField(
                            controller: _docSearchController,
                            decoration: InputDecoration(
                              hintText: 'Select Document',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (text) {
                              _filteredDocumentList = provider.documentNoList
                                  .where((e) => e
                                  .toLowerCase()
                                  .contains(text.toLowerCase()))
                                  .toList();

                              _documentOverlayEntry?.markNeedsBuild();
                            },
                          ),
                        ),

                        const Divider(height: 1),

                        // List of Documents
                        Expanded(
                          child: _filteredDocumentList.isEmpty
                              ? const Center(
                            child: Text("No documents found"),
                          )
                              : ListView.separated(
                            itemCount: _filteredDocumentList.length,
                            separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                            itemBuilder: (_, index) {
                                item = _filteredDocumentList[index];
                              final isSelected =
                                  item == provider.selectedDocumentNo;

                              return ListTile(
                                dense: true,
                                title: Text(item),
                                trailing: isSelected
                                    ?  Icon(Icons.check,
                                    color:  themeController.primaryColor)
                                    : null,
                                onTap: () {
                                  /// Set selected & filter list
                                  provider.setSelectedDocumentNo(item);

                                  /// Now load only this document's records
                                  provider.loadAllTransactionsSelected(
                                      item);

                                  _removeDocumentOverlay();
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );

    overlay.insert(_documentOverlayEntry!);

    setState(() => isDocumentDropdownOpen = true);
  }

  void _removeDocumentOverlay() {
    if (_documentOverlayEntry != null) {
      _documentOverlayEntry!.remove();
      _documentOverlayEntry = null;
    }
    if (mounted) {
      setState(() => isDocumentDropdownOpen = false);
    }
  }

  // ----------------------------------------
  // UI
  // ----------------------------------------
  int _idx = 1;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return  Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          backgroundColor: isDesktop
              ? Colors.white // dark app background for Windows/Desktop
              : const Color(0xFFF5F7FB),

          // ================= APP BAR =================
          appBar:PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: SizedBox(
                      width: isDesktop ? 700 : double.infinity,
                      child: AppBar(
            foregroundColor: Colors.white,

            backgroundColor: themeController.primaryColor,
              elevation: 0,
              titleSpacing: 0,
              title: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Container(
                    height: 56,
                    alignment: Alignment.centerLeft,
                    child:  Text(
                      "Issues",
                      style:  GoogleFonts.lato(

                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      )
                    ),
                  ),
                ),
              ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop();
                 /* Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => Dashboard()),
                  );*/
                });
              },
            ),
            )))),
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
                        ),*/

              ],
            ),
          ),
          // ================= BODY =================
          body:SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child:Container(
        height: MediaQuery.of(context).size.height,
        color:const Color(0xFFF5F7FB),
        width: isDesktop ? 700 : double.infinity,
        padding: const EdgeInsets.all(0),
        child: Column(
                  children: [


                    // Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Consumer<BarcodeProvider>(
                        builder: (_, provider, __) =>
                            _buildDocumentDropdown(context, provider),
                      ),
                    ),

                    // List
                    Expanded(
                      child: Consumer<BarcodeProvider>(
                        builder: (_, provider, __) {
                          if (provider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final list = provider.transactions;

                          if (list.isEmpty) {
                            return const Center(child: Text("No data available"));
                          }

                         /* return ListView.builder(
                            itemCount: list.length,
                            padding: const EdgeInsets.only(
                                bottom: 10, left: 8, right: 8),
                            itemBuilder: (_, index) {
                              final lot = list[index];

                              return Card(
                                child: ListTile(
                                  onTap: () async {
                                    if (Platform.isAndroid) {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BarcodeIssueQRViewExample(
                                                lot: lot,
                                                documentNo:
                                                provider.selectedDocumentNo,
                                              ),
                                        ),
                                      );

                                      if (provider.selectedDocumentNo != null) {
                                        provider.loadAllTransactionsSelected(
                                          provider.selectedDocumentNo!,
                                        );
                                      } else {
                                        provider.loadAllTransactions();
                                      }
                                    }
                                  },
                                  title: Text(
                                    "${lot.invcType ?? ''} - ${lot.invcNumb ?? ''}",
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lot.itemCode ?? ''),
                                      Text(lot.itemDesc ?? ''),
                                      Text(
                                        "Quantity: "
                                            "${double.tryParse(lot.barcodeQty ?? '0')?.toInt() ?? 0}"
                                            " / "
                                            "${double.tryParse(lot.qty ?? '0')?.toInt() ?? 0}",
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.qr_code_scanner),
                                ),
                              );
                            },
                          );*/
                         return  ListView.builder(
                            itemCount: list.length,
                            padding: const EdgeInsets.all(12),


                             itemBuilder: (_, index) {
                              final lot = list[index];

                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  if (Platform.isAndroid) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BarcodeIssueQRViewExample(
                                          lot: lot,
                                          documentNo: provider.selectedDocumentNo,
                                        ),
                                      ),
                                    );

                                    if (provider.selectedDocumentNo != null) {
                                      provider.loadAllTransactionsSelected(
                                        provider.selectedDocumentNo!,
                                      );
                                    } else {
                                      provider.loadAllTransactions();
                                    }
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left Blue Border
                                      Container(
                                        width: 4,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F4C81),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${lot.invcType ?? ''} - ${lot.invcNumb ?? ''}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F4C81),
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            _infoRow(
                                              Icons.inventory_2_outlined,
                                              lot.itemCode ?? "",
                                            ),

                                            const SizedBox(height: 8),

                                            _infoRow(
                                              Icons.description_outlined,
                                              lot.itemDesc ?? "",
                                            ),

                                            const SizedBox(height: 8),

                                            _infoRow(
                                              Icons.qr_code,
                                              "Qty : "
                                                  "${double.tryParse(lot.barcodeQty ?? '0')?.toInt() ?? 0}"
                                                  " / "
                                                  "${double.tryParse(lot.qty ?? '0')?.toInt() ?? 0}",
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons.qr_code_scanner,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF0F4C81),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
