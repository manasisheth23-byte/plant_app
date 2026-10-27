import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/soreport/sochart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../../provider/themecontroller.dart';
import '../so_reports/so_reports_screen.dart';

class SoChartScreen extends StatefulWidget {
  const SoChartScreen({super.key});

  @override
  State<SoChartScreen> createState() => _SoChartScreen();
}


class _SoChartScreen extends State<SoChartScreen> {
  Map<String, double> dataMap = {};
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]).then((_) {

    });

  }
  @override
  void dispose() {
    // Reset the orientation back to normal (landscape and portrait allowed)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

    ]);
    super.dispose();
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {};
    Map<String, Color> colorMap = {};
    List<List<String>> tableData = []; // Initialize tableData
    List<List<String>> tableData2 = []; // Initialize tableData2
    context.read<SoChatService>().fetchDashboardData(context,"1","1","2");
    themeController = Provider.of<ThemeController>(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);

    return Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: themeController.primaryColor,
            foregroundColor: Colors.white,
            title: GestureDetector(
              onTap: () {
                // Handle tap here
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                    SoReports(),
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
               /* Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SoReports()),
                );*/
              },
              child: Text('SO Chart',style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              )),
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
        /*        Navigator.pushReplacement(
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
          body: Consumer<SoChatService>(
            builder: (context, service, child) {
              if (service.dashboardData == null) {
                return Center(child: CircularProgressIndicator());

              }else if (service.dashboardData!.sTATUS == "false") {
                return Center(child: Text('No report available'));
              }else {
                return SingleChildScrollView(
                    child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: service.dashboardData!.dashboard!.length,
                            // Iterate through all Dashboard items
                            itemBuilder: (context, index) {
                              var item = service.dashboardData!.dashboard![index];
                              var erroritem = service.dashboardData!
                                  .errorList![index];
                              var pieChartData = item.pieChart;

                              dataMap.clear(); // Clear dataMap for each pie chart
                              colorMap.clear(); // Clear colorMap for each pie chart
                              tableData
                                  .clear(); // Clear tableData for each pie chart
                              tableData2
                                  .clear(); // Clear tableData2 for each pie chart

                              for (var pie in pieChartData!) {
                                double perc = pie.pERC != null ? pie.pERC!
                                    .toDouble() : 0.0;
                                dataMap[pie.cOLORDESC!] = perc;

                                switch (pie.cOLORDESC!.capitalizeFirst) {
                                  case "Green":
                                    colorMap[pie.cOLORDESC!] = Colors.green;
                                    break;
                                  case "Red":
                                    colorMap[pie.cOLORDESC!] = Colors.red;
                                    break;
                                  case "Yellow":
                                    colorMap[pie.cOLORDESC!] = Colors.yellow;
                                    break;
                                  case "Black":
                                    colorMap[pie.cOLORDESC!] = Colors.black;
                                    break;
                                  case "White":
                                    colorMap[pie.cOLORDESC!] = Colors.white;
                                    break;
                                  case "Orange":
                                    colorMap[pie.cOLORDESC!] = Colors.orange;
                                    break;
                                // ... other cases
                                  default:
                                    colorMap[pie.cOLORDESC!] = Colors.grey;
                                }
                              }


                              return SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 25),
                                        Center(
                                          child: Text(item.title ?? "",
                                              style: TextStyle(fontSize: 18,
                                                  fontWeight: FontWeight
                                                      .bold)), // Display title
                                        ),

                                        Column(
                                          children: <Widget>[
                                          /*  Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Column(
                                                  children: <Widget>[

                                                    SizedBox(height: 15),
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          if (dataMap.isNotEmpty)
                                                            PieChart(
                                                              dataMap: dataMap,
                                                              colorList: colorMap
                                                                  .values.toList(),
                                                              chartType: ChartType
                                                                  .disc,
                                                              chartRadius: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width / 2.5,
                                                              legendOptions: LegendOptions(
                                                                  showLegends: false),
                                                              chartValuesOptions: ChartValuesOptions(
                                                                showChartValuesInPercentage: true,
                                                                showChartValuesOutside: true,
                                                                showChartValues: true,
                                                                decimalPlaces: 1,
                                                              ),
                                                            ),
                                                          SizedBox(width: 45),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 15),
                                                  ],
                                                ),
                                                SizedBox(width: 30),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start, // Align to start
                                                  children: [
                                                    for (var pie in pieChartData)...[

                                                      CircleWithDescription(
                                                          color: getColorFromDescription(
                                                              pie.cOLORDESC!
                                                                  .capitalizeFirst),
                                                          description: pie
                                                              .cOLORNAME!),
                                                      SizedBox(
                                                        width: 20, height: 10,),

                                                    ]


                                                  ],
                                                ),

                                              ],
                                            ),*/
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      const SizedBox(height: 15),
                                                      Center(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            if (dataMap.isNotEmpty)
                                                              PieChart(
                                                                dataMap: dataMap,
                                                                colorList: colorMap.values.toList(),
                                                                chartType: ChartType.disc,
                                                                chartRadius:
                                                                MediaQuery.of(context).size.width > 900
                                                                    ? 220
                                                                    : 160,
                                                                legendOptions: const LegendOptions(
                                                                  showLegends: false,
                                                                ),
                                                                chartValuesOptions: const ChartValuesOptions(
                                                                  showChartValuesInPercentage: true,
                                                                  showChartValuesOutside: true,
                                                                  showChartValues: true,
                                                                  decimalPlaces: 1,
                                                                ),
                                                              ),
                                                            const SizedBox(width: 45),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 30),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      for (var pie in pieChartData) ...[
                                                        CircleWithDescription(
                                                          color: getColorFromDescription(
                                                              pie.cOLORDESC!.capitalizeFirst),
                                                          description: pie.cOLORNAME!,
                                                        ),
                                                        const SizedBox(height: 10),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Table(
                                                border: TableBorder.all(),

                                                columnWidths: {
                                                  0: FixedColumnWidth(200),
                                                  1: FixedColumnWidth(120),
                                                  2: FixedColumnWidth(120),
                                                  3: FixedColumnWidth(120),
                                                },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      TableCell(child:
                                                      Padding(
                                                          padding: EdgeInsets.all(
                                                              8.0),
                                                          // Customize padding here
                                                          child: Text('C.D.D Status',
                                                              style: TextStyle(
                                                                color: Colors.blue,
                                                                fontWeight: FontWeight
                                                                    .bold,)))),
                                                      TableCell(child:
                                                      Padding(
                                                          padding: EdgeInsets.all(
                                                              8.0),
                                                          // Customize padding here
                                                          child: Text('Count',
                                                              style: TextStyle(
                                                                color: Colors.blue,
                                                                fontWeight: FontWeight
                                                                    .bold,)))),
                                                      TableCell(child:
                                                      Padding(
                                                          padding: EdgeInsets.all(
                                                              8.0),
                                                          // Customize padding here
                                                          child: Text('Quantity',
                                                              style: TextStyle(
                                                                color: Colors.blue,
                                                                fontWeight: FontWeight
                                                                    .bold,)))),
                                                      TableCell(child: Padding(
                                                          padding: EdgeInsets.all(
                                                              8.0),
                                                          // Customize padding here
                                                          child: Text(
                                                              'Value(In Lakhs)',
                                                              style: TextStyle(
                                                                color: Colors.blue,
                                                                fontWeight: FontWeight
                                                                    .bold,)))),
                                                    ],
                                                  ),
                                                  // Loop through the pieChart data and create rows dynamically
                                                  for (var pie in item.pieChart!) ...[
                                                    TableRow(
                                                      children: [
                                                        TableCell(child:
                                                        Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text(
                                                                pie.cOLORNAME!))),
                                                        TableCell(child: Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text(pie.nOOFSO
                                                                .toString()))),
                                                        TableCell(child: Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text(
                                                                pie.qTY.toString()))),
                                                        TableCell(child: Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text(pie.sOVALUE
                                                                .toString()))),
                                                      ],
                                                    ),

                                                  ],
                                                  if(item.totals != null)...[
                                                    TableRow(
                                                      children: [
                                                        TableCell(child:
                                                        Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text('Total',
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight
                                                                        .bold)))),
                                                        TableCell(child: Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text(item.totals!
                                                                .totalCount
                                                                .toString() ?? '0'))),
                                                        TableCell(child: Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text(
                                                                item.totals!.totalQty
                                                                    .toString() ??
                                                                    "0.0"))),
                                                        TableCell(child: Padding(
                                                            padding: EdgeInsets.all(
                                                                8.0),
                                                            // Customize padding here
                                                            child: Text(item.totals!
                                                                .totalValue != null && item.totals!
                                                                .totalValue != "0.0"
                                                                ? item.totals!
                                                                .totalValue.toString()
                                                                : '0'),
                                                        )),
                                                      ],
                                                    ),
                                                  ]
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20,),
                                          ],),


                                      ],),
                                  ],),
                              );
                            },
                          ),
                          Center(
                            child: Text('Dashboared - Error Count',
                                style: TextStyle(fontSize: 18,
                                    fontWeight: FontWeight.bold)), // Display title
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              border: TableBorder.all(),

                              columnWidths: {
                                0: FixedColumnWidth(40),
                                1: FixedColumnWidth(200),
                                2: FixedColumnWidth(120),
                                3: FixedColumnWidth(120),
                                4: FixedColumnWidth(120),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(child:
                                    Padding(
                                        padding: EdgeInsets.all(8.0),
                                        // Customize padding here
                                        child: Text('#',
                                            style: TextStyle(color: Colors.blue,
                                              fontWeight: FontWeight.bold,)))),


                                    TableCell(child:
                                    Padding(
                                        padding: EdgeInsets.all(8.0),
                                        // Customize padding here
                                        child: Text('Alerts Messages',
                                            style: TextStyle(color: Colors.blue,
                                              fontWeight: FontWeight.bold,)))),
                                    TableCell(child:
                                    Padding(
                                        padding: EdgeInsets.all(8.0),
                                        // Customize padding here
                                        child: Text('Count',
                                            style: TextStyle(color: Colors.blue,
                                              fontWeight: FontWeight.bold,)))),
                                    TableCell(child:
                                    Padding(
                                        padding: EdgeInsets.all(8.0),
                                        // Customize padding here
                                        child: Text('Quantity',
                                            style: TextStyle(color: Colors.blue,
                                              fontWeight: FontWeight.bold,)))),
                                    TableCell(child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        // Customize padding here
                                        child: Text('Value(In Lakhs)',
                                            style: TextStyle(color: Colors.blue,
                                              fontWeight: FontWeight.bold,)))),
                                  ],
                                ),
                                // Loop through the pieChart data and create rows dynamically
                                for (int j = 0; j < service.dashboardData!.errorList!
                                    .length; j++) ...[
                                  TableRow(
                                    children: [
                                      TableCell(child:
                                      Padding(
                                          padding: EdgeInsets.all(8.0),
                                          // Customize padding here
                                          child: Text((j + 1).toString(),
                                            style: TextStyle(color: Color(int.parse(
                                                "0xFF${service.dashboardData!
                                                    .errorList![j].bGCOLOR!.substring(
                                                    1)}"))

                                            ),
                                          ))),
                                      TableCell(child:
                                      Padding(
                                          padding: EdgeInsets.all(8.0),
                                          // Customize padding here
                                          child: Text(
                                            service.dashboardData!.errorList![j]
                                                .rEASON!,
                                            style: TextStyle(color: Color(int.parse(
                                                "0xFF${service.dashboardData!
                                                    .errorList![j].bGCOLOR!.substring(
                                                    1)}"))
                                            ),))),
                                      TableCell(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          // Customize padding here
                                          child: Text(
                                            service.dashboardData!.errorList![j]
                                                .rECORDCNT.toString(),
                                            style: TextStyle(color: Color(int.parse(
                                                "0xFF${service.dashboardData!
                                                    .errorList![j].bGCOLOR!.substring(
                                                    1)}"))

                                            ),))),
                                      TableCell(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          // Customize padding here
                                          child: Text(
                                            service.dashboardData!.errorList![j].qTY
                                                .toString(),
                                            style: TextStyle(color: Color(int.parse(
                                                "0xFF${service.dashboardData!
                                                    .errorList![j].bGCOLOR!.substring(
                                                    1)}"))

                                            ),

                                          ))),
                                      TableCell(child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          // Customize padding here
                                          child: Text(
                                            (service.dashboardData!.errorList![j].vAL != null && service.dashboardData!.errorList![j].vAL != 0.0
                                                ? service.dashboardData!.errorList![j].vAL.toString()
                                                : '0'),
                                            style: TextStyle(color: Color(int.parse(
                                                "0xFF${service.dashboardData!
                                                    .errorList![j].bGCOLOR!.substring(
                                                    1)}"))

                                            ),
                                          ))),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                        ]));
              }

            },
          ),
        ),
      ),
    );
  }


  Color getColorFromDescription(String? colorDesc) {
  // Map color descriptions to actual Color objects
  switch (colorDesc?.capitalizeFirst) {
  case "Green":
  return Colors.green;
  case "Red":
  return Colors.red;
  case "Yellow":
  return Colors.yellow;
  case "Blue":
  return Colors.blue;
  case "Black":
  return Colors.black;
  case "White":
  return Colors.white;
  default:
  return Colors.grey; // Default color for unknown description
  }
  }

  }
class CircleWithDescription extends StatelessWidget {
  final Color color;
  final String description;

  CircleWithDescription({required this.color, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20.0, // Circle size
          height: 20.0, // Circle size
          decoration: BoxDecoration(
            color: color, // Circle color
            shape: BoxShape.circle, // Make it a circle
          ),
        ),
        SizedBox(width: 10), // Space between circle and text
        Text(description), // Text description
      ],
    );
  }
}