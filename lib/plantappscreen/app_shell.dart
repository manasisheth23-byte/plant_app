import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import 'package:erpflutter/Dashboard.dart';
import 'package:erpflutter/models/LoginResponseModel.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/ProfileScreen.dart';
import 'package:erpflutter/screens/chatbot/ChatBotScreen.dart';
import 'package:erpflutter/screens/report/report.dart';
import 'package:erpflutter/screens/alerts/alerts_list.dart';
import 'package:erpflutter/screens/activity/activity_controller.dart';
import 'package:erpflutter/screens/login/login_controller.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/plantlist/plantlist.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';

import '../Constants.dart';
import '../app_config.dart';
import '../models/getnotificationmodel.dart';

class AppShell extends StatefulWidget {
  final String role;
  final String plant;
  final int selectedIndex;

  const AppShell({
    super.key,
    required this.role,
    required this.plant,
    this.selectedIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // ============================================================
  // STATE
  // ============================================================

  late int _idx;

  LoginResponseModel? loginResponseModel;

  String? strUserID;

  int coloumncount = 0;

  String date = '';

  bool _initialized = false;

  // ============================================================
  // PAGES
  //
  // IMPORTANT:
  //
  // These are created ONLY ONCE.
  // Do NOT create these inside build().
  // ============================================================

  late Dashboard _dashboardScreen;
  late AlertsList _alertsScreen;
  late Report _reportScreen;
  late ChatBotScreen _chatBotScreen;
  late ProfileScreen _profileScreen;

  late List<Widget> _pages;

  // ============================================================
  // TITLES
  // ============================================================

  static const List<List<String>> _titles = [
    ['Home', ''],
    ['Alerts', ''],
    ['Reports & MIS', ''],
    ['Cloud9 Assistant', ''],
    ['Profile', 'Information'],
  ];

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _idx = widget.selectedIndex;

    if (_idx < 0 || _idx >= 5) {
      _idx = 0;
    }

    if (Platform.isWindows) {
      coloumncount = 8;
    } else {
      coloumncount = 4;
    }

    date = DateFormat(
      'EEEE, dd MMM',
    ).format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> _initialize() async {
    try {
      // ----------------------------------------------------------
      // GET LOGIN RESPONSE
      // ----------------------------------------------------------

      await getUserResponse();

      if (!mounted) return;

      // ----------------------------------------------------------
      // CREATE PAGES ONLY ONCE
      // ----------------------------------------------------------

      _dashboardScreen = Dashboard();

      _alertsScreen = AlertsList();

      _reportScreen = Report();

      _chatBotScreen = ChatBotScreen();

      _profileScreen = ProfileScreen();

      _pages = [
        _dashboardScreen,
        _alertsScreen,
        _reportScreen,
        _chatBotScreen,
        _profileScreen,
      ];

      // ----------------------------------------------------------
      // APP IS READY
      // ----------------------------------------------------------

      if (!mounted) return;

      setState(() {
        _initialized = true;
      });

      // ----------------------------------------------------------
      // NOTIFICATION COUNT
      // ----------------------------------------------------------

      await getNotificationCount();

      if (!mounted) return;

      // ----------------------------------------------------------
      // CHECK OPEN NOTIFICATION FLAG
      // ----------------------------------------------------------

      await check();

      if (!mounted) return;

      // ----------------------------------------------------------
      // WINDOWS WEBSOCKET
      // ----------------------------------------------------------

      if (Platform.isWindows) {
        await connectWebSocket();
      }
    } catch (e) {
      debugPrint(
        'AppShell initialization error: $e',
      );
    }
  }

  // ============================================================
  // GET USER RESPONSE
  // ============================================================

  Future<void> getUserResponse() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final loginResponseString =
      prefs.getString('LOGINRESPONSE');

      if (loginResponseString == null ||
          loginResponseString.isEmpty) {
        debugPrint(
          'LOGINRESPONSE not found',
        );
        return;
      }

      final decoded =
      jsonDecode(loginResponseString);

      loginResponseModel =
          LoginResponseModel.fromJson(decoded);

      debugPrint(
        'Login response loaded successfully',
      );
    } catch (e) {
      debugPrint(
        'Error loading login response: $e',
      );
    }
  }

