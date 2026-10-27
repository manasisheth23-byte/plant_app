import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/screens.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/ProfileScreen.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/alerts/alerts_list.dart';
import 'package:erpflutter/screens/chatbot/ChatBotScreen.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/report/report.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Dashboard.dart';
import '../../database/database_service.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/get_approval_list_request_model.dart';
import '../../models/get_approval_list_response_model.dart';
import '../../models/get_approvals_list_model.dart';
import '../../provider/themecontroller.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import 'approval_history_list_screen.dart';
import 'approvals_controller.dart';
import 'approvals_details_screen.dart';

class ApprovalsListFragment extends StatefulWidget {
  LoginResponseModel? loginResponseModel;
  String apibaseurl = "";

  ApprovalsListFragment({
    required this.loginResponseModel,
  });

  @override
  _ApprovalsListFragment createState() =>
      _ApprovalsListFragment(loginResponseModel);
}

class _ApprovalsListFragment extends State<ApprovalsListFragment> {
  TextEditingController cmobnoController = TextEditingController();

  LoginResponseModel? loginResponseModel;

  static int _numberOfPostsPerRequest = 10;

  late final PagingController<int, LISTAPPROVAL> _pagingController;

  static bool checkedValue = false;
  static String searchflag = "0";

  SizeConfig sizeConfig = SizeConfig();

  MediaQueryData? _mediaQueryData;
  double? screenWidth;
  double? screenHeight;

  int i = 1;

  static int callValue = 0;

  double? blockSizeHorizontal;

  static List<APPROVALSLIST>? getLeadList = [];

  static DatabaseService _databaseService = DatabaseService();

  SharedPreferences? prefs;

  bool _working = false;

  late ThemeController themeController;

  bool searchBarEnabled = false;

  TextEditingController searchController = TextEditingController();

  static GetApprovalListResponseModel? getApprovalListModel =
  GetApprovalListResponseModel();

  int _idx = 0;

  // ============================================================
  // DOCUMENT FILTER
  // ============================================================

  // Previously:
  // String selectedDocDesc = "All";

  String selectedDocFilter = "All";

  // ============================================================
  // SEARCH LISTENER
  // ============================================================

  late final VoidCallback _searchListener;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  _ApprovalsListFragment(this.loginResponseModel);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _ApprovalsListFragment.callValue = 0;
    _ApprovalsListFragment.getLeadList?.clear();
    _ApprovalsListFragment.searchflag = "0";

    searchController.removeListener(_searchListener);

    searchController.dispose();
    cmobnoController.dispose();

    _pagingController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOADING DIALOG
  // ============================================================

