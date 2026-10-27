import 'package:erpflutter/provider/financialyear_provider.dart';
import 'package:erpflutter/screens/companylist/model/transaction_model.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/plantlist/plantlist.dart';
import 'package:erpflutter/services/ApiProvider.dart';
import 'package:erpflutter/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../app_colors.dart';
import '../../provider/themecontroller.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
 // late Future<List<TransactionModel>> futureTransactions;
  late FinancialYearProvider provider;
  late ThemeController themeController;

  late Future<dynamic> futureTransactions;
  @override
  void initState() {
    super.initState();
    futureTransactions = ApiProvider().fetchTransactions("6");
    provider = context.read<FinancialYearProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinancialYearProvider>().loadTransactions();
    });  }

  /// 🔴 BACK PRESS HANDLER
  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Do you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              exit(0); // 🔴 Exit App
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    themeController = Provider.of(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final screenWidth = MediaQuery.of(context).size.width;

    final drawerWidth = 700.0;
    final leftPadding =
    screenWidth > drawerWidth ? (screenWidth - drawerWidth) / 2 : 0;
    final selectedYear =
        context.read<FinancialYearProvider>().selectedYear;
    return WillPopScope(
      onWillPop: _onWillPop, // 🔴 Important
      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: isDesktop
                ?  Colors.white // dark app background for Windows/Desktop
                : const Color(0xFFF6F9FC), // light app background for mobile
            appBar:PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child: AppBar(
              title:  Text("Company Name",style: GoogleFonts.lato(fontSize: Platform.isIOS ? 17 :14, fontWeight: FontWeight.normal),),
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              actions: [Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Consumer<FinancialYearProvider>(
                    builder: (context, provider, _) {
                      final selectedYear = provider.selectedYear;

                      return Text(
                        selectedYear?.description ?? '',
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:Platform.isIOS ? 17 : 14,
                        ),
                      );
                    },
                  ),
                ),
              ),
              ],
            )))),
            body: FutureBuilder(
              future: futureTransactions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return const Center(child: Text("No Data Found"));
                }

                return  Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      color:const Color(0xFFF5F7FB),
                      width: isDesktop ? 700 : double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];

                      return Card(
                        color: const Color(0xFFE3F2FD),
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            // Your click action
                            showLoader(context);
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString(
                                "PLANTORGSTRUCTID", item.orgStrucId);
                            Provider.of<PlantProvider>(context, listen: false).setCompanyName(item.companyName);
                            hideLoader(context);

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 10),
                                reverseTransitionDuration: const Duration(milliseconds: 10),
                                pageBuilder: (_, animation, secondaryAnimation) =>
                                    PlantListScreen(
                                      orgStrucId: item.orgStrucId,
                                      companyName: item.companyName,
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
                         /*   Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    PlantListScreen(orgStrucId: item.orgStrucId,companyName:item.companyName)));*/

                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Container(
                                  height: 52,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.business_rounded,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 0),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                       Text(
                                          item.companyName,
                                          style: GoogleFonts.lato(
                                            fontSize:Platform.isIOS ? 17 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          softWrap: true,
                                        ),


                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                );
              },
            ),
            drawer: MyDrawer(),
            drawerEdgeDragWidth: 100,

          ),
        ),
      ),
    );
  }

  void showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void hideLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