  // ============================================================
  // TAB CHANGE
  // ============================================================

  void _go(int index) {
    if (!mounted) return;

    if (!_initialized) {
      return;
    }

    if (index < 0 ||
        index >= _pages.length) {
      return;
    }
    // ChatBot / Assistant is coming soon
    if (index == 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Coming Soon 🚀"),
          content: const Text(
            "This feature is under development and will be available soon.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      return; // Don't change the selected tab
    }
    if (_idx == index) {
      return;
    }

    setState(() {
      _idx = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= 700;

    // ----------------------------------------------------------
    // INITIAL LOADING
    // ----------------------------------------------------------

    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentTitle =
    _titles[_idx];

    // ----------------------------------------------------------
    // HIDE APPBAR + BOTTOM NAVIGATION
    //
    // Alerts = index 1
    // Reports = index 2
    // ----------------------------------------------------------

    final bool hideAppBar =
        _idx == 1 || _idx == 2;

    final bool hideBottomNavigation =
        _idx == 1 || _idx == 2;

    return Consumer2<
        LoginController,
        UnreadNotificationProvider>(
      builder: (
          context,
          loginController,
          unreadProvider,
          child,
          ) {
        return Center(
          child: SizedBox(
            width:
            isDesktop ? 700 : double.infinity,
            child: Scaffold(

              // ==================================================
              // APP BAR
              // ==================================================

              appBar: hideAppBar
                  ? null
                  : PreferredSize(
                preferredSize:
                const Size.fromHeight(60),
                child: SizedBox(
                  width: isDesktop
                      ? 700
                      : double.infinity,
                  child: _buildAppBar(
                    context,
                    currentTitle,
                    unreadProvider
                        .unreadCount,
                  ),
                ),
              ),

              // ==================================================
              // BODY
              //
              // IMPORTANT:
              //
              // IndexedStack keeps the pages alive.
              //
              // No AnimatedSwitcher.
              // No KeyedSubtree.
              // ==================================================

              body: IndexedStack(
                index: _idx,
                children: _pages,
              ),

              // ==================================================
              // BOTTOM NAVIGATION
              // ==================================================

              bottomNavigationBar:
              hideBottomNavigation
                  ? null
                  : _buildBottomNavigation(
                unreadProvider
                    .unreadCount,
                isDesktop,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      List<String> currentTitle,
      int unreadCount,
      ) {
    return AppBar(
      backgroundColor: C.deep,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,

      // --------------------------------------------------------
      // BACK BUTTON
      // --------------------------------------------------------

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
        ),
        onPressed:
        _handleBackPressed,
      ),

      // --------------------------------------------------------
      // TITLE
      // --------------------------------------------------------

      title: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentTitle[0],
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
              FontWeight.normal,
            ),
          ),

          Text(
            _idx == 0
                ? '$date · ${widget.plant}'
                : currentTitle[1],
            style: body(
              11,
              c: const Color(
                0xFF9DB8D4,
              ),
            ),
          ),
        ],
      ),

      // --------------------------------------------------------
      // NOTIFICATION
      // --------------------------------------------------------

      actions: [
        Padding(
          padding:
          const EdgeInsets.only(
            right: 10,
          ),
          child: Stack(
            clipBehavior:
            Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons
                      .notifications_outlined,
                ),
                onPressed:
                _openNotifications,
              ),

              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding:
                  const EdgeInsets.all(3),
                  decoration:
                  const BoxDecoration(
                    color: C.red,
                    shape:
                    BoxShape.circle,
                  ),
                  constraints:
                  const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    textAlign:
                    TextAlign.center,
                    style: body(
                      9,
                      w: FontWeight.w700,
                      c: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation(
      int unreadCount,
      bool isDesktop,
      ) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle:
        MaterialStateProperty
            .resolveWith<TextStyle>(
              (states) {
            if (states.contains(
              MaterialState.selected,
            )) {
              return const TextStyle(
                fontSize: 10,
                fontWeight:
                FontWeight.w600,
              );
            }

            return const TextStyle(
              fontSize: 9,
            );
          },
        ),
      ),
      child: SizedBox(
        width: isDesktop
            ? 700
            : double.infinity,
        child: NavigationBar(
          selectedIndex: _idx,

          // IMPORTANT:
          //
          // Only changes selected tab.
          // Does NOT push another AppShell.
          //

          onDestinationSelected: _go,

          height: 60,

          backgroundColor:
          Colors.white,

          indicatorColor:
          C.bluep,

          destinations: [
            // ==================================================
            // HOME
            // ==================================================

            const NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                size: 30,
              ),
              selectedIcon:
              Icon(
                Icons.home,
                color: C.blue,
                size: 30,
              ),
              label: 'Home',
            ),

            // ==================================================
            // ALERTS
            // ==================================================

            NavigationDestination(
              icon: Badge(
                label: Text(
                  unreadCount.toString(),
                ),
                child:
                const Icon(
                  Icons
                      .notifications_outlined,
                  size: 30,
                ),
              ),
              selectedIcon:
              const Icon(
                Icons.notifications,
                size: 30,
                color: C.blue,
              ),
              label: 'Alerts',
            ),

            // ==================================================
            // REPORTS
            // ==================================================

            const NavigationDestination(
              icon: Icon(
                Icons
                    .bar_chart_outlined,
                size: 30,
              ),
              selectedIcon:
              Icon(
                Icons.bar_chart,
                size: 30,
                color: C.blue,
              ),
              label: 'Reports',
            ),

            // ==================================================
            // ASSISTANT
            // ==================================================

            const NavigationDestination(
              icon: Icon(
                Icons
                    .chat_bubble_outline,
                size: 30,
              ),
              selectedIcon:
              Icon(
                Icons.chat_bubble,
                size: 30,
                color: C.blue,
              ),
              label: 'Assistant',
            ),

            // ==================================================
            // PROFILE
            // ==================================================

            const NavigationDestination(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              selectedIcon:
              Icon(
                Icons.person,
                size: 30,
                color: C.blue,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Future<void> _handleBackPressed() async {
    if (!mounted) return;

    // ----------------------------------------------------------
    // HOME
    // ----------------------------------------------------------

    if (_idx == 0) {
      try {
        final plantProvider =
        context.read<PlantProvider>();

        final plantName =
            plantProvider.plantName;

        final prefs =
        await SharedPreferences
            .getInstance();

        final orgId =
        prefs.getString(
          'PLANTORGSTRUCTID',
        );

        if (!mounted) return;

        if (orgId == null ||
            orgId.isEmpty) {
          debugPrint(
            'PLANTORGSTRUCTID is empty',
          );
          return;
        }

        Navigator.of(context).push(
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
                context,
                animation,
                secondaryAnimation,
                ) {
              return PlantListScreen(
                orgStrucId: orgId,
                companyName: plantName,
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
      } catch (e) {
        debugPrint(
          'Error opening plant list: $e',
        );
      }

      return;
    }

    // ----------------------------------------------------------
    // ALERTS / REPORTS / OTHER TABS
    //
    // Simply return to Home.
    // ----------------------------------------------------------

    if (!mounted) return;

    setState(() {
      _idx = 0;
    });
  }

  // ============================================================
  // OPEN NOTIFICATIONS
  // ============================================================

  Future<void> _openNotifications() async {
    if (!mounted) return;

    try {
      // --------------------------------------------------------
      // Make sure login response is available
      // --------------------------------------------------------

      if (loginResponseModel == null) {
        await getUserResponse();
      }

      if (!mounted) return;

      // --------------------------------------------------------
      // Fetch activity data
      // --------------------------------------------------------

      context
          .read<ActivityController>()
          .fetchData();

      if (!mounted) return;

      // --------------------------------------------------------
      // IMPORTANT:
      //
      // Do NOT Navigator.push AlertsList.
      //
      // Use the existing AlertsList from IndexedStack.
      // --------------------------------------------------------

      _go(1);
    } catch (e) {
      debugPrint(
        'Error opening notifications: $e',
      );
    }
  }

  // ============================================================
  // NOTIFICATION COUNT
  // ============================================================

  Future<void> getNotificationCount() async {
    try {
      final notificationProvider =
      Provider.of(
        context,
        listen: false,
      );

      await notificationProvider
          .GetNotification("0");

      if (!mounted) return;

      final List<NitificationLIST>
      notifications =
          notificationProvider
              .getNotificationModel
              ?.dATA
              ?.lIST ??
              [];

      // --------------------------------------------------------
      // SORT UNREAD FIRST
      // --------------------------------------------------------

      notifications.sort(
            (a, b) {
          final aValue =
          a.ISREAD == "0"
              ? 0
              : 1;

          final bValue =
          b.ISREAD == "0"
              ? 0
              : 1;

          return aValue.compareTo(
            bValue,
          );
        },
      );

      // --------------------------------------------------------
      // COUNT
      // --------------------------------------------------------

      final unreadCount =
          notifications.where(
                (item) =>
            item.ISREAD == "0",
          ).length;

      Constant.unreadCount =
          unreadCount;

      final unreadProvider =
      Provider.of<
          UnreadNotificationProvider>(
        context,
        listen: false,
      );

      unreadProvider.setUnreadCount(
        unreadCount,
      );

      debugPrint(
        'Unread count: $unreadCount',
      );
    } catch (e) {
      debugPrint(
        'Error fetching notification count: $e',
      );
    }
  }

  // ============================================================
  // WEBSOCKET
  // ============================================================

  Future<void> connectWebSocket() async {
    try {
      final prefs =
      await SharedPreferences
          .getInstance();

      strUserID =
          prefs.getString('USERID');

      // --------------------------------------------------------
      // ALREADY CONNECTED
      // --------------------------------------------------------

      if (Constant.rawSocket != null &&
          Constant.rawSocket!.readyState ==
              WebSocket.open) {
        debugPrint(
          'WebSocket is already connected.',
        );
        return;
      }

      // --------------------------------------------------------
      // CLOSE OLD CONNECTION
      // --------------------------------------------------------

      if (Constant.rawSocket != null &&
          Constant.rawSocket!.readyState !=
              WebSocket.closed) {
        debugPrint(
          'Closing stale WebSocket connection...',
        );

        await Constant.rawSocket!.close();
      }

      // --------------------------------------------------------
      // URL
      // --------------------------------------------------------

      final wsUrl =
      AppConfig.RAW_BASE_URL
          .replaceFirst(
        'http',
        'ws',
      );

      final socket =
      await WebSocket.connect(
        '$wsUrl/ERPAPI/WebSocketHandlerUserWise_API.ashx?USERID=$strUserID',
      );

      if (!mounted) {
        await socket.close();
        return;
      }

      Constant.rawSocket =
          socket;

      debugPrint(
        'WebSocket connected.',
      );

      // --------------------------------------------------------
      // CHANNEL
      // --------------------------------------------------------

      Constant.channel =
          IOWebSocketChannel(
            Constant.rawSocket!,
          );

      Constant.channel!.stream.listen(
            (data) async {
          debugPrint(
            'WebSocket received: $data',
          );

          // Get actual unread count.
          //
          // Don't manually increment it.
          if (mounted) {
            await getNotificationCount();
          }
        },
        onDone: () {
          debugPrint(
            'WebSocket closed',
          );
        },
        onError: (error) {
          debugPrint(
            'WebSocket error: $error',
          );
        },
      );
    } catch (e) {
      debugPrint(
        'WebSocket connection error: $e',
      );
    }
  }

  // ============================================================
  // CHECK OPEN NOTIFICATION SCREEN
  // ============================================================

  Future<void> check() async {
    try {
      final prefs =
      await SharedPreferences
          .getInstance();

      final value =
          prefs.getBool(
            'open_notification_screen',
          ) ??
              false;

      if (!value) {
        return;
      }

      await prefs.setBool(
        'open_notification_screen',
        false,
      );

      if (!mounted) return;

      // Use existing AlertsList.
      _go(1);
    } catch (e) {
      debugPrint(
        'Error checking notification screen: $e',
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    // Do not close Constant.rawSocket here.
    //
    // It is being used as an application-level socket.
    //
    // If AppShell becomes the owner of the socket later,
    // then close it here.

    super.dispose();
  }
}