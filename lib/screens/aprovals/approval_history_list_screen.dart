import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../models/LoginResponseModel.dart';
import '../../models/get_approval_list_request_model.dart';
import '../../models/get_approval_list_response_model.dart';
import '../../models/get_approvals_list_model.dart';
import '../../provider/themecontroller.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import 'approvals_controller.dart';
import 'approvals_history_details.dart';

// ============================================================================
// FILTER OPTION MODEL
// ============================================================================

class HistoryFilterOption {
  final String description;
  final String invoiceType;

  const HistoryFilterOption({
    required this.description,
    required this.invoiceType,
  });

  String get displayText {
    if (invoiceType.isEmpty) {
      return description;
    }

    return "$invoiceType | $description";
  }
}

// ============================================================================
// APPROVAL HISTORY LIST
// ============================================================================

class ApprovalsHistoryListFragment extends StatefulWidget {
  final LoginResponseModel? loginResponseModel;
  final String apibaseurl = "";

  const ApprovalsHistoryListFragment({
    super.key,
    required this.loginResponseModel,
  });

  @override
  State<ApprovalsHistoryListFragment> createState() =>
      _ApprovalsHistoryListFragmentState();
}

class _ApprovalsHistoryListFragmentState
    extends State<ApprovalsHistoryListFragment> {
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const int _numberOfPostsPerRequest = 10;

  // ============================================================
  // PAGINATION
  // ============================================================

  late final PagingController<int, LISTAPPROVAL> _pagingController;

  // ============================================================
  // LOGIN
  // ============================================================

  LoginResponseModel? get loginResponseModel =>
      widget.loginResponseModel;

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController searchController =
  TextEditingController();

  bool searchBarEnabled = false;

  String searchFlag = "0";

  late final VoidCallback _searchListener;

  // ============================================================
  // DATA
  // ============================================================

  GetApprovalListResponseModel? getApprovalListModel =
  GetApprovalListResponseModel();

  // ============================================================
  // FILTER
  // ============================================================

  String selectedDocDesc = "All";

  String selectedInvoiceType = "";

  // ============================================================
  // UI
  // ============================================================

  int _selectedIndex = 0;

  late ThemeController themeController;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, LISTAPPROVAL>(
      firstPageKey: 1,
    );

    // ----------------------------------------------------------
    // PAGINATION
    // ----------------------------------------------------------

    _pagingController.addPageRequestListener(
          (pageKey) {
        if (!mounted) return;

        _fetchPage(
          pageKey: pageKey,
          searchText: searchController.text.trim(),
        );
      },
    );

    // ----------------------------------------------------------
    // SEARCH LISTENER
    // ----------------------------------------------------------

    _searchListener = () {
      if (!mounted) return;

      if (searchController.text.trim().isEmpty &&
          searchFlag == "1") {
        setState(() {
          searchFlag = "0";
        });

        _refreshList();
      }
    };

    searchController.addListener(_searchListener);

    // ----------------------------------------------------------
    // PORTRAIT
    // ----------------------------------------------------------

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.removeListener(_searchListener);
    searchController.dispose();

    _pagingController.dispose();

    super.dispose();
  }

  // ============================================================
  // DOCUMENT FILTER OPTIONS
  //
  // Displays:
  //
  // Suppliers | U1-SU
  // Purchase Invoice | U1-PI
  // Sales Invoice | U1-SI
  //
  // Using:
  // DOCDESC | INVCTYPE
  // ============================================================

  List<HistoryFilterOption> get docDescFilterOptions {
    final Map<String, HistoryFilterOption> values =
    <String, HistoryFilterOption>{};

    final List<LISTAPPROVAL> list =
        getApprovalListModel?.dATA?.lIST ?? <LISTAPPROVAL>[];

    for (final LISTAPPROVAL item in list) {
      final String description =
          item.dOCDESC?.trim() ?? "";

      final String invoiceType =
          item.iNVCTYPE?.trim() ?? "";

      if (description.isEmpty &&
          invoiceType.isEmpty) {
        continue;
      }

      final String key =
      "$invoiceType | $description".toLowerCase();

      values[key] = HistoryFilterOption(
        description: description,
        invoiceType: invoiceType,
      );
    }

    final List<HistoryFilterOption> sortedValues =
    values.values.toList()
      ..sort(
            (
            HistoryFilterOption a,
            HistoryFilterOption b,
            ) {
          return a.displayText
              .toLowerCase()
              .compareTo(
            b.displayText.toLowerCase(),
          );
        },
      );

    return <HistoryFilterOption>[
      const HistoryFilterOption(
        description: "All",
        invoiceType: "",
      ),
      ...sortedValues,
    ];
  }

  // ============================================================
  // REFRESH LIST
  // ============================================================

  void _refreshList() {
    if (!mounted) return;

    _pagingController.refresh();
  }

  // ============================================================
  // RESET HISTORY LIST
  // ============================================================

  void _resetHistoryList() {
    if (!mounted) return;

    setState(() {
      selectedDocDesc = "All";
      selectedInvoiceType = "";
      searchFlag = "0";
    });

    searchController.clear();

    getApprovalListModel =
        GetApprovalListResponseModel();

    _pagingController.refresh();
  }

  // ============================================================
  // SEARCH SUBMIT
  // ============================================================

  void _submitSearch(String value) {
    final String searchText = value.trim();

    if (searchText.isEmpty) {
      setState(() {
        searchFlag = "0";
      });

      _refreshList();
      return;
    }

    if (searchText.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter at least 2 characters",
          ),
        ),
      );

      return;
    }

    setState(() {
      searchFlag = "1";
    });

    _refreshList();
  }

  // ============================================================
  // SHOW FILTER
  // ============================================================

  Future<void> _showDocDescFilter() async {
    final HistoryFilterOption? result =
    await showGeneralDialog<HistoryFilterOption>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(
        milliseconds: 200,
      ),
      pageBuilder: (
          dialogContext,
          animation,
          secondaryAnimation,
          ) {
        return HistoryFilterDialog(
          options: docDescFilterOptions,
          selectedValue: selectedDocDesc,
          selectedInvoiceType: selectedInvoiceType,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      selectedDocDesc =
      result.description.trim().isEmpty
          ? "All"
          : result.description.trim();

      selectedInvoiceType =
          result.invoiceType.trim();

      searchFlag = "0";
    });

    searchController.clear();

    getApprovalListModel =
        GetApprovalListResponseModel();

    _pagingController.refresh();
  }

  // ============================================================
  // REMOVE FILTER
  // ============================================================

  void _removeFilter() {
    setState(() {
      selectedDocDesc = "All";
      selectedInvoiceType = "";
    });

    getApprovalListModel =
        GetApprovalListResponseModel();

    _refreshList();
  }

  // ============================================================
  // BUILD LABEL VALUE ROW
  // ============================================================

  Widget buildLabelValueRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: Platform.isIOS ? 17 : 14,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              fontSize: Platform.isIOS ? 17 : 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final double screenWidth =
        MediaQuery.of(context).size.width;

    final bool isDesktop = screenWidth >= 700;

    themeController =
        Provider.of<ThemeController>(
          context,
          listen: false,
        );

    final UnreadNotificationProvider unreadProvider =
    Provider.of<UnreadNotificationProvider>(
      context,
    );

    return PopScope(
      canPop: !searchBarEnabled,
      onPopInvoked: (bool didPop) {
        if (didPop) return;

        if (searchBarEnabled) {
          searchController.clear();

          setState(() {
            searchBarEnabled = false;
            searchFlag = "0";
          });

          _refreshList();
        }
      },
      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: isDesktop
                ? Colors.white
                : const Color(0xffF5F7FA),

            // ======================================================
            // APP BAR
            // ======================================================

            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                child: SizedBox(
                  width: isDesktop ? 700 : double.infinity,
                  child: AppBar(
                    backgroundColor:
                    themeController.primaryColor,
                    foregroundColor: Colors.white,
                    titleSpacing: 1,

                    title: searchBarEnabled
                        ? _buildSearchBar()
                        : Text(
                      "Approval History",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize:
                        Platform.isIOS ? 17 : 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),

                    actions: [
                      if (!searchBarEnabled)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              searchBarEnabled = true;
                            });
                          },
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),

                      if (!searchBarEnabled)
                        IconButton(
                          onPressed: _showDocDescFilter,
                          icon: const Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ======================================================
            // BOTTOM NAVIGATION
            // ======================================================

            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle:
                MaterialStateProperty.resolveWith<TextStyle>(
                      (Set<MaterialState> states) {
                    if (states.contains(
                      MaterialState.selected,
                    )) {
                      return TextStyle(
                        fontSize:
                        Platform.isIOS ? 13 : 10,
                        fontWeight: FontWeight.w600,
                      );
                    }

                    return TextStyle(
                      fontSize:
                      Platform.isIOS ? 12 : 9,
                    );
                  },
                ),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected:
                _onNavigationDestinationSelected,
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
                    label: "Home",
                  ),

                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible:
                      unreadProvider.unreadCount > 0,
                      label: Text(
                        unreadProvider.unreadCount.toString(),
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
                    label: "Alerts",
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
                    label: "Reports",
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
                    label: "Assistant",
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
                    label: "Profile",
                  ),
                ],
              ),
            ),

            // ======================================================
            // BODY
            // ======================================================

            body: Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: isDesktop ? 700 : double.infinity,
                color: const Color(0xFFF5F7FB),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // ACTIVE FILTER
                    // ==================================================

                    if (selectedDocDesc != "All")
                      _buildActiveFilter(),

                    // ==================================================
                    // HISTORY LIST
                    // ==================================================

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _pagingController.refresh();
                        },
                        child:
                        PagedListView<int, LISTAPPROVAL>(
                          pagingController:
                          _pagingController,
                          padding: const EdgeInsets.only(
                            top: 6,
                            bottom: 10,
                          ),
                          builderDelegate:
                          PagedChildBuilderDelegate<
                              LISTAPPROVAL>(
                            firstPageErrorIndicatorBuilder:
                            errorIndicator,

                            noItemsFoundIndicatorBuilder:
                            noHistoryIndicator,

                            newPageErrorIndicatorBuilder:
                                (context) {
                              return _buildPageError();
                            },

                            firstPageProgressIndicatorBuilder:
                                (context) {
                              return _buildLoadingIndicator();
                            },

                            newPageProgressIndicatorBuilder:
                                (context) {
                              return _buildLoadingIndicator();
                            },

                            itemBuilder: (
                                context,
                                item,
                                index,
                                ) {
                              return _buildHistoryItem(item);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        right: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: searchController,
        style: GoogleFonts.lato(
          color: Colors.black,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _submitSearch,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF123E68),
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.grey,
            ),
            onPressed: () {
              searchController.clear();

              setState(() {
                searchFlag = "0";
              });

              _refreshList();
            },
          ),
          hintText: "Search...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVE FILTER
  // ============================================================

  Widget _buildActiveFilter() {
    final String filterText =
    selectedInvoiceType.isEmpty
        ? selectedDocDesc
        : "$selectedInvoiceType | $selectedDocDesc";

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            size: 18,
            color: Color(0xFF123E68),
          ),

          const SizedBox(width: 7),

          const Text(
            "Filter:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              filterText,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),
          ),

          InkWell(
            onTap: _removeFilter,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY ITEM
  // ============================================================

  Widget _buildHistoryItem(
      LISTAPPROVAL item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: GestureDetector(
        onTap: () {
          _openHistoryDetails(item);
        },
        child: Card(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color(0xFFD9E2EC),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 125,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.iNVCTYPE ?? "",
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(
                                  0xFFC0504D,
                                ),
                                fontWeight:
                                FontWeight.w400,
                                fontSize:
                                Platform.isIOS
                                    ? 14.5
                                    : 11.5,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration:
                            BoxDecoration(
                              color: const Color(
                                0xFFEAF1F8,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              item.dUEDATE ?? "",
                              style: TextStyle(
                                fontSize:
                                Platform.isIOS
                                    ? 13.5
                                    : 10.5,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        item.iNVCNUMB ?? "",
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                          Platform.isIOS ? 16 : 13,
                          fontWeight:
                          FontWeight.w700,
                          color: const Color(
                            0xFF123E68,
                          ),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _getDescription(item),
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                          Platform.isIOS
                              ? 14.5
                              : 11.5,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "Type : ${item.dOCDESC ?? ""}",
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize:
                          Platform.isIOS
                              ? 12.5
                              : 10.5,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "GL : ${item.gLDESC ?? ""}",
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize:
                          Platform.isIOS
                              ? 14.5
                              : 11.5,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "₹ ${item.dOCAMT ?? "0"}",
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(
                                  0xFF1A4A7A,
                                ),
                                fontSize:
                                Platform.isIOS
                                    ? 15
                                    : 12,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "Release By : ${item.cREATEDBYNAME ?? ""}",
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize:
                          Platform.isIOS
                              ? 14.5
                              : 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  String _getDescription(
      LISTAPPROVAL item) {
    final String salesDescription =
        item.sLDESC?.trim() ?? "";

    if (salesDescription.isNotEmpty) {
      return salesDescription;
    }

    return item.dOCDESC?.trim() ?? "";
  }

  // ============================================================
  // OPEN DETAILS
  // ============================================================

  void _openHistoryDetails(
      LISTAPPROVAL item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 10),
        reverseTransitionDuration:
        const Duration(milliseconds: 10),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return ApprovalsHistoryDetailsScreen(
            item,
            loginResponseModel,
          );
        },
        transitionsBuilder: (
            context,
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
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void>
  _onNavigationDestinationSelected(
      int index,
      ) async {
    if (!mounted) return;

    setState(() {
      _selectedIndex = index;
    });

    final String plantName =
        context.read<PlantProvider>().plantName;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 10),
        reverseTransitionDuration:
        const Duration(milliseconds: 10),
        pageBuilder: (
            _,
            animation,
            secondaryAnimation,
            ) {
          return AppShell(
            role: "Admin",
            plant: plantName,
            selectedIndex: index,
          );
        },
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
  }

  // ============================================================
  // ERROR INDICATOR
  // ============================================================

  Widget errorIndicator(
      BuildContext context) {
    return _buildEmptyState(
      icon: Icons.error_outline,
      title: "Unable to load history",
      subtitle:
      "Please check your internet connection and try again.",
      showRetry: true,
    );
  }

  // ============================================================
  // NO HISTORY
  // ============================================================

  Widget noHistoryIndicator(
      BuildContext context) {
    final bool isSearch =
        searchFlag == "1" &&
            searchController.text.trim().isNotEmpty;

    return _buildEmptyState(
      icon: isSearch
          ? Icons.search_off
          : Icons.history,
      title: isSearch
          ? "No history found"
          : "No approval history",
      subtitle: isSearch
          ? "Try another search term."
          : selectedDocDesc != "All"
          ? "No records found for the selected document type."
          : "There are no approval history records available.",
      showRetry: false,
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xffEAF1F8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: const Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            if (showRetry) ...[
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _refreshList,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF123E68),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Try Again",
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF123E68),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE ERROR
  // ============================================================

  Widget _buildPageError() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            const Text(
              "Unable to load more records",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                _pagingController
                    .retryLastFailedRequest();
              },
              child: const Text(
                "Retry",
                style: TextStyle(
                  color: Color(0xFF123E68),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FETCH PAGE
  // ============================================================

  Future<void> _fetchPage({
    required int pageKey,
    required String searchText,
  }) async {
    try {
      // ----------------------------------------------------------
      // LOGIN VALIDATION
      // ----------------------------------------------------------

      final LoginResponseModel? login =
          loginResponseModel;

      if (login == null ||
          login.data == null) {
        throw Exception(
          "Login information is not available",
        );
      }

      // ----------------------------------------------------------
      // INTERNET CHECK
      // ----------------------------------------------------------

      final CommonUtils commonUtils =
      CommonUtils();

      final bool isConnectivity =
      await commonUtils.check();

      if (!isConnectivity) {
        if (!mounted) return;

        _pagingController.error =
            Exception(
              "Please check Internet Connection",
            );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Please check Internet Connection",
            ),
          ),
        );

        return;
      }

      // ----------------------------------------------------------
      // REQUEST
      // ----------------------------------------------------------

      final GetApprovalListRequestModel request =
      GetApprovalListRequestModel();

      request.xMLFILE = XMLFILEAPPROVALS();

      request.xMLFILE!.dOCID = "0";
      request.xMLFILE!.dUEDATE = "";
      request.xMLFILE!.fLAG = "2";
      request.xMLFILE!.fROMDATE = "";
      request.xMLFILE!.mENUID = "0";
      request.xMLFILE!.mID = "0";

      request.xMLFILE!.oRGSTRUCTID =
      login.data!.orgstrucid!;

      request.xMLFILE!.pAGENO =
          pageKey;

      request.xMLFILE!.pOSID =
          login.data!.posid;

      request.xMLFILE!.tODATE = "";

      request.xMLFILE!.tOKEN =
          login.data!.token;

      request.xMLFILE!.uSERID =
          login.data!.userid;

      // ----------------------------------------------------------
      // SEARCH
      // ----------------------------------------------------------

      if (searchFlag == "1") {
        if (searchText.length < 2) {
          if (pageKey == 1) {
            _pagingController.appendLastPage(
              <LISTAPPROVAL>[],
            );
          }

          return;
        }

        request.xMLFILE!.dESC =
            searchText;
      } else {
        request.xMLFILE!.dESC = "";
      }

      // ----------------------------------------------------------
      // API CONTROLLER
      // ----------------------------------------------------------

      final ApprovalsController controller =
      Provider.of<ApprovalsController>(
        context,
        listen: false,
      );

      final GetApprovalListResponseModel?
      response =
      await controller.GetApprovalListDetails(
        request,
        context,
      );

      if (!mounted) return;

      getApprovalListModel = response;

      // ----------------------------------------------------------
      // API LIST
      // ----------------------------------------------------------

      final List<LISTAPPROVAL> apiList =
          response?.dATA?.lIST ??
              <LISTAPPROVAL>[];

      // ----------------------------------------------------------
      // DOCUMENT FILTER
      //
      // Filter by BOTH:
      //
      // DOCDESC
      // INVCTYPE
      //
      // Example:
      // Suppliers | U1-SU
      // ----------------------------------------------------------

      final List<LISTAPPROVAL> filteredList =
      selectedDocDesc == "All"
          ? apiList
          : apiList.where(
            (LISTAPPROVAL item) {
          final String docDesc =
              item.dOCDESC
                  ?.trim()
                  .toLowerCase() ??
                  "";

          final String invoiceType =
              item.iNVCTYPE
                  ?.trim()
                  .toLowerCase() ??
                  "";

          final bool descMatches =
              docDesc ==
                  selectedDocDesc
                      .trim()
                      .toLowerCase();

          final bool invoiceTypeMatches =
              invoiceType ==
                  selectedInvoiceType
                      .trim()
                      .toLowerCase();

          return descMatches &&
              invoiceTypeMatches;
        },
      ).toList();

      // ----------------------------------------------------------
      // PAGINATION
      // ----------------------------------------------------------

      final bool isLastPage =
          apiList.length <
              _numberOfPostsPerRequest;

      if (isLastPage) {
        _pagingController.appendLastPage(
          filteredList,
        );
      } else {
        _pagingController.appendPage(
          filteredList,
          pageKey + 1,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        "Approval History API error: $e",
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) return;

      _pagingController.error = e;
    }
  }
}

// ============================================================================
// HISTORY FILTER DIALOG
// ============================================================================

class HistoryFilterDialog
    extends StatefulWidget {
  final List<HistoryFilterOption> options;

  final String selectedValue;

  final String selectedInvoiceType;

  const HistoryFilterDialog({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.selectedInvoiceType,
  });

  @override
  State<HistoryFilterDialog> createState() =>
      _HistoryFilterDialogState();
}

class _HistoryFilterDialogState
    extends State<HistoryFilterDialog> {
  late final TextEditingController searchController;

  late HistoryFilterOption selectedOption;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    searchController =
        TextEditingController();

    selectedOption =
        widget.options.firstWhere(
              (HistoryFilterOption item) {
            return item.description ==
                widget.selectedValue &&
                item.invoiceType ==
                    widget.selectedInvoiceType;
          },
          orElse: () {
            return const HistoryFilterOption(
              description: "All",
              invoiceType: "",
            );
          },
        );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String searchText =
    searchController.text
        .trim()
        .toLowerCase();

    final List<HistoryFilterOption>
    filteredOptions =
    widget.options.where(
          (HistoryFilterOption item) {
        if (searchText.isEmpty) {
          return true;
        }

        return item.displayText
            .toLowerCase()
            .contains(searchText);
      },
    ).toList();

    final double screenWidth =
        MediaQuery.of(context).size.width;

    final double dialogWidth =
    screenWidth >= 700
        ? 650
        : screenWidth - 24;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: dialogWidth,
            margin: const EdgeInsets.only(
              top: 50,
              left: 12,
              right: 12,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  _buildHeader(),

                  const Divider(height: 1),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Padding(
                    padding:
                    EdgeInsets.fromLTRB(
                      18,
                      12,
                      18,
                      7,
                    ),
                    child: Text(
                      "Document Type",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  _buildSearchField(),

                  const SizedBox(height: 10),

                  // ==================================================
                  // OPTIONS
                  // ==================================================

                  _buildOptions(
                    filteredOptions,
                  ),

                  const SizedBox(height: 8),

                  const Divider(height: 1),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        10,
        10,
      ),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
              const Color(0xffEAF1F8),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.filter_alt_outlined,
              color: Color(0xFF123E68),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              "Filter History",
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText:
          "Search document type...",
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF123E68),
          ),
          suffixIcon:
          searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.clear,
              size: 19,
            ),
            onPressed: () {
              searchController
                  .clear();

              setState(() {});
            },
          )
              : null,
          filled: true,
          fillColor:
          const Color(0xffF5F7FB),
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide:
            const BorderSide(
              color: Color(0xFFD9E2EC),
            ),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide:
            const BorderSide(
              color: Color(0xFFD9E2EC),
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide:
            const BorderSide(
              color: Color(0xFF123E68),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPTIONS
  // ============================================================

  Widget _buildOptions(
      List<HistoryFilterOption>
      filteredOptions,
      ) {
    if (filteredOptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(25),
        child: Center(
          child: Text(
            "No document type found",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Container(
      constraints:
      const BoxConstraints(
        maxHeight: 300,
      ),
      margin:
      const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount:
        filteredOptions.length,
        itemBuilder: (
            context,
            index,
            ) {
          final HistoryFilterOption option =
          filteredOptions[index];

          final bool isSelected =
              selectedOption.description ==
                  option.description &&
                  selectedOption.invoiceType ==
                      option.invoiceType;

          return InkWell(
            borderRadius:
            BorderRadius.circular(10),
            onTap: () {
              setState(() {
                selectedOption =
                    option;
              });
            },
            child: Container(
              margin:
              const EdgeInsets.symmetric(
                vertical: 2,
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(
                  0xffEAF1F8,
                )
                    : Colors.transparent,
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    option.description ==
                        "All"
                        ? Icons.select_all
                        : Icons
                        .description_outlined,
                    size: 20,
                    color: isSelected
                        ? const Color(
                      0xFF123E68,
                    )
                        : Colors.grey,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      option.displayText,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        isSelected
                            ? FontWeight
                            .w700
                            : FontWeight
                            .w400,
                        color: isSelected
                            ? const Color(
                          0xFF123E68,
                        )
                            : Colors.black87,
                      ),
                    ),
                  ),

                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color:
                      Color(0xFF123E68),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // ------------------------------------------------------
          // CLEAR
          // ------------------------------------------------------

          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  const HistoryFilterOption(
                    description: "All",
                    invoiceType: "",
                  ),
                );
              },
              style:
              OutlinedButton.styleFrom(
                minimumSize:
                const Size(0, 44),
                side:
                const BorderSide(
                  color:
                  Color(0xFFD9E2EC),
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),
              child: const Text(
                "Clear",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ------------------------------------------------------
          // APPLY
          // ------------------------------------------------------

          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  selectedOption,
                );
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFF123E68,
                ),
                foregroundColor:
                Colors.white,
                elevation: 0,
                minimumSize:
                const Size(0, 44),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),
              child: const Text(
                "Apply Filter",
                style: TextStyle(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
