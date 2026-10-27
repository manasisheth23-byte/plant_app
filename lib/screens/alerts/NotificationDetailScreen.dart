

import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/provider/get_notification_provider.dart';
import 'package:erpflutter/models/notification_detail_response.dart';

import '../../provider/themecontroller.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NitificationLIST notificationitem;

  const NotificationDetailScreen({
    super.key,
    required this.notificationitem,
  });

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends State<NotificationDetailScreen> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late ThemeController themeController;

  String _searchQuery = "";

  int _idx = 1;

  bool _orientationChanged = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(widget.notificationitem.nID.toString());
      Provider.of<GetNotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications(
        widget.notificationitem.nID.toString(),
      );
    });
  }

  @override
  void dispose() {
    // Return mobile device to portrait
    // when leaving this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.dispose();
      _verticalController.dispose();
      _horizontalController.dispose();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);


    });



    super.dispose();
  }

  // ============================================================
  // ORIENTATION
  // ============================================================

  void _handleOrientation(bool hasRecords) {
    if (!mounted) return;

    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 700;

    // Windows/Desktop:
    // Don't force orientation.
    if (!isMobile) {
      return;
    }

    if (hasRecords) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }


  // ============================================================
  // DISPLAY VALUE
  // ============================================================

  String _displayValue(String value) {
    if (value.trim().isEmpty) {
      return "-";
    }

    // Your API uses 1900-01-01 for empty dates.
    if (value == "1900-01-01" ||
        value == "1900-01-01 00:00:00") {
      return "-";
    }

    return value;
  }

  // ============================================================
  // NOTIFICATION HEADER
  // ============================================================

  Widget _buildNotificationHeader(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.notificationitem.tITLE ?? "Notification",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (widget.notificationitem.sTATUS
                  ?.trim()
                  .isNotEmpty ??
                  false)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.notificationitem.sTATUS!.trim(),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            widget.notificationitem.mSGBODY ?? "No Message",
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 14),

          if (!isDesktop)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 17,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${widget.notificationitem.nOTIFYDATE ?? ""} "
                            "${widget.notificationitem.notifytime ?? ""}",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 17,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.notificationitem.nOTIFYBYNAME ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  "${widget.notificationitem.nOTIFYDATE ?? ""} "
                      "${widget.notificationitem.notifytime ?? ""}",
                  style: GoogleFonts.lato(
                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.person,
                  size: 17,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),

                Flexible(
                  child: Text(
                    widget.notificationitem.nOTIFYBYNAME ?? "",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  // NO RECORD VIEW
  // ============================================================

  Widget _buildNoRecordsView(bool isDesktop) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F7FB),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildNotificationHeader(isDesktop),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 50,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "No Records Available",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "There are no details available for this notification.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATA TABLE
  // ============================================================

  Widget _buildDataTable(
      BuildContext context,
      List<dynamic> details,
      List<String> columnNames,
      ) {
    final columns = columnNames
        .where((column) => column != "MID")
        .toList();

    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 52,

          dataRowMinHeight: 48,

          dataRowMaxHeight: 62,

          columnSpacing: 24,

          horizontalMargin: 12,

          headingRowColor: MaterialStateProperty.all(
            themeController.primaryColor,
          ),

          border: TableBorder.all(
            color: Colors.grey.shade300,
          ),

          columns: columns.map(
                (column) {
              return DataColumn(
                label: SizedBox(
                  width: 125,
                  child: Text(
                    column.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          ).toList(),

          rows: details.map(
                (row) {
              return DataRow(
                cells: columns.map(
                      (column) {
                    final value = row.data.firstWhere(
                          (d) => d.columnName == column,
                      orElse: () => DataField(
                        columnName: column,
                        values: "",
                      ),
                    );

                    return DataCell(
                      SizedBox(
                        width: 125,
                        child: Text(
                          _displayValue(value.values),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // RECORD SECTION
  // ============================================================

  Widget _buildRecordsSection(
      BuildContext context,
      List<dynamic> details,
      bool isDesktop,
      ) {
    final List<String> columnNames =
    details.first.data
        .map<String>(
          (e) => e.columnName.toString(),
    )
        .toList();

    final filteredDetails = details.where((row) {
      final allValues = row.data
          .map<String>(
            (d) => d.values.toString().toLowerCase(),
      )
          .join(" ");

      return allValues.contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // TABLE HEADER
          // ======================================================
          if (filteredDetails.isNotEmpty)...[
          Row(
            children: [
              Text(
                "",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: isDesktop ? 280 : 220,
                height: 42,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: GoogleFonts.lato(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                    const EdgeInsets.symmetric(
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // RECORD COUNT
          // ======================================================

      /*    Row(
            children: [
              Icon(
                Icons.table_rows_outlined,
                size: 17,
                color: themeController.primaryColor,
              ),

              const SizedBox(width: 6),

              Text(
                "${filteredDetails.length} record(s)",
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (!isDesktop) ...[
                const Spacer(),

                Icon(
                  Icons.swipe,
                  size: 17,
                  color: Colors.grey.shade500,
                ),

                const SizedBox(width: 5),

                Text(
                  "Swipe horizontally",
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),*/



          // ======================================================
          // TABLE
          // ======================================================




            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildDataTable(
                context,
                filteredDetails,
                columnNames,
              ),
            ),
        ],]
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    final bool isDesktop = screenWidth >= 700;

    themeController =
        Provider.of<ThemeController>(
          context,
          listen: false,
        );

    final unreadProvider =
    Provider.of<UnreadNotificationProvider>(
      context,
    );

    return Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          // ======================================================
          // APP BAR
          // ======================================================

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),

            child: Center(
              child: SizedBox(
                width: isDesktop
                    ? 700
                    : double.infinity,

                child: AppBar(
                  foregroundColor: Colors.white,

                  backgroundColor:
                  themeController.primaryColor,

                  title: Text(
                    'Notification Details',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),

                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // BOTTOM NAVIGATION
          // ======================================================

          bottomNavigationBar:
          NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle:
              MaterialStateProperty.resolveWith<
                  TextStyle>(
                    (states) {
                  if (states.contains(
                    MaterialState.selected,
                  )) {
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

              onDestinationSelected:
                  (index) async {
                    if (index == 3) {
                      showDialog( context: context, builder: (context) =>
                          AlertDialog( title: const Text("Coming Soon 🚀"),
                            content: const Text( "This feature is under development and will be available soon.", ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text("OK"), ), ], ), ); return; }
                final plantName =
                    context
                        .read<PlantProvider>()
                        .plantName;

                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration:
                    const Duration(
                      milliseconds: 10,
                    ),

                    reverseTransitionDuration:
                    const Duration(
                      milliseconds: 10,
                    ),

                    pageBuilder: (
                        _,
                        animation,
                        secondaryAnimation,
                        ) =>
                        AppShell(
                          role: "Admin",
                          plant: plantName,
                          selectedIndex: index,
                        ),

                    transitionsBuilder: (
                        _,
                        animation,
                        secondaryAnimation,
                        child,
                        ) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },

              height: 60,

              backgroundColor: Colors.white,

              indicatorColor: C.bluep,

              destinations: [
                const NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    size: 30,
                  ),

                  selectedIcon: Icon(
                    Icons.home,
                    color: C.blue,
                    size: 30,
                  ),

                  label: 'Home',
                ),

                NavigationDestination(
                  icon: Badge(
                    label: Text(
                      unreadProvider
                          .unreadCount
                          .toString(),
                    ),

                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 30,
                    ),
                  ),

                  selectedIcon: const Icon(
                    Icons.notifications,
                    size: 30,
                    color: C.blue,
                  ),

                  label: 'Alerts',
                ),

                const NavigationDestination(
                  icon: Icon(
                    Icons.bar_chart_outlined,
                    size: 30,
                  ),

                  selectedIcon: Icon(
                    Icons.bar_chart,
                    size: 30,
                    color: C.blue,
                  ),

                  label: 'Reports',
                ),

                const NavigationDestination(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    size: 30,
                  ),

                  selectedIcon: Icon(
                    Icons.chat_bubble,
                    size: 30,
                    color: C.blue,
                  ),

                  label: 'Assistant',
                ),

                const NavigationDestination(
                  icon: Icon(
                    Icons.person,
                    size: 30,
                  ),

                  selectedIcon: Icon(
                    Icons.person,
                    size: 30,
                    color: C.blue,
                  ),

                  label: 'Profile',
                ),
              ],
            ),
          ),

          // ======================================================
          // BODY
          // ======================================================

          body: Consumer<GetNotificationProvider>(
            builder: (
                context,
                provider,
                child,
                ) {
              // ==================================================
              // LOADING
              // ==================================================

              if (provider.loadingDetail) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // ==================================================
              // ERROR
              // ==================================================

              if (provider.error != null) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  if (mounted) {
                    _handleOrientation(false);
                  }
                });

                return Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(20),
                    child: Text(
                      provider.error!,
                      textAlign:
                      TextAlign.center,
                      style:
                      GoogleFonts.lato(),
                    ),
                  ),
                );
              }

              // ==================================================
              // CHECK RECORDS
              // ==================================================

              final bool hasRecords =
                  provider.response != null &&
                      provider.response!.details.isNotEmpty;

              // Orientation must be changed after build.
              WidgetsBinding.instance
                  .addPostFrameCallback((_) {
                if (mounted) {
                  _handleOrientation(
                    hasRecords,
                  );
                }
              });

              // ==================================================
              // NO RECORDS
              // ==================================================

              if (!hasRecords) {
                return _buildNoRecordsView(
                  isDesktop,
                );
              }

              // ==================================================
              // RECORDS AVAILABLE
              // ==================================================

              final details =
                  provider.response!.details;

              return Container(
                width: double.infinity,

                height: double.infinity,

                color:
                const Color(0xFFF5F7FB),

                child: Scrollbar(
                  controller:
                  _verticalController,

                  child:
                  SingleChildScrollView(
                    controller:
                    _verticalController,

                    padding:
                    const EdgeInsets.all(
                      15,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        // ========================================
                        // NOTIFICATION HEADER
                        // ========================================

                        _buildNotificationHeader(
                          isDesktop,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // ========================================
                        // DATA TABLE
                        // ========================================

                        _buildRecordsSection(
                          context,
                          details,
                          isDesktop,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DETAIL CARD
// ================================================================

class DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),

      padding:
      const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color:
              const Color(0xffEAF3FF),

              borderRadius:
              BorderRadius.circular(10),
            ),

            child: Icon(
              icon,
              color:
              const Color(0xff1565C0),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DETAIL ROW
// ================================================================

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.of(context).size.width >=
            700;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            '$label: ',

            style: TextStyle(
              fontSize:
              isDesktop ? 17 : 13,

              fontWeight:
              FontWeight.w700,

              color: Colors.red,
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: TextStyle(
                fontSize:
                isDesktop ? 17 : 13,

                fontWeight:
                FontWeight.w700,

                color:
                Colors.blueGrey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
