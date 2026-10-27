// ignore_for_file: avoid_print


import 'package:erpflutter/barcodescanner/views/asn_qrcode.dart';
import 'package:erpflutter/barcodescanner/views/asn_scanning.dart';
import 'package:erpflutter/provider/barcode_provider.dart';
import 'package:erpflutter/repository/invoiceDetailsRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';


class InvoiceDetailedScreennew extends StatefulWidget {
  InvoiceDetailedScreennew({
    super.key,
    required this.documentType,
    required this.documentNo,
    required this.documentDate,
    required this.mid,
    required this.docid,
    required this.flag,
    required this.slid,
    required this.projid,
    // required this.tid,
    required this.orgid,
    required this.title,

    // required Barcode result,
  });
  final String documentType;
  final String documentNo;
  final String documentDate;
  final String mid;
  final String docid;
  final String flag;
  final String slid;
  final String projid;
  // final String tid;
  final String orgid;
  final String title;
  @override
  State<InvoiceDetailedScreennew> createState() => _InvoiceDetailedScreenState();
}

class _InvoiceDetailedScreenState extends State<InvoiceDetailedScreennew> {
  var getinvoiceData = InvoiceDetailsRequest();

  @override
  void initState() {
    super.initState();
    // getinvoiceData.getInvoiceDetails(
    //     widget.mid,
    //     widget.docid,
    //     widget.flag,
    //     widget.slid,
    //     widget.orgid,
    //     // widget.tid,
    //     widget.projid);
    print('---------');
    print('Document Type: ${widget.documentType}');
    print('Document No: ${widget.documentNo}');
    print('Document Date: ${widget.documentDate}');
    print('Mobile ID: ${widget.mid}');
    print('Document ID: ${widget.docid}');
    print('Flag: ${widget.flag}');
    print('Slip ID: ${widget.slid}');
    print('project ID : ${widget.projid}');
    // print('T ID : ${widget.tid}');
    print('Organization ID: ${widget.orgid}');
    print('---------');
    invoiceDetailsApi();

    // WidgetsFlutterBinding.ensureInitialized();
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // @override
  // void dispose() {
  //   // Allow any orientation when leaving DetailsScreen
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //   super.dispose();
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   getinvoiceData = InvoiceDetailsRequest();
  // }

  invoiceDetailsApi() async {
    final response = await Provider.of<BarcodeProviderAns>(context, listen: false)
        .InvoiceDetailsProvider(widget.mid, widget.docid, widget.flag,
        widget.slid, widget.orgid, widget.projid);

    print(response);
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    print("title is : -------------------------------");
    print(widget.title);
    print("orgid is : -------------------------------");
    print(widget.orgid);
    print("flag is : -------------------------------");
    print(widget.flag);
    print("mid is : -------------------------------");
    print(widget.mid);
    print("docid is : -------------------------------");
    print(widget.docid);
    // print("t ID is : -------------------------------");
    // print(widget.tid);
    final setHeight = MediaQuery.of(context).size.height;
    final setWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Use default back icon
          onPressed: () {
            // Navigator.of(context).pop();
            // Navigator.pop(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => InvoiceScreen(
            //             orgID15: widget.orgid,
            //             invoiceFlag: widget.flag,
            //             title: widget.title,
            //             mId: '',
            //             docId: '')));
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => ASNScanningScreen(
                    )),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor:
        Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove elevation
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${widget.title.replaceAll(" ", '')} #${widget.documentType}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.bold),
          ),
        ),
        titleSpacing: -10,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(204, 70, 73, 231), // Start color
                Color.fromARGB(214, 155, 39, 176), // End color
              ],
            ),
          ),
        ),
      ),
      // appBar: AppBar(
      //   iconTheme: const IconThemeData(
      //     color: Color.fromARGB(255, 255, 255, 255),
      //   ),
      //   backgroundColor: Colors.blue,
      //   title: Align(
      //     alignment: Alignment.centerLeft,
      //     child: Text(
      //       '${widget.title.replaceAll(" ", '')} #${widget.documentType}',
      //       style: const TextStyle(
      //           color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back), // Use default back icon
      //     onPressed: () {
      //       // Navigator.of(context).pop();
      //       // Navigator.pop(
      //       //     context,
      //       //     MaterialPageRoute(
      //       //         builder: (context) => InvoiceScreen(
      //       //             orgID15: widget.orgid,
      //       //             invoiceFlag: widget.flag,
      //       //             title: widget.title,
      //       //             mId: '',
      //       //             docId: '')));
      //       Navigator.of(context).pushReplacement(
      //         MaterialPageRoute(
      //             builder: (context) => InvoiceScreen(
      //                 orgID15: widget.orgid,
      //                 invoiceFlag: widget.flag,
      //                 title: widget.title,
      //                 mId: '',
      //                 docId: '')),
      //       );
      //     },
      //   ),
      // ),
      body: Column(
        children: [
          // TextFeilds Section....

          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    height: setHeight * 0.07,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.padding_outlined,
                          size: 25,
                        ),
                        Text(widget.documentNo,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                      height: setHeight * 0.07,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.date_range_rounded,
                            size: 25,
                          ),
                          Text(
                            widget.documentDate,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),

          SizedBox(
            height: setHeight * 0.01,
          ),

          Table(
            border: TableBorder.all(
                color: const Color.fromARGB(255, 218, 218, 218)),
            columnWidths: {
              0: FixedColumnWidth(
                setWidth * 0.14,
              ),
              2: FixedColumnWidth(
                setWidth * 0.1,
              ),
              // 3: FixedColumnWidth(
              //   setWidth * 0.1,
              // ),
              3: (widget.flag == "11")
                  ? FixedColumnWidth(
                setWidth * 0.1,
              )
                  : const IntrinsicColumnWidth(),
              4: (widget.flag == "11")
                  ? FixedColumnWidth(
                setWidth * 0.1,
              )
                  : const IntrinsicColumnWidth(),
              5: FixedColumnWidth(
                setWidth * 0.1,
              ),
            },
            children: [
              // Table Heading***********
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFF00D09F),
                ),
                children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Item Code",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // const TableCell(
                  //   child: Padding(
                  //     padding: EdgeInsets.all(8.0),
                  //     child: Text(
                  //       "UOM",
                  //       style: TextStyle(
                  //         color: Colors.black87,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Quantity",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  (widget.flag == "11")
                      ? const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Dispatched",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(),
                  (widget.flag == "11")
                      ? const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Balance",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(),
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Scanned",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: getinvoiceData.getInvoiceDetails(
                  widget.mid,
                  widget.docid,
                  "14",
                  widget.slid,
                  widget.orgid,
                  // widget.tid,
                  widget.projid),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: SpinKitCubeGrid(
                        size: 40,
                        color: Color.fromARGB(255, 209, 207, 207),
                      ));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.tRANSACTIONDETAILS!.status ==
                    "false") {
                  return const Expanded(
                    child: Center(
                      child: Text(
                        "No Record Found",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount:
                    snapshot.data!.tRANSACTIONDETAILS!.tRANSACTIONS!.length,
                    itemBuilder: (context, index) {
                      Color backgroundColor = index % 2 == 0
                          ? const Color.fromARGB(255, 226, 226, 226)
                          : const Color.fromARGB(255, 207, 207, 207);

                      return InkWell(
                        // InkWell(onTap: () {
                        // Future.delayed(Duration(milliseconds: 800), () {
                        //   setState(() {
                        //     SystemChrome.setPreferredOrientations([
                        //       DeviceOrientation.portraitUp
                        //       // DeviceOrientation.landscapeLeft,
                        //       // DeviceOrientation.landscapeRight,
                        //     ]);
                        //   });
                        // });

                        /*  (Provider.of<BarcodeProvider>(context, listen: false).scannedStatus == "0") ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QRViewExample(
                                mId: widget.mid,
                                dId: widget.docid,
                                itemId: snapshot.data!.tRANSACTIONDETAILS!
                                    .tRANSACTIONS![index].iTEMID!,
                                itemCode: snapshot.data!.tRANSACTIONDETAILS!
                                    .tRANSACTIONS![index].productCode!,
                                tId: snapshot.data!.tRANSACTIONDETAILS!
                                    .tRANSACTIONS![index].tID!,
                                // avlQty: snapshot.data!.tRANSACTIONDETAILS!
                                //     .tRANSACTIONS![index].balance!
                                //     .toString(),
                                planQty: snapshot.data!.tRANSACTIONDETAILS!
                                    .tRANSACTIONS![index].quantity!,
                                scanqty: snapshot.data!.tRANSACTIONDETAILS!
                                    .tRANSACTIONS![index].scanned!,
                                balanceQty: (widget.flag == "11")
                                    ? snapshot.data!.tRANSACTIONDETAILS!
                                        .tRANSACTIONS![index].balance!
                                    : '',
                                flag: widget.flag,
                                orgID: widget.orgid,
                                slid: (widget.flag == "11") ? widget.slid : '',
                                projId:
                                    (widget.flag == "11") ? widget.projid : '',
                                doctype: widget.documentType,
                                docno: widget.documentNo,
                                docdate: widget.documentDate,
                                title: widget.title),
                          ),
                        ) : SizedBox()
                      },  */
                          onTap: () {
                            if (Provider.of<BarcodeProviderAns>(context, listen: false)
                                .scannedquantity!
                                .tRANSACTIONDETAILS!
                                .tRANSACTIONS![index]
                                .scanStatus ==
                                "0") {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => QRViewExampleans(
                                      mId: widget.mid,
                                      dId: widget.docid,
                                      itemId: snapshot.data!.tRANSACTIONDETAILS!
                                          .tRANSACTIONS![index].iTEMID!,
                                      itemCode: snapshot.data!.tRANSACTIONDETAILS!
                                          .tRANSACTIONS![index].productCode!,
                                      tId: snapshot.data!.tRANSACTIONDETAILS!
                                          .tRANSACTIONS![index].tID!,
                                      planQty: snapshot.data!.tRANSACTIONDETAILS!
                                          .tRANSACTIONS![index].quantity!,
                                      scanqty: snapshot.data!.tRANSACTIONDETAILS!
                                          .tRANSACTIONS![index].scanned!,
                                      balanceQty: (widget.flag == "11")
                                          ? snapshot.data!.tRANSACTIONDETAILS!
                                          .tRANSACTIONS![index].balance!
                                          : '',
                                      flag: widget.flag,
                                      orgID: widget.orgid,
                                      slid: /*   (widget.flag == "11") ? */
                                      widget.slid /* : '' */,
                                      projId: /*  (widget.flag == "11")
                                      ? */
                                      widget.projid /* : '' */,
                                      doctype: widget.documentType,
                                      docno: widget.documentNo,
                                      docdate: widget.documentDate,
                                      title: widget.title,
                                      index: index),
                                ),
                              );
                            }
                          }, child: Consumer<BarcodeProviderAns>(
                          builder: (context, value, child) {
                            return Table(
                              border: TableBorder.all(
                                  color: const Color.fromARGB(255, 218, 218, 218)),
                              columnWidths: {
                                0: FixedColumnWidth(
                                  setWidth * 0.14,
                                ),
                                2: FixedColumnWidth(
                                  setWidth * 0.1,
                                ),
                                // 3: FixedColumnWidth(
                                //   setWidth * 0.1,
                                // ),
                                3: (widget.flag == "11")
                                    ? FixedColumnWidth(
                                  setWidth * 0.1,
                                )
                                    : const IntrinsicColumnWidth(),
                                4: (widget.flag == "11")
                                    ? FixedColumnWidth(
                                  setWidth * 0.1,
                                )
                                    : const IntrinsicColumnWidth(),
                                5: FixedColumnWidth(
                                  setWidth * 0.1,
                                ),
                              },
                              children: [
                                // Table Dataaaaa
                                TableRow(
                                  decoration: BoxDecoration(color: backgroundColor),
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot.data!.tRANSACTIONDETAILS!
                                              .tRANSACTIONS![index].productCode
                                              .toString(),
                                          style: const TextStyle(
                                            color: Color(0xFF00D09F),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot
                                              .data!
                                              .tRANSACTIONDETAILS!
                                              .tRANSACTIONS![index]
                                              .productDescription
                                              .toString(),
                                          style: const TextStyle(
                                            color: Color.fromARGB(221, 78, 78, 78),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // TableCell(
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: Text(
                                    //       snapshot.data!.tRANSACTIONDETAILS!
                                    //           .tRANSACTIONS![index].uOM
                                    //           .toString(),
                                    //       style: const TextStyle(
                                    //         color: Color.fromARGB(221, 78, 78, 78),
                                    //         fontWeight: FontWeight.bold,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              snapshot.data!.tRANSACTIONDETAILS!
                                                  .tRANSACTIONS![index].quantity
                                                  .toString(),
                                              style: const TextStyle(
                                                color:
                                                Color.fromARGB(221, 78, 78, 78),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    ),
                                    (widget.flag == "11")
                                        ? TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              snapshot
                                                  .data!
                                                  .tRANSACTIONDETAILS!
                                                  .tRANSACTIONS![index]
                                                  .dispatched
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    221, 78, 78, 78),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    )
                                        : const SizedBox(),
                                    (widget.flag == "11")
                                        ? TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              snapshot
                                                  .data!
                                                  .tRANSACTIONDETAILS!
                                                  .tRANSACTIONS![index]
                                                  .balance
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    221, 78, 78, 78),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    )
                                        : const SizedBox(),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8, left: 5, right: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: [
                                            Center(
                                              child: (value.isLoading)
                                                  ? const SpinKitThreeBounce(
                                                size: 15,
                                                color: Color.fromARGB(
                                                    255, 224, 222, 222),
                                              )
                                                  : Text(
                                                value
                                                    .scannedquantity!
                                                    .tRANSACTIONDETAILS!
                                                    .tRANSACTIONS![index]
                                                    .scanned
                                                    .toString(),
                                                /*  snapshot
                                                      .data!
                                                      .tRANSACTIONDETAILS!
                                                      .tRANSACTIONS![index]
                                                      .scanned
                                                      .toString(), */
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      221, 78, 78, 78),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            (value
                                                .scannedquantity!
                                                .tRANSACTIONDETAILS!
                                                .tRANSACTIONS![index]
                                                .scanStatus ==
                                                "1")
                                                ? const CircleAvatar(
                                              radius: 8,
                                              backgroundColor: Colors.black,
                                              child: Icon(
                                                Icons.check,
                                                size: 13.5,
                                                color: Colors.white,
                                              ),
                                            )
                                                : const SizedBox(
                                              height: 0,
                                              width: 0,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          }));
                    },
                  );
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => ASNScanningScreen(
                         )),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(228, 70, 73, 231),
                ),
                width: setWidth,
                child: const Center(
                  child: Text(
                    "Save & Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

