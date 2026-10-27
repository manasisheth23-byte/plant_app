
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/konowledgebase/webview.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_colors.dart';
import '../../models/know_your_products_model.dart';
import '../../provider/themecontroller.dart';
import '../../services/ApiProvider.dart';
import 'knowledgebase_provider.dart';




class KnowYourProductScreen extends StatefulWidget {
  final String text;
  KnowYourProductScreen({required this.text, super.key});

  @override
  State<KnowYourProductScreen> createState() => _KnowYourProductScreenState();
}

class _KnowYourProductScreenState extends State<KnowYourProductScreen> {
  bool showContainer = false;
  bool showFirstContainer = false;
  bool showSecondContainer = false;
  bool showThirdContainer = false;
  final String htmlContent = """
    <html>
      <head>
        <style type="text/css">
          /* Your CSS styles here */
        </style>
      </head>
      <body>
        <!-- Your HTML content here -->
        <div>
          <!-- Your HTML form data here -->
        </div>
      </body>
    </html>
  """;

  webViewApi(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    await Provider.of<Konowledgeprovider>(context, listen: false)
        .webViewAPi(id, token.toString());
  }
  late ThemeController themeController;

  bool isLoading = true;
  KnowYourProductsModel? dataModel;

  void fetchData() async{
    dataModel = await ApiProvider().getKnowYourProducts();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_){
      fetchData();
    });
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final setHeight = MediaQuery.of(context).size.height * 1;
    final setWidth = MediaQuery.of(context).size.width * 1;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: SizedBox(
                      width: isDesktop ? 700 : double.infinity,
                      child:AppBar(
            backgroundColor: themeController.primaryColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            title:  Text(
              "Know Your Product",
              style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              )
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
      /*          Navigator.pushReplacement(
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
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (dataModel == null ||
              dataModel!.cATEGORY == null ||
              dataModel!.cATEGORY!.sOLCAR == null)
              ? const Center(child: Text("No data available"))
              :Center(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  color:const Color(0xFFF5F7FB),
                  width: isDesktop ? 700 : double.infinity,
                  padding: const EdgeInsets.all(10),
                  child:SingleChildScrollView(
              child: Column(
            children: dataModel!.cATEGORY!.sOLCAR!
                .map((solCar) => SolCar(solCar))
                .toList(),
          )))),
        ),
      ),
    );
  }
}

class SolFolder extends StatefulWidget {
  SOLFOLDER solFolderItem;
  SolFolder(this.solFolderItem, {super.key});

  @override
  State<SolFolder> createState() => _SolFolderState();
}

class _SolFolderState extends State<SolFolder> {
  bool showContainer = false;
  late ThemeController themeController;



  @override
  Widget build(BuildContext context) {
    themeController = Provider.of(context, listen: false);

    var setWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              showContainer = !showContainer;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: const Border(
                bottom: BorderSide(
                  color: Colors.black87,
                  width: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 15),
                      child: showContainer
                          ? Image.asset(
                        "assets/downward-arrow.png",
                        width: 25,
                        height: 40,
                      )
                          : Image.asset(
                        "assets/right-arrow-icon-8.png",
                        width: 25,
                        height: 40,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "${widget.solFolderItem.nAME}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:  EdgeInsets.only(right: 10),
                  child: Container(
                    padding:  EdgeInsets.symmetric(
                        horizontal: 8),
                    decoration: BoxDecoration(
                        color: themeController.primaryColor,
                        borderRadius:
                        BorderRadius.circular(3)),
                    child: Center(
                      child: Text(
                        "${widget.solFolderItem.sCNT}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        showContainer
            ? Column(
          children: widget.solFolderItem!.sOLUTIONS!.map((solution){
            return Solutions(solution);
          }).toList(),
        ) : Container(),
      ],
    );
  }
}

class Solutions extends StatefulWidget {
  SOLUTIONS solution;
  Solutions(this.solution, {super.key});

  @override
  State<Solutions> createState() => _SolutionsState();
}

class _SolutionsState extends State<Solutions> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (_, animation, secondaryAnimation) =>
                WebViewChart(solId: widget.solution!.sOLID!, title: widget.solution!.tITLE!,sofolder: widget.solution.sOLFOLID!,),
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
       /* Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => WebViewChart(solId: widget.solution!.sOLID!, title: widget.solution!.tITLE!,sofolder: widget.solution.sOLFOLID!,)
          ),
        );*/
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
            vertical: 15, horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.black87,
              width: 0.3,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            Expanded(
              child: Text(
                "${widget.solution.tITLE}",
                maxLines: 2, // optional, limit lines if long
                overflow: TextOverflow.ellipsis, // shows ... if text is too long
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SolCar extends StatefulWidget {
  SOLCAR solCar;
  SolCar(this.solCar, {super.key});

  @override
  State<SolCar> createState() => _SolCarState();
}

class _SolCarState extends State<SolCar> {
  bool showContainer = false;
  late ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    themeController = Provider.of(context, listen: false);

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(
                  () {
                showContainer = !showContainer;
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: const BoxDecoration(

              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.black87,
                  width: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/assign_category.png",
                      width: 40,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "${widget.solCar.cATNAME}",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:  EdgeInsets.only(right: 10),
                  child: Container(
                    padding:  EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: themeController.primaryColor,
                        borderRadius: BorderRadius.circular(3)),
                    child:Center(
                      child: Text(
                        "${widget.solCar.sFNT}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        showContainer ? Column(
          children: widget.solCar.sOLFOLDER!.map((item) {
            return SolFolder(item);
          }).toList(),
        ) : Container()
      ],
    );
  }
}

