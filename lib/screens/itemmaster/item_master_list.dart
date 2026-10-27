import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/itemmaster/item_master_details.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_service.dart';
import '../../models/inventory_list_model.dart';
import '../../models/inventory_list_model.dart';
import '../../models/inventory_list_model.dart';
import '../../provider/themecontroller.dart';
import '../../utils/SizeConfig.dart';
import '../login/login_controller.dart';

class InventoryListFragment extends StatefulWidget {
  InventoryListFragment({Key? key}) : super(key: key);

  String apibaseurl = "";

  @override
  _InventoryListFragment createState() => new _InventoryListFragment();
}

class _InventoryListFragment extends State<InventoryListFragment> {
  TextEditingController cmobnoController = TextEditingController();


  static int _numberOfPostsPerRequest = 10;
  static String searchValue = '';

  static PagingController<int, InventoryListModel> _pagingController =
  PagingController(firstPageKey: 0);
  static bool checkedValue = false;
  static String searchflag = "0";
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  double? screenWidth;
  double? screenHeight;
  int i = 1;
  static int callValue = 0;
  double? blockSizeHorizontal;
  static List<InventoryListModel>? getLeadList = [];
  static DatabaseService _databaseService = DatabaseService();
  SharedPreferences? prefs;
  bool _working = false;
  late ThemeController themeController;


  @override
  void dispose() {
    super.dispose();
    _InventoryListFragment.searchValue = "";
    _InventoryListFragment.callValue = 0;
    _InventoryListFragment.getLeadList!.clear();
    _InventoryListFragment.searchflag = "0";
    _pagingController.refresh();
  }



