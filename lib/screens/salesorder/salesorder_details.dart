import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/get_approval_history_request_model.dart';
import '../../models/get_approval_history_response_model.dart';
import '../../provider/themecontroller.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../aprovals/approvals_controller.dart';

class DetailsScreen extends StatelessWidget {
  // Sales order details
  final String? status;
  final String? invoiceNumber;
  final String? amount;
  final String? customerName;
  final String? dueDate;
  final String? createdBy;
  final String? salesPerson;
  final String? formattedDate;
  final String? porefno;
  final String? porefdate;
  final String? salestype;
  final String? mid;
  final String? docid;
  final String? menuid;

  // Line items details
  final List<Map<String, String>> lineItems;

  DetailsScreen({
    this.status,
    this.invoiceNumber,
    this.amount,
    this.customerName,
    this.dueDate,
    this.createdBy,
    this.salesPerson,
    this.formattedDate,
    this.porefno,
    this.porefdate,
    this.salestype,
    this.mid,
    this.docid,
    this.menuid,
    required this.lineItems,
  });
  late ThemeController themeController;

  GetApproveHistoryResponseModel approvehistoryresponse =
      new GetApproveHistoryResponseModel();
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          backgroundColor: isDesktop
              ?  Colors.white // dark app background for Windows/Desktop
              : const Color(0xffF5F7FA), // light app background for mobile
           //   backgroundColor: const Color(0xffF5F7FA),
        /*  appBar: AppBar(
            centerTitle: Platform.isWindows ? true : false,
            backgroundColor: AppColors.APPCOLOR,
            foregroundColor: Colors.white,
            title: Text("Details",style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            )),

          ),*/
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: SizedBox(
                      width: isDesktop ? 700 : double.infinity,
                      child:AppBar(
            backgroundColor: themeController.primaryColor,

            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.white,
            centerTitle: false,
            titleSpacing: 16,
            title:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sales Order",
                  style: GoogleFonts.lato(

                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  )
                ),
                SizedBox(height: 2),
                Text(
                  "Order Details",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
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
          body: Padding(
            padding: const EdgeInsets.all(0),
            child: ScrollConfiguration(
              behavior: MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                },
              ),
              child: Center(
                child: Container(
                  width: Platform.isAndroid
                      ? double.infinity                       // FULL width on Android
                      : 700,
                  decoration: Platform.isAndroid
                      ? null                                   // 🔥 No border on Android
                      : BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        // Sales Order Details Section
                     /*   Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Sales Order Details",
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),*/

                        orderHeaderCard(),
                       SizedBox(height: 10,),

                       /* buildDetailRow("Document Number", invoiceNumber),
                        buildDivider(),
                        buildDetailRow("Status", status),
                        buildDivider(),
                        buildDetailRow("Customer Name", customerName),
                        buildDivider(),
                        buildDetailRow("Currency", '\u{20B9} $amount'),
                        buildDivider(),
                        buildDetailRow("Due Date", dueDate),
                        buildDivider(),
                        buildDetailRow("Document Date", formattedDate),
                        buildDivider(),
                        buildDetailRow("PO/Ref NO", porefno),*/
                        infoCard(
                          title: "Document Number",
                          icon: Icons.receipt_long,
                          value: invoiceNumber ?? "",
                        ),

                        infoCard(
                          title: "Customer",
                          icon: Icons.business,
                          value: customerName ?? "",
                        ),

                        infoCard(
                          title: "Document Date",
                          icon: Icons.calendar_today,
                          value: formattedDate ?? "",
                        ),

                        infoCard(
                          title: "Sales Executive",
                          icon: Icons.person,
                          value: salesPerson ?? "",
                        ),

                        infoCard(
                          title: "PO Reference",
                          icon: Icons.description_outlined,
                          value: porefno ?? "",
                        ),

                        infoCard(
                          title: "PO/Ref Date",
                          icon: Icons.event,
                          value: porefdate ?? "",
                        ),
                        /*buildDivider(),
                        buildDetailRow("PO/Ref Date", porefdate),*/
                        //buildDivider(),
                       // buildDetailRow("Sales Type", salestype),
                        infoCard(
                          title: "Sales Type",
                          icon: Icons.shopping_bag_outlined,
                          value: salestype ?? "",
                        ),
                        infoCard(
                          title: "Created By",
                          icon: Icons.person,
                          value: createdBy ?? "",
                        ),
                        infoCard(
                          title: "Sales Executive",
                          icon: Icons.person,
                          value: salesPerson ?? "",
                        ),
                       /* buildDivider(),
                        buildDetailRow("Created By", createdBy),
                        buildDivider(),*/
                        //buildDetailRow("Sales Executive", salesPerson),
                        SizedBox(height: 0),


                        // Line Items Details Section
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Line Items Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.APPCOLOR,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        ...lineItems.map((item) => buildLineItemCart(item)).toList(),
                        SizedBox(height: 12),

                        // Approval History Section
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Approval History",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.APPCOLOR,
                            ),
                          ),
                        ),
                        FutureBuilder<GetApproveHistoryResponseModel>(
                          future: ApproveHistoryapicall(
                            context,
                            docid!,
                            "92",
                            mid!,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(color: Colors.blue),
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.data != null) {
                              final approveResponseModel = snapshot.data!;
                              if (approveResponseModel != null &&
                                  approveResponseModel.data != null) {
                                return SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      for (int k = 0;
                                      k <
                                          approveResponseModel
                                              .data!.list.length;
                                      k++) ...[
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${approveResponseModel.data!.list[k].releasecount!} Release',
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.lato(
                                                color: Colors.red,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(color: Colors.grey),
                                        for (int j = 0;
                                        j <
                                            approveResponseModel.data!
                                                .list[k].sublist.length;
                                        j++) ...[
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  const Icon(
                                                    Icons
                                                        .supervised_user_circle,
                                                    size: 50.0,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: historyTile(
                                                      name: approveResponseModel
                                                          .data!
                                                          .list[k]
                                                          .sublist[j]
                                                          .name!,

                                                      status: approveResponseModel
                                                          .data!
                                                          .list[k]
                                                          .sublist[j]
                                                          .approverstatus!,

                                                      date: approveResponseModel
                                                          .data!
                                                          .list[k]
                                                          .sublist[j]
                                                          .date!,

                                                      statusId: approveResponseModel
                                                          .data!
                                                          .list[k]
                                                          .sublist[j]
                                                          .statusid!,
                                                    ),
                                                    /*
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Container(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: <Widget>[
                                                                  const SizedBox(
                                                                      height: 5),
                                                                  Text(
                                                                    approveResponseModel
                                                                        .data!
                                                                        .list[k]
                                                                        .sublist[j]
                                                                        .name!,
                                                                    style:
                                                                   GoogleFonts.lato(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                      fontSize:
                                                                      14,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height: 2),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                                children: <Widget>[
                                                                  const SizedBox(
                                                                      height: 5),
                                                                  if (approveResponseModel
                                                                      .data!
                                                                      .list[k]
                                                                      .sublist[
                                                                  j]
                                                                      .statusid ==
                                                                      "3") ...[
                                                                    Container(
                                                                      padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                      child:
                                                                      Align(
                                                                        alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                        child:
                                                                        Container(
                                                                          color: Colors
                                                                              .red,
                                                                          padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                          child:
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].date!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ] else if (approveResponseModel
                                                                      .data!
                                                                      .list[k]
                                                                      .sublist[
                                                                  j]
                                                                      .date !=
                                                                      "01-Jan-1900 12:00 AM") ...[
                                                                    Container(
                                                                      padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                      child:
                                                                      Align(
                                                                        alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                        child:
                                                                        Container(
                                                                          color: Colors
                                                                              .orangeAccent,
                                                                          padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                          child:
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].date!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ] else ...[
                                                                    Container(
                                                                      padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                      child:
                                                                      Align(
                                                                        alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                        child:
                                                                        Container(
                                                                          color: Colors
                                                                              .blue,
                                                                          padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                          child:
                                                                          Text(
                                                                            approveResponseModel
                                                                                .data!
                                                                                .list[k]
                                                                                .sublist[j]
                                                                                .approverstatus!,
                                                                            style:
                                                                            GoogleFonts.lato(
                                                                              fontSize:
                                                                              12,
                                                                              color:
                                                                              Colors.black,
                                                                              fontWeight:
                                                                              FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                  const SizedBox(
                                                                      height: 2),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),*/
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(width: 100, height: 20),
                                      ],
                                    ],
                                  ),
                                );
                              } else {
                                return  Center(
                                  child: Text(
                                    "No Records to display",
                                    style: GoogleFonts.lato(fontSize: 14),
                                  ),
                                );
                              }


                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    "No Records to display",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Sales Order Details Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Sales Order Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16),
            buildDetailRow("Document Number", invoiceNumber),
            buildDivider(),
            buildDetailRow("Status", status),
            buildDivider(),
            buildDetailRow("Customer Name", customerName),
            buildDivider(),
            buildDetailRow("Currency", '\u{20B9} $amount'),
            buildDivider(),
            buildDetailRow("Due Date", dueDate),
            buildDivider(),
            buildDetailRow("Document Date", formattedDate),
            buildDivider(),
            buildDetailRow("PO/Ref NO", porefno),
            buildDivider(),
            buildDetailRow("PO/Ref Date", porefdate),
            buildDivider(),
            buildDetailRow("Sales Type", salestype),
            buildDivider(),
            buildDetailRow("Created By", createdBy),
            buildDivider(),
            buildDetailRow("Sales Executive", salesPerson),
            SizedBox(height: 24),

            // Line Items Details Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Line Items Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 8),

            // Loop through the line items and display each one
            ...lineItems.map((item) => buildLineItemCart(item)).toList(),
            SizedBox(height: 12),
            // Sales Order History Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Approval History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Container(
              child: FutureBuilder<GetApproveHistoryResponseModel>(
                future: ApproveHistoryapicall(
                  context,
                  docid!,
                  "92",
                  mid!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    GetApproveHistoryResponseModel?
                    approveResponseModel = snapshot.data;
                    if (approveResponseModel != null) {
                      if (approveResponseModel.data != null) {
                        return SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              for (int k = 0;
                              k <
                                  approveResponseModel
                                      .data!.list.length;
                              k++) ...[
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  // Aligns children to start
                                  children: [
                                    Text(
                                      approveResponseModel!
                                          .data!
                                          .list![k]
                                          .releasecount! +
                                          " Release",
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    )
                                  ],
                                ),
                                Divider(color: Colors.grey),
                                for (int j = 0;
                                j <
                                    approveResponseModel.data!
                                        .list[k].sublist.length;
                                j++) ...[
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons
                                                .supervised_user_circle,
                                            size: 50.0,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: <Widget>[
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          approveResponseModel
                                                              .data!
                                                              .list![
                                                          k]
                                                              .sublist![
                                                          j]
                                                              .name!,
                                                          style:
                                                          const TextStyle(
                                                            color: Colors
                                                                .black,
                                                            fontWeight:
                                                            FontWeight
                                                                .normal,
                                                            fontSize:
                                                            14,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .end,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .end,
                                                      children: <Widget>[
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        if (approveResponseModel
                                                            .data!
                                                            .list[
                                                        k]
                                                            .sublist[
                                                        j]
                                                            .statusid! ==
                                                            "3") ...[
                                                          Container(
                                                            padding:
                                                            EdgeInsets.all(
                                                                8.0),
                                                            child:
                                                            Align(
                                                              alignment:
                                                              Alignment.centerRight,
                                                              child:
                                                              Container(
                                                                color:
                                                                Colors.red,
                                                                padding:
                                                                EdgeInsets.all(4.0),
                                                                child:
                                                                Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment.end,
                                                                  children: [
                                                                    Text(
                                                                      approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      approveResponseModel.data!.list[k].sublist[j].date!,
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ] else if (approveResponseModel
                                                            .data!
                                                            .list[
                                                        k]
                                                            .sublist[
                                                        j]
                                                            .date !=
                                                            "01-Jan-1900 12:00 AM") ...[
                                                          Container(
                                                            padding:
                                                            EdgeInsets.all(
                                                                8.0),
                                                            child:
                                                            Align(
                                                              alignment:
                                                              Alignment.centerRight,
                                                              child:
                                                              Container(
                                                                color:
                                                                Colors.orangeAccent,
                                                                padding:
                                                                EdgeInsets.all(4.0),
                                                                child:
                                                                Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment.end,
                                                                  children: [
                                                                    Text(
                                                                      approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      approveResponseModel.data!.list[k].sublist[j].date!,
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ] else ...[
                                                          Container(
                                                            padding:
                                                            EdgeInsets.all(
                                                                8.0),
                                                            child:
                                                            Align(
                                                              alignment:
                                                              Alignment.centerRight,
                                                              child:
                                                              Container(
                                                                color:
                                                                Colors.blue,
                                                                padding:
                                                                EdgeInsets.all(4.0),
                                                                child:
                                                                Flexible(
                                                                  child:
                                                                  Text(
                                                                    approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(
                                    width: 100,
                                    // Width of the box
                                    height: 20),
                              ],
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            "No Records to display",
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }
                    }
                  }
                  return Center(
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20),
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }*/
  Widget infoCard({
    required String title,
    required IconData icon,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xff1565C0),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Cart-style UI for line items with all details in one line
/*  Widget buildLineItemCart(Map<String, String> item) {

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailRowHeader(
                      item['Product_Code']! +
                          " / " +
                          item['Product_Description']!,
                      "",
                      true),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDetailRow("Unit Rate", item['UnitRate'], true),
                      buildDetailRow("UOM Code", item['UOMCODE'], true),
                      buildDetailRow(
                          "Delivery Date", item['DiliveryDate']!.split(' ')[0], true),
                    ],
                  ),
                ),
                SizedBox(width: 10), // Space between columns
                // Right Column
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDetailRow("Quantity", item['QTY'], true),
                      buildDetailRow("Amount", item['Amount'], true),
                      buildDetailRow(
                          "Last Sale Rate", item['LastSaleRate'], true),
                    ],
                  ),
                ),
              ],
            ),
            // Divider after the entire row
          ],
        ),
      ),
    );
  }*/
  Widget buildLineItemCart(Map<String, String> item) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Product Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        item['Product_Description'] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['Product_Code'] ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(height: 1),

            const SizedBox(height: 15),

            /// Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: Column(
                    children: [
                      infoTile(
                        Icons.currency_rupee,
                        "Unit Rate",
                        item['UnitRate'],
                      ),
                      infoTile(
                        Icons.straighten,
                        "UOM",
                        item['UOMCODE'],
                      ),
                      infoTile(
                        Icons.calendar_today_outlined,
                        "Delivery",
                        item['DiliveryDate']
                            ?.split(' ')
                            .first ??
                            "",
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    children: [
                      infoTile(
                        Icons.shopping_cart_outlined,
                        "Quantity",
                        item['QTY'],
                      ),
                      infoTile(
                        Icons.history,
                        "Last Sale",
                        item['LastSaleRate'],
                      ),
                      infoTile(
                        Icons.payments_outlined,
                        "Amount",
                        item['Amount'],
                        valueColor: Colors.green,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(
      IconData icon,
      String title,
      String? value, {
        Color? valueColor,
        bool isBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? "-",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    isBold ? FontWeight.bold : FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Helper to build key-value rows with smaller font size
  Widget buildDetailRow(String label, String? value, [bool isTitle = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 0,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12, // Smaller font size for titles
                color: isTitle ? Colors.blue : Colors.black,
              ),
            ),
          ),
          SizedBox(width: 8), // Space between label and value
          Expanded(
            flex: 3,
            child: Text(
              value ?? "N/A",
              style: TextStyle(fontSize: 12), // Smaller font size for values
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
  Widget orderHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0,4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Expanded(
                child: Text(
                  invoiceNumber ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status ?? "",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height:12),

          Text(
            customerName ?? "",
            style: const TextStyle(
              fontSize:16,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height:20),

          Text(
            "₹ $amount",
            style: const TextStyle(
              fontSize:30,
              fontWeight: FontWeight.bold,
              color: Color(0xff1565C0),
            ),
          ),

          const SizedBox(height:20),

          Row(
            children: [

              Icon(Icons.calendar_today,size:18),

              SizedBox(width:6),

              Text(dueDate ?? ""),

              Spacer(),

              Icon(Icons.person,size:18),

              SizedBox(width:6),

              Text(salesPerson ?? "")
            ],
          )
        ],
      ),
    );
  }
  Widget historyTile({
    required String name,
    required String status,
    required String date,
    required String statusId,
  })
  {
    Color statusColor;

    if (statusId == "3") {
      statusColor = Colors.red;
    } else if (date != "01-Jan-1900 12:00 AM") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Timeline Dot
          Column(
            children: [
              SizedBox(height: 20,),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      name,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.lato(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      date,
                      style: GoogleFonts.lato(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Helper to build key-value rows with smaller font size (Header)
  Widget buildDetailRowHeader(String label, String? value,
      [bool isTitle = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The first part of the row (label)
          Expanded(
            flex: 25,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12, // Smaller font size for titles
                color: isTitle ? Colors.black : Colors.black,
              ),
              overflow: TextOverflow.ellipsis, // Prevent text overflow
            ),
          ),
          SizedBox(width: 8), // Space between label and value
          // The second part of the row (value)
          Expanded(
            flex: 1,
            child: Text(
              value ?? "N/A",
              style: TextStyle(fontSize: 12), // Smaller font size for values
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a divider
  Widget buildDivider() {
    return Divider(
      thickness: 1,
      color: Colors.grey,
    );
  }

  Future<GetApproveHistoryResponseModel> ApproveHistoryapicall(
    BuildContext context,
    String strDocid,
    String strMenuId,
    String strMid,
  ) async {
    try {
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? UserID = prefs.getString('USERID');
        String? OrStID = prefs.getString('ORGSTRUCTID');
        String? Token = prefs.getString('TOKEN');
        String? PosID = prefs.getString('POSID');
        String? controlno = prefs.getString('CONTROLNO');
        GetApproveHistoryRequestModel approvehistoryrequestmodel =
            GetApproveHistoryRequestModel();
        approvehistoryrequestmodel.xMLFILE = XMLFILEAPPROVEHISTORY();
        approvehistoryrequestmodel.xMLFILE!.dOCID = strDocid;
        approvehistoryrequestmodel.xMLFILE!.fLAG = "1";
        approvehistoryrequestmodel.xMLFILE!.fROMDATE = "";
        approvehistoryrequestmodel.xMLFILE!.mENUID = strMenuId;
        approvehistoryrequestmodel.xMLFILE!.mID = strMid;
        approvehistoryrequestmodel.xMLFILE!.oRGSTRUCTID = orgStructId;
        approvehistoryrequestmodel.xMLFILE!.controlno = controlno;
        approvehistoryrequestmodel.xMLFILE!.pAGENO = 1;
        approvehistoryrequestmodel.xMLFILE!.pOSID = PosID;
        approvehistoryrequestmodel.xMLFILE!.tODATE = "";
        approvehistoryrequestmodel.xMLFILE!.tOKEN = Token;
        approvehistoryrequestmodel.xMLFILE!.uSERID = UserID;
        approvehistoryrequestmodel.xMLFILE!.controlno = controlno!;
        approvehistoryresponse =
            await Provider.of<ApprovalsController>(context, listen: false)
                .GetApprovalHistory(approvehistoryrequestmodel, context);

        print(
            'apporval details-------------> ${approvehistoryresponse.data..toString()}');

        if (approvehistoryresponse != null) {
        } else {}
      } else {
        return approvehistoryresponse;
      }
    } catch (error, stacktrace) {
      // print("Exception occured: $error stackTrace: $stacktrace");
    }
    return approvehistoryresponse;
  }
}
