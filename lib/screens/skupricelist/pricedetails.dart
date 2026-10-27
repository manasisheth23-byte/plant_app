import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:intl/intl.dart';

class PriceDetails extends StatefulWidget {
  const PriceDetails({
    super.key,
    this.itemCode,
    this.itemDesc,
    this.unitRate,
    this.wef,
  });

  final String? itemCode;
  final String? itemDesc;
  final double? unitRate;
  final String? wef;

  @override
  State<PriceDetails> createState() => _PriceDetailsState();
}

class _PriceDetailsState extends State<PriceDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Price Details",
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: ProductCard(
        wef: widget.wef,
        itemCode: widget.itemCode,
        itemDesc: widget.itemDesc,
        unitRate: widget.unitRate,

      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  ProductCard({
    super.key,
    // this.pid,
    // this.itemId,
    this.itemCode,
    this.itemDesc,
    this.wef,
    this.unitRate,
    // this.onTap,
    this.maingroup,
    this.plant,
    this.instockquantity,
  });

  // final int? pid;
  // final int? itemId;
  final String? itemCode;
  final String? itemDesc;
  final String? wef;
  final double? unitRate;

  // Callback? onTap;
  final String? maingroup;
  final String? plant;
  final String? instockquantity;

  // String get formattedDate {
  //   try {
  //     final date = DateFormat('dd-MMM-yyyy')
  //         .parse(wef ?? ''); // Parse the original date format
  //     return DateFormat('dd MMM').format(date); // Desired date format
  //   } catch (e) {
  //     return 'Invalid Date'; // Handle parsing errors
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.all(10.0),
          elevation: 5,
          child: SizedBox(
            height: 125,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      wef.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    // Wrap the Column with Expanded

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          itemDesc.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          itemCode.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25,
            horizontal: 25,
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Plant",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(plant ?? ""),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Unit Price",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("₹ ${unitRate?.toStringAsFixed(2) ?? '0.00'}"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "In Stock Quantity",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(instockquantity ?? ""),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Main Group",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(maingroup ?? ""),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
