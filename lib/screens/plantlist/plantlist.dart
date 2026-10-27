import 'dart:convert';

import 'package:erpflutter/barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import 'package:erpflutter/database/database_service.dart';
import 'package:erpflutter/database/secure_storage_service.dart';
import 'package:erpflutter/models/sync_s_ledger_model.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/provider/financialyear_provider.dart';
import 'package:erpflutter/screens/companylist/model/transaction_model.dart';
import 'package:erpflutter/screens/login/login_controller.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/services/ApiProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../Dashboard.dart';
import '../../app_colors.dart';
import '../../models/LoginResponseModel.dart';
import '../../provider/themecontroller.dart';
import '../../utils/global_variables.dart';
import '../companylist/company_list_screen.dart';

class PlantListScreen extends StatefulWidget {
  final String orgStrucId;
  final String companyName;
  const PlantListScreen({super.key,  required this.orgStrucId,required this.companyName});

  @override
  State<PlantListScreen> createState() =>
      _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  late Future<List<TransactionModel>> plantlist;
  var CompanyName;
  LoginResponseModel? loginResponseModel;
  late ThemeController themeController;
  void getUserResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs = await SharedPreferences.getInstance();
    setState(() {
      loginResponseModel = LoginResponseModel.fromJson(
          jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;

    });

  }
  @override
  void initState() {
    super.initState();
    CompanyName = context.read<PlantProvider>().companyName;
    plantlist = ApiProvider().fetchPlantLIst(widget.orgStrucId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserResponse();

    });
  }

  /// 🔴 BACK PRESS HANDLER

  Future<bool> _onWillPop() async {
    return true; // allows Navigator.pop()
  }
  @override
  Widget build(BuildContext context) {
    themeController = Provider.of<ThemeController>(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final selectedYear = context.read<FinancialYearProvider>().selectedYear;
    return PopScope(
      canPop: true,
      onPopInvoked: (_) async{
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionListScreen(),
            ),
          );
        });
      },

      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: isDesktop
                ?  Colors.white // dark app background for Windows/Desktop
                : const Color(0xffF5F7FA), // light app background for mobile
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child:AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () async{
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 10),
                      pageBuilder: (_, animation, secondaryAnimation) =>
                      const TransactionListScreen(),
                      transitionsBuilder: (_, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0), // Slide from left
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
               /*   WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionListScreen(),
                      ),
                    );
                  });*/

                },
              ),
              actions: [
                Consumer<FinancialYearProvider>(
                  builder: (context, provider, _) {
                    final year = provider.selectedYear;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: Text(
                          year?.description ?? '',
                          style:  TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: Platform.isIOS ? 17 :14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              title:  Text(CompanyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize:Platform.isIOS ? 17 : 14,
                fontWeight: FontWeight.normal,
              )),
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,

            )))),
            body: FutureBuilder<List<TransactionModel>>(
              future: plantlist,
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


                return Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      color:const Color(0xFFF5F7FB),
                      width: isDesktop ? 700 : double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];

                      return GestureDetector(
                        onTap: () async {
                          showLoader(context);
                          await SecureStorageService.updateOrgStructId(item.orgStrucId);
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString("ORGSTRUCTID", item.orgStrucId);

                          String? crntno = prefs.getString("CONTROLNO");
                          prefs.setString("CONTROLNO", crntno ?? '');

                          await getData();

                          print(item.orgStrucId);
                          print("************************$crntno");

                       //   _loadBarcodeData();
                          final provider = Provider.of<BarcodeProvider>(context, listen: false);

                         /* try {
                            provider.fetchBarcodeDetails("1");
                            provider.fetchBarcodeDetails("2");

                          } catch (e) {
                            print("Error while loading barcode data: $e");
                          }*/
                          final menu = loginResponseModel!
                              .data!
                              .menulist!
                              .data[0]
                              .list[index];

// Allowed Menu IDs
                          const allowedMenuIds = [984, 983];

                          if (allowedMenuIds.contains(menu.id)) {
                            try {
                              provider.fetchBarcodeDetails("1");
                              provider.fetchBarcodeDetails("2");
                            } catch (e) {
                              print("Error while loading barcode data: $e");
                            }
                          }
                          Provider.of<PlantProvider>(context, listen: false)
                              .setPlantName(item.companyName);

                          try {
                            String? userID = prefs.getString('USERID');
                            String? token = prefs.getString('TOKEN');
                            String? posID = prefs.getString('POSID');
                            String? controlno = prefs.getString("CONTROLNO");

                            var strSLedger = prefs.getString('syncSLedgerLastSyncDate');

                            SyncSLedgerModel syncSLedgerModel =
                            await Provider.of<LoginController>(context, listen: false)
                                .syncSLedgerData({
                              "XMLFILE": {
                                "FLAG": "1",
                                "LASTSYNCDATE":
                                strSLedger ?? "01-Jan-1900 00:00:00",
                                "MID": "0",
                                "ORGSTRUCTID": item.orgStrucId,
                                "POSID": posID,
                                "TOKEN": token,
                                "USERID": userID,
                                "CONTROLNO": controlno
                              }
                            });

                            await DatabaseService()
                                .insertOrUpdateSLedger(syncSLedgerModel);

                            if (syncSLedgerModel.dATA != null) {
                              prefs.setString(
                                "syncSLedgerLastSyncDate",
                                syncSLedgerModel.dATA!.sYNCDATETIME ??
                                    "01-Jan-1900 00:00:00",
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("calling syncSLedgerModel API: $e"),
                              ),
                            );
                          }

                          hideLoader(context);
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 10),
                              reverseTransitionDuration: const Duration(milliseconds: 10),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  AppShell(
                                    role: "Admin",
                                    plant: item.companyName,
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
                        /*  Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppShell(
                                role: "Admin",
                                plant: item.companyName,
                              ),
                            ),
                          );*/
                        },
                        child: Card(
                          color: const Color(0xFFE3F2FD),
                          margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.factory_outlined,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Text(
                                      item.companyName,
                                      style: GoogleFonts.lato(
                                        fontSize:Platform.isIOS ? 17 : 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      softWrap: true,
                                      maxLines: 3,
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.all(6),
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
                        ),
                      );
                    },
                  )),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _loadBarcodeData() async {
    final provider = Provider.of<BarcodeProvider>(context, listen: false);

    try {
      provider.fetchBarcodeDetails("1");
    provider.fetchBarcodeDetails("2");
     /* await Future.wait([
        provider.fetchBarcodeDetails("1"),
        provider.fetchBarcodeDetails("2"),
      ]);*/
    } catch (e) {
      print("Error while loading barcode data: $e");
    }
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
