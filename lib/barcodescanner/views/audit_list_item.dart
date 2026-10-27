import 'package:erpflutter/barcodescanner/models/audit_response_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/themecontroller.dart';


class BarcodeListItem extends StatelessWidget {
  final Transaction item;
  final LotDetail? lotDetail;// Pass Transaction object
  late ThemeController themeController;

   BarcodeListItem({super.key, required this.item, required this.lotDetail});

  Widget _buildRow(BuildContext context,String label, String value) {
    themeController = Provider.of<ThemeController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style:  TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: themeController.primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeController themeController =  Provider.of<ThemeController>(context, listen: false);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            child: Padding(
              padding:  EdgeInsets.all(0),
              child: Container(width: 5,  decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: themeController.primaryColor,
                    width: 4,
                  ),
                ),
              ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(context,"Item Type:", item.itemType?.toString() ?? ""),
                  _buildRow(context,"Item Group:", item.itemGroup?.toString() ?? ""),
                  _buildRow(context,"Item Code:", item.itemCode?.toString() ?? ""),
                  _buildRow(context,"Desc:", item.itemDesc?.toString() ?? ""),
                  _buildRow(context,"Quantity:", item.qty?.toString() ?? ""),
                  _buildRow(context,"Rack & Bin:", item.rackDescription?.toString() ?? ""),
                  _buildRow(context,"GRN No:", lotDetail?.grnNo?.toString() ?? ""),
                  _buildRow(context,"Proj No:", item.jobNo?.toString() ?? ""),
                  _buildRow(context,"SO No:", lotDetail?.soNo?.toString() ?? ""),
                  _buildRow(context,"PO No:", lotDetail?.poNo?.toString() ?? ""),
                  _buildRow(context,"Supplier:", lotDetail?.supplier?.toString() ?? ""),
                  _buildRow(context,"Customer:", lotDetail?.customer?.toString() ?? ""),
                  _buildRow(context,"Closing Balance:", item.totalStock?.toString() ?? ""),
                  // Add more fields if needed
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