  void showLoadingDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.blue,
            backgroundColor: Colors.white,
          ),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Loading..."),
          ),
        ],
      ),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // ============================================================
  // BUILD ROW
  // ============================================================

  Widget buildRow({
    required String left,
    required String right,
    TextStyle? leftStyle,
    TextStyle? rightStyle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: leftStyle,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              right,
              style: rightStyle,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD LABEL VALUE ROW
  // ============================================================

  Widget buildLabelValueRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
  // DOCUMENT FILTER OPTIONS
  //
  // Example:
  //
  // INVCTYPE = U1-SU
  // DOCDESC   = Suppliers
  //
  // Dropdown:
  //
  // U1-SU | Suppliers
  // ============================================================

  List<String> get docDescFilterOptions {
    final Set<String> values = <String>{};

    final list = getApprovalListModel?.dATA?.lIST;

    if (list != null) {
      for (final item in list) {
        final String invcType =
            item.iNVCTYPE?.trim() ?? "";

        final String docDesc =
            item.dOCDESC?.trim() ?? "";

        String displayValue = "";

        if (invcType.isNotEmpty && docDesc.isNotEmpty) {
          displayValue = "$invcType | $docDesc";
        } else if (invcType.isNotEmpty) {
          displayValue = invcType;
        } else if (docDesc.isNotEmpty) {
          displayValue = docDesc;
        }

        if (displayValue.isNotEmpty) {
          values.add(displayValue);
        }
      }
    }

    final List<String> sortedValues = values.toList()..sort();

    return [
      "All",
      ...sortedValues,
    ];
  }

  // ============================================================
  // RESET PAGINATION
  // ============================================================

  void _resetApprovalList() {
    if (!mounted) return;

    callValue = 0;

    getLeadList?.clear();

    _pagingController.refresh();
  }

  // ============================================================
  // SHOW DOCUMENT FILTER
  // ============================================================

  Future<void> _showDocDescFilter() async {
    final String? result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
          dialogContext,
          animation,
          secondaryAnimation,
          ) {
        return ApprovalFilterDialog(
          options: docDescFilterOptions,
          selectedValue: selectedDocFilter,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      selectedDocFilter =
      result.trim().isEmpty ? "All" : result.trim();
    });

    callValue = 0;
    getLeadList?.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _pagingController.refresh();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;

    blockSizeHorizontal = (screenWidth! / 100);

    final bool isDesktop =
        MediaQuery.of(context).size.width >= 700;

    themeController = Provider.of<ThemeController>(
      context,
      listen: false,
    );

    final unreadProvider =
    Provider.of<UnreadNotificationProvider>(
      context,
    );

    return PopScope(
      canPop: !searchBarEnabled,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (searchBarEnabled) {
          searchController.clear();

          setState(() {
            searchBarEnabled = false;
            searchflag = "0";
          });

          callValue = 0;
          getLeadList?.clear();

          _pagingController.refresh();
        }
      },
      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: isDesktop
                ? Colors.white
                : const Color(0xffF5F7FA),

            // ========================================================
            // APP BAR
            // ========================================================

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
                        ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: TextField(
                          style: GoogleFonts.lato(),
                          controller: searchController,
                          textInputAction:
                          TextInputAction.search,
                          onSubmitted: (value) {
                            final String searchText =
                            value.trim();

                            if (searchText.length < 2) {
                              return;
                            }

                            callValue = 0;
                            getLeadList?.clear();
                            searchflag = "1";

                            _pagingController.refresh();
                          },
                          decoration:
                          const InputDecoration(
                            prefixIcon:
                            Icon(Icons.search),
                            hintText: 'Search...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    )
                        : Text(
                      'Approval List',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),

                    // ==================================================
                    // APP BAR ACTIONS
                    // ==================================================

                    actions: [
                      // SEARCH
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

                      // FILTER
                      if (!searchBarEnabled)
                        IconButton(
                          onPressed: _showDocDescFilter,
                          icon: const Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),

                      // HISTORY
                      if (!searchBarEnabled)
                        IconButton(
                          onPressed: () => Navigator.push(
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
                                  ApprovalsHistoryListFragment(
                                    loginResponseModel:
                                    loginResponseModel,
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
                          ),
                          icon: const Icon(
                            Icons.history,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ========================================================
            // BOTTOM NAVIGATION
            // ========================================================

            bottomNavigationBar: NavigationBarTheme(
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
                onDestinationSelected: (index) async {
                  if (index == 3) {
                    showDialog( context: context, builder: (context) =>
                        AlertDialog( title: const Text("Coming Soon 🚀"),
                          content: const Text( "This feature is under development and will be available soon.", ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text("OK"), ), ], ), ); return; }
                  final plantName =
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

            // ========================================================
            // BODY
            // ========================================================

            body: Center(
              child: Container(
                height:
                MediaQuery.of(context).size.height,
                color: const Color(0xFFF5F7FB),
                width: isDesktop ? 700 : double.infinity,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    // ==================================================
                    // ACTIVE FILTER
                    // ==================================================

                    if (selectedDocFilter != "All")
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(
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
                                selectedDocFilter,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF123E68),
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedDocFilter = "All";
                                });

                                _resetApprovalList();
                              },
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
                      ),

                    // ==================================================
                    // APPROVAL LIST
                    // ==================================================

                    Flexible(
                      flex: 50,
                      child: SizedBox(
                        height:
                        SizeConfig.screenHeight! * 100,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _pagingController.refresh();
                          },
                          child: PagedListView<
                              int, LISTAPPROVAL>(
                            pagingController:
                            _pagingController,
                            builderDelegate:
                            PagedChildBuilderDelegate<
                                LISTAPPROVAL>(
                              firstPageErrorIndicatorBuilder:
                              errorIndicator,

                              // ==================================================
                              // ITEM BUILDER
                              // ==================================================

                              itemBuilder:
                                  (context, item, index) {
                                return Padding(
                                  padding:
                                  const EdgeInsets.all(0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result =
                                      await Navigator.push(
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
                                              ApprovalsDetailsScreen(
                                                item,
                                                loginResponseModel,
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

                                      if (!mounted) return;

                                      if (result == true) {
                                        _resetApprovalList();
                                      }
                                    },

                                    // ==================================================
                                    // CARD
                                    // ==================================================

                                    child: Card(
                                      elevation: 0,
                                      color: Colors.white,
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                          20,
                                        ),
                                        side:
                                        const BorderSide(
                                          color:
                                          Color(0xFFD9E2EC),
                                        ),
                                      ),
                                      child: Container(
                                        padding:
                                        const EdgeInsets.all(
                                          16,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [

                                            // STATUS
                                            Container(
                                              width: 5,
                                              height: 90,
                                              decoration:
                                              BoxDecoration(
                                                color: item
                                                    .cOLORCODE !=
                                                    null &&
                                                    item
                                                        .cOLORCODE!
                                                        .isNotEmpty
                                                    ? _getColorFromHex(
                                                  item
                                                      .cOLORCODE!,
                                                )
                                                    : Colors.orange,
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                  10,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              width: 14,
                                            ),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [

                                                  // ==================================================
                                                  // TYPE + DATE
                                                  // ==================================================

                                                  Row(
                                                    children: [
                                                      Text(
                                                        item.iNVCTYPE ??
                                                            "",
                                                        style:
                                                        TextStyle(
                                                          color:
                                                          const Color(
                                                            0xFFC0504D,
                                                          ),
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                          fontSize:
                                                          Platform.isIOS
                                                              ? 14
                                                              : 11.5,
                                                        ),
                                                      ),

                                                      const Spacer(),

                                                      Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                          12,
                                                          vertical:
                                                          4,
                                                        ),
                                                        decoration:
                                                        BoxDecoration(
                                                          color:
                                                          const Color(
                                                            0xFFEAF1F8,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                            20,
                                                          ),
                                                        ),
                                                        child:
                                                        Text(
                                                          item.dUEDATE ??
                                                              "",
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            Platform.isIOS
                                                                ? 13.5
                                                                : 10.5,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  // ==================================================
                                                  // INVOICE
                                                  // ==================================================

                                                  Text(
                                                    item.iNVCNUMB ??
                                                        "",
                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      Platform.isIOS
                                                          ? 16
                                                          : 13,
                                                      fontWeight:
                                                      FontWeight
                                                          .w700,
                                                      color:
                                                      const Color(
                                                        0xFF123E68,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  // ==================================================
                                                  // SUPPLIER
                                                  // ==================================================

                                                  Text(
                                                    (item.sLDESC
                                                        ?.trim()
                                                        .isNotEmpty ??
                                                        false)
                                                        ? item.sLDESC!
                                                        : (item.dOCDESC
                                                        ?.trim() ??
                                                        ""),
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      Platform.isIOS
                                                          ? 14
                                                          : 11.5,
                                                      color:
                                                      Colors.black87,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  // ==================================================
                                                  // DOCUMENT TYPE
                                                  // ==================================================

                                                  Text(
                                                    "Type : ${item.dOCDESC ?? ""}",
                                                    maxLines: 1,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    style:
                                                    TextStyle(
                                                      color: Colors
                                                          .grey
                                                          .shade600,
                                                      fontSize:
                                                      Platform.isIOS
                                                          ? 12.5
                                                          : 10.5,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  // ==================================================
                                                  // GL
                                                  // ==================================================

                                                  Text(
                                                    "GL : ${item.gLDESC ?? ""}",
                                                    style:
                                                    TextStyle(
                                                      color: Colors
                                                          .grey
                                                          .shade600,
                                                      fontSize:
                                                      Platform.isIOS
                                                          ? 14
                                                          : 11.5,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  // ==================================================
                                                  // AMOUNT
                                                  // ==================================================

                                                  Row(
                                                    children: [
                                                      Text(
                                                        "₹ ${item.dOCAMT ?? "0"}",
                                                        style:
                                                        TextStyle(
                                                          color:
                                                          const Color(
                                                            0xFF1A4A7A,
                                                          ),
                                                          fontSize:
                                                          Platform.isIOS
                                                              ? 14
                                                              : 11.5,
                                                          fontWeight:
                                                          FontWeight
                                                              .w700,
                                                        ),
                                                      ),

                                                      const Spacer(),

                                                      const Icon(
                                                        Icons
                                                            .arrow_forward_ios,
                                                        size: 16,
                                                        color:
                                                        Colors.grey,
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(
                                                    height: 3,
                                                  ),

                                                  // ==================================================
                                                  // CREATED BY
                                                  // ==================================================

                                                  Text(
                                                    "Release By : ${item.cREATEDBYNAME ?? ""}",
                                                    style:
                                                    TextStyle(
                                                      color: Colors
                                                          .grey
                                                          .shade600,
                                                      fontSize:
                                                      Platform.isIOS
                                                          ? 14
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
                              },
                            ),
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
  // HEX COLOR
  // ============================================================

  Color _getColorFromHex(String hexColor) {
    try {
      String colorString =
      hexColor.replaceAll("#", "");

      if (colorString.length == 6) {
        colorString = "FF$colorString";
      }

      return Color(
        int.parse(
          colorString,
          radix: 16,
        ),
      );
    } catch (e) {
      return Colors.orange;
    }
  }

  // ============================================================
  // ERROR INDICATOR
  // ============================================================

  Widget errorIndicator(BuildContext context) {
    return const Center(
      child: Text(
        'No records found!',
      ),
    );
  }

  // ============================================================
  // FETCH PAGE
  // ============================================================

  Future<void> _fetchPage(
      BuildContext context,
      int pageKey,
      int currentPage,
      String searchtext,
      String searchflag,
      String strOrgStructId,
      String strPostNo,
      String strToken,
      String strUserId,
      ) async {

    // IMPORTANT:
    // Do NOT clear getLeadList here.
    //
    // This function can be called for page 2, page 3, etc.
    // Clearing here can interfere with pagination.

    final List<LISTAPPROVAL> postList = [];

    try {
      final CommonUtils commonUtils = CommonUtils();

      final bool isConnectivity =
      await commonUtils.check();

      if (!isConnectivity) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please check Internet Connection",
            ),
          ),
        );

        return;
      }

      // ========================================================
      // REQUEST MODEL
      // ========================================================

      final GetApprovalListRequestModel
      approvalsRequestModel =
      GetApprovalListRequestModel();

      approvalsRequestModel.xMLFILE =
          XMLFILEAPPROVALS();

      approvalsRequestModel.xMLFILE!.dOCID = "0";
      approvalsRequestModel.xMLFILE!.dUEDATE = "";
      approvalsRequestModel.xMLFILE!.fLAG = "1";
      approvalsRequestModel.xMLFILE!.fROMDATE = "";
      approvalsRequestModel.xMLFILE!.mENUID = "0";
      approvalsRequestModel.xMLFILE!.mID = "0";
      approvalsRequestModel.xMLFILE!.oRGSTRUCTID =
          strOrgStructId;
      approvalsRequestModel.xMLFILE!.controlno =
          controlno;
      approvalsRequestModel.xMLFILE!.pAGENO =
          pageKey;
      approvalsRequestModel.xMLFILE!.pOSID =
          strPostNo;
      approvalsRequestModel.xMLFILE!.tODATE = "";
      approvalsRequestModel.xMLFILE!.tOKEN =
          strToken;
      approvalsRequestModel.xMLFILE!.uSERID =
          strUserId;

      // ========================================================
      // SEARCH
      // ========================================================

      if (searchflag == "1") {
        if (searchtext.length < 2) {
          if (pageKey == 1) {
            _pagingController.appendLastPage([]);
          }

          return;
        }

        approvalsRequestModel.xMLFILE!.dESC =
            searchtext;
      }

      // ========================================================
      // API
      // ========================================================

      final ApprovalsController controller =
      Provider.of<ApprovalsController>(
        context,
        listen: false,
      );

      getApprovalListModel =
      await controller.GetApprovalListDetails(
        approvalsRequestModel,
        context,
      );
    } catch (e) {
      debugPrint(
        "Approval API error --> $e",
      );

      if (!mounted) return;

      _pagingController.error = e;

      return;
    }

    // ==========================================================
    // CHECK RESPONSE
    // ==========================================================

    if (!mounted) return;

    if (getApprovalListModel == null ||
        getApprovalListModel!.dATA == null ||
        getApprovalListModel!.dATA!.lIST == null) {
      _pagingController.appendLastPage([]);

      return;
    }

    final List<LISTAPPROVAL> apiList =
    getApprovalListModel!.dATA!.lIST!;

    // ==========================================================
    // APPLY DOCUMENT FILTER
    //
    // FILTER FORMAT:
    //
    // U1-SU | Suppliers
    //
    // INVCTYPE = U1-SU
    // DOCDESC  = Suppliers
    // ==========================================================

    if (selectedDocFilter == "All") {
      postList.addAll(apiList);
    } else {
      final String selected =
      selectedDocFilter.trim().toLowerCase();

      postList.addAll(
        apiList.where(
              (item) {
            final String invcType =
                item.iNVCTYPE?.trim().toLowerCase() ?? "";

            final String docDesc =
                item.dOCDESC?.trim().toLowerCase() ?? "";

            final String combinedFilter =
                "$invcType | $docDesc";

            return combinedFilter == selected;
          },
        ),
      );
    }

    // ==========================================================
    // PAGINATION
    // ==========================================================

    final bool isLastPage =
        apiList.length < _numberOfPostsPerRequest;

    if (isLastPage) {
      _pagingController.appendLastPage(
        postList,
      );
    } else {
      final int nextPageKey =
          pageKey + 1;

      _pagingController.appendPage(
        postList,
        nextPageKey,
      );
    }
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // PAGING CONTROLLER
    // ==========================================================

    _pagingController =
        PagingController<int, LISTAPPROVAL>(
          firstPageKey: 1,
        );

    callValue = 0;

    _pagingController.addPageRequestListener(
          (pageKey) {
        if (!mounted) return;

        _fetchPage(
          context,
          pageKey,
          i,
          searchController.text.trim(),
          searchflag,
          loginResponseModel!.data!.orgstrucid!,
          loginResponseModel!.data!.posid,
          loginResponseModel!.data!.token,
          loginResponseModel!.data!.userid,
        );
      },
    );

    // ==========================================================
    // SEARCH LISTENER
    // ==========================================================

    _searchListener = () {
      if (!mounted) return;

      if (searchController.text.isEmpty) {
        setState(() {
          callValue = 0;
          getLeadList?.clear();
          searchflag = "0";
        });

        if (mounted) {
          _pagingController.refresh();
        }
      }
    };

    searchController.addListener(
      _searchListener,
    );

    // ==========================================================
    // PORTRAIT ONLY
    // ==========================================================

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }
}

// ============================================================================
// APPROVAL FILTER DIALOG
// ============================================================================

class ApprovalFilterDialog extends StatefulWidget {
  final List<String> options;
  final String selectedValue;

  const ApprovalFilterDialog({
    super.key,
    required this.options,
    required this.selectedValue,
  });

  @override
  State<ApprovalFilterDialog> createState() =>
      _ApprovalFilterDialogState();
}

class _ApprovalFilterDialogState
    extends State<ApprovalFilterDialog> {

  late TextEditingController searchController;
  late String selectedValue;

  @override
  void initState() {
    super.initState();

    searchController =
        TextEditingController();

    selectedValue =
        widget.selectedValue;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String searchText =
    searchController.text
        .trim()
        .toLowerCase();

    final List<String> filteredOptions =
    widget.options.where((item) {
      if (searchText.isEmpty) {
        return true;
      }

      return item
          .toLowerCase()
          .contains(searchText);
    }).toList();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width:
            MediaQuery.of(context).size.width >= 700
                ? 650
                : MediaQuery.of(context).size.width -
                24,

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
            ),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      12,
                      10,
                      10,
                    ),
                    child: Row(
                      children: [

                        const Icon(
                          Icons.filter_alt_outlined,
                          color:
                          Color(0xFF123E68),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Text(
                            "Filter Approvals",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              Color(0xFF123E68),
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                  ),

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

                  Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: TextField(
                      controller:
                      searchController,
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration:
                      InputDecoration(
                        hintText:
                        "Search document type...",
                        prefixIcon:
                        const Icon(
                          Icons.search,
                        ),
                        suffixIcon:
                        searchController
                            .text
                            .isNotEmpty
                            ? IconButton(
                          icon:
                          const Icon(
                            Icons.clear,
                          ),
                          onPressed:
                              () {
                            searchController
                                .clear();

                            setState(
                                  () {},
                            );
                          },
                        )
                            : null,
                        filled: true,
                        fillColor:
                        const Color(
                          0xffF5F7FB,
                        ),
                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
                              0xFFD9E2EC,
                            ),
                          ),
                        ),
                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
                              0xFFD9E2EC,
                            ),
                          ),
                        ),
                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
                              0xFF123E68,
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // DOCUMENT LIST
                  // ==================================================

                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount:
                    filteredOptions.length,
                    itemBuilder: (
                        context,
                        index,
                        ) {
                      final String option =
                      filteredOptions[index];

                      final bool isSelected =
                          selectedValue ==
                              option;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedValue =
                                option;
                          });
                        },
                        child: Container(
                          margin:
                          const EdgeInsets
                              .symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ),
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration:
                          BoxDecoration(
                            color: isSelected
                                ? const Color(
                              0xffEAF1F8,
                            )
                                : Colors.transparent,
                            borderRadius:
                            BorderRadius
                                .circular(
                              10,
                            ),
                          ),
                          child: Row(
                            children: [

                              Icon(
                                option == "All"
                                    ? Icons.select_all
                                    : Icons
                                    .description_outlined,
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
                                  option,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  TextStyle(
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
                                        : Colors
                                        .black87,
                                  ),
                                ),
                              ),

                              if (isSelected)
                                const Icon(
                                  Icons
                                      .check_circle,
                                  color:
                                  Color(
                                    0xFF123E68,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                  ),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Padding(
                    padding:
                    const EdgeInsets.all(
                      12,
                    ),
                    child: Row(
                      children: [

                        // ==================================================
                        // CLEAR
                        // ==================================================

                        Expanded(
                          child:
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                "All",
                              );
                            },
                            style:
                            OutlinedButton
                                .styleFrom(
                              backgroundColor:
                              Colors.white,
                              foregroundColor:
                              const Color(
                                0xFF123E68,
                              ),
                              elevation: 0,
                              minimumSize:
                              const Size(
                                0,
                                44,
                              ),
                              side:
                              const BorderSide(
                                color:
                                Color(
                                  0xFFD9E2EC,
                                ),
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  10,
                                ),
                              ),
                            ),
                            child:
                            const Text(
                              "Clear",
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        // ==================================================
                        // APPLY
                        // ==================================================

                        Expanded(
                          child:
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                selectedValue,
                              );
                            },
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              const Color(
                                0xFF123E68,
                              ),
                              foregroundColor:
                              Colors.white,
                              elevation: 0,
                              minimumSize:
                              const Size(
                                0,
                                44,
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  10,
                                ),
                              ),
                            ),
                            child:
                            const Text(
                              "Apply Filter",
                            ),
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
      ),
    );
  }
}