  void showLoadingDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(
            color: Colors.blue,
            backgroundColor: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(left: 7),
            child: Text("Loading..."),
          ),
        ],
      ),
    );

    showDialog(
      barrierDismissible: false, // Prevent dialog from being dismissed
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = (screenWidth! / 100);
    var blockSizeVertical = (screenHeight! / 100);
    //call multiple database function
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);

    return Scaffold(

        appBar:PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Center(
                child: SizedBox(
                    width: isDesktop ? 700 : double.infinity,
                    child: AppBar(
          backgroundColor: themeController.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(
                "Inventory",
                style:  GoogleFonts.lato(

                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                )
              ),
              Text(
                "Item master & stock details",
                style:  GoogleFonts.lato(

                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                )
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  SearchPage(),
                  ),
                );
              },
            )

          ],
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
      body: Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              color:const Color(0xFFF5F7FB),
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.all(10),
              child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Flexible(
                  flex: 50,
                  child: SizedBox(
                      height: SizeConfig.screenHeight! * 100,
                      child: RefreshIndicator(
                        onRefresh: () =>
                            Future.sync(() => _pagingController.refresh()),
                        child: PagedListView<int, InventoryListModel>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<InventoryListModel>(
                              itemBuilder: (context, item, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Provider.of<LoginController>(context, listen: false).getItemMaster(
                                        item.iTEMDESC.toString(),item.iTEMCODE.toString(),item.pLANT.toString(),item.uNITPRICE.toString(),item.mAINGROUP.toString(),item.sUBGROUP.toString(),
                                        item.iTEMCODE.toString(),item.iNSTOCKQTY.toString());

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => InventoryListDetailsFragment(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      children: [

                                        /// Left Status Bar
                                        Container(
                                          width: 5,
                                          height: 95,
                                          decoration: BoxDecoration(
                                            color: Color(0xff1E4A7B),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              bottomLeft: Radius.circular(14),
                                            ),
                                          ),
                                        ),

                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.iTEMDESC ?? "",
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16,
                                                          color: Color(0xff1B2A4A),
                                                        ),
                                                      ),
                                                    ),

                                                    /*Text(
                                                      item.pLANT ?? "",
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 12,
                                                      ),
                                                    )*/
                                                  ],
                                                ),

                                                const SizedBox(height: 8),

                                                Text(
                                                  "Code : ${item.iTEMCODE}",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 13,
                                                  ),
                                                ),

                                                const SizedBox(height: 5),

                                                Text(
                                                  "${item.mAINGROUP} • ${item.sUBGROUP}",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),

                                                const SizedBox(height: 5),
                                                Text(
                                                  item.pLANT.toString(),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
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
                          ),
                        ),
                      ))),
            ],
          ))),
    );
  }

  static Future<void> _fetchPage(int pageKey,
      int currentPage, String searchtext, String searchflag) async {
    getLeadList!.clear();
    List<InventoryListModel>? postList = [];
    try {

      if (searchflag == "1") {
        if (searchtext.length >= 2) {
          getLeadList =
          await _databaseService.getInventorySearchList(
              searchtext);
        }
      } else {
        final stopwatch = Stopwatch()..start();
        getLeadList = await _databaseService.getinventoryPaginatelist(pageKey);
        stopwatch.stop();
        print('Function Execution Time : ${stopwatch.elapsed}');
      }

      /*final response = await get(Uri.parse(
          "https://jsonplaceholder.typicode.com/posts?_page=$pageKey&_limit=$_numberOfPostsPerRequest"));
      List responseList = json.decode(response.body);*/
      postList.clear();
      for (int i = 0; i < getLeadList!.length; i++) {
        InventoryListModel lookUpDropDownList = new InventoryListModel();

        lookUpDropDownList.iTEMID =
            int.tryParse(getLeadList![i].iTEMID.toString());
        lookUpDropDownList.cURRENCY = getLeadList![i].cURRENCY.toString();
        lookUpDropDownList.iTEMCODE = getLeadList![i].iTEMCODE.toString();
        lookUpDropDownList.iTEMDESC = getLeadList![i].iTEMDESC.toString();
        lookUpDropDownList.uOMCODE = getLeadList![i].uOMCODE.toString();
        lookUpDropDownList.uOMDESC = getLeadList![i].uOMDESC.toString();
        lookUpDropDownList.sUBGROUP = getLeadList![i].sUBGROUP.toString();
        lookUpDropDownList.mAINGROUP = getLeadList![i].mAINGROUP.toString();
        lookUpDropDownList.pLANT = getLeadList![i].pLANT.toString();
        lookUpDropDownList.iTEMTYPE =getLeadList![i].iTEMTYPE.toString();
        lookUpDropDownList.iNSTOCKQTY =getLeadList![i].iNSTOCKQTY.toString();
        lookUpDropDownList.uNITPRICE = getLeadList![i].uNITPRICE.toString();
        postList.add(lookUpDropDownList);
      }

      final isLastPage = postList!.length < _numberOfPostsPerRequest;
      if (isLastPage) {
        _pagingController.appendLastPage(postList);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(postList, nextPageKey);
      }
    } catch (e) {
      print("error --> $e");
      _pagingController.error = e;
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0);
    callValue = 0;
    // _getLead('1',checkedValue,i);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, i, searchValue, searchflag);
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    // _getLead('1',false);
  }
}

class SearchPage extends StatelessWidget {
  late ThemeController themeController;

   SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of(context, listen: false);

    return Scaffold(

      appBar:PreferredSize(
          preferredSize:  Size.fromHeight(60),
          child: Center(
              child: SizedBox(
                  width: isDesktop ? 700 : double.infinity,
                  child: AppBar(
                      backgroundColor: themeController.primaryColor,
                      foregroundColor: Colors.white,
        // The search area here
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {

                  if (value != null && value == "" && value.length < 2) {
                  } else {
                   // _fetchPage(0, '1', checkedValue, i,searchValue,searchflag);
                    // _getLead('1',checkedValue,i);

                    // _LeadListFragment._fetchPage(0, '1', false, 1, _LeadListFragment.searchValue, _LeadListFragment.searchflag);
                    _InventoryListFragment.searchValue = value;
                    _InventoryListFragment.callValue = 0;
                    _InventoryListFragment.getLeadList!.clear();
                    _InventoryListFragment.searchflag = "1";
                    Navigator.pop(context);
                    _InventoryListFragment._pagingController.refresh();
                    // _LeadListFragment._pagingController.notifyListeners();
                  }
                },
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        /* Clear the search field */
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
              ),
            ),
          ))))),
    );
  }
}
