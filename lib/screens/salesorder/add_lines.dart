// import 'package:erpflutter/models/getproductcode_model.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../database/database_service.dart';
//
// class AddLineScreen extends StatefulWidget {
//   AddLineScreen({
//     super.key,
//     required this.documentType,
//     required this.customerName,
//     required this.salesExecutive,
//     required this.dueDate,
//     required this.poRefNumber,
//     required this.poRefDate,
//     required this.slid,
//     required this.docid,
//
//   });
//
//   final String documentType;
//   final String customerName;
//   final String salesExecutive;
//   final String dueDate;
//   final String poRefNumber;
//   final String poRefDate;
//   final int slid;
//   final int docid;
//
//
//   @override
//   State<AddLineScreen> createState() => _AddLineScreenState();
// }
//
// class _AddLineScreenState extends State<AddLineScreen> {
//   // Define separate variables for the selected values
//   String? selectedProductCode;
//   String? selectedProductDescription;
//   String? selectedQuantity;
//   String? selectedUnitRate;
//   String? selectedAmount;
//   DateTime? deliveryDate;
//
//   Map<String, dynamic>? line;
//
//   void _showSnackBar(String message) {
//     Fluttertoast.cancel();
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       // You can also use Toast.LENGTH_SHORT
//       gravity: ToastGravity.BOTTOM,
//       // Position of the toast
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
//
//   void _showAddedSnackbar(String message) {
//     Fluttertoast.cancel();
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       // You can also use Toast.LENGTH_SHORT
//       gravity: ToastGravity.BOTTOM,
//       // Position of the toast
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: Text('Add Line'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.check),
//             onPressed: () async {
//               if (selectedProductCode == null || selectedProductCode!.isEmpty) {
//                 _showSnackBar("Please select product code");
//                 return;
//               } else if (selectedProductDescription == null ||
//                   selectedProductDescription!.isEmpty) {
//                 _showSnackBar("Please enter product description");
//                 return;
//               } else if (selectedQuantity == null ||
//                   selectedQuantity!.isEmpty) {
//                 _showSnackBar("Please enter quantity");
//                 return;
//               } else if (selectedUnitRate == null ||
//                   selectedUnitRate!.isEmpty) {
//                 _showSnackBar("Please enter unit rate");
//                 return;
//               } else if (selectedAmount == null || selectedAmount!.isEmpty) {
//                 _showSnackBar("Please enter amount");
//                 return;
//               } else if (deliveryDate == null) {
//                 _showSnackBar("Please Select Delivery Date");
//                 return;
//               }
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               int? usrid=int.parse(prefs.getString("USERID").toString());
//               String currentDateTime = DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now());
//
//               line = {
//                 'ITEMID' : selectedProductCode,
//                     'ITEMDESC' : selectedProductDescription,
//                     'DELDATE' : deliveryDate,
//                     'QTY' : selectedQuantity,
//                     'MRP' : selectedAmount,
//                     'SOTID' : '0',
//                     'UNITRATE' : selectedUnitRate
//
//                 // 'SOID': 0,
//                 // 'SLID': widget.slid,
//                 // 'SLDESC': selectedProductDescription!,
//                 // 'POREFNO': widget.poRefNumber,
//                 // 'POREFDATE': widget.poRefDate,
//                 // 'SONO': currentDateTime,
//                 // 'DUEDATE': widget.dueDate,
//                 // 'CREATEDBY': usrid!,
//                 // 'FLAG': deliveryDate.toString(),
//                 // 'LASTUPDATEDDATE': deliveryDate.toString(),
//                 // 'DOCID': "I",
//                 // 'SALESPERSON': widget.docid
//               };
//
//               print('Added info 2-------------->');
//
//               Navigator.pop(context, line);
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.close),
//             onPressed: () {
//               // Add cancel functionality
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.home),
//             onPressed: () {
//               // Add home functionality
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SelectProductCode(
//               title: "Product Code",
//               dropdowntitle: "Select Product Code",
//               onSelected: (value) {
//                 selectedProductCode = value;
//               },
//             ),
//             Divider(
//               color: Colors.grey,
//               height: 0,
//             ),
//             SizedBox(height: 15),
//
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Product Description',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 TextFormField(
//                   autofocus: false,
//                   decoration: InputDecoration(
//                     hintText: 'Enter Product Description',
//                     border: InputBorder.none,
//                     isDense: true,
//                     contentPadding: EdgeInsets.symmetric(vertical: 8.0),
//                   ),
//                   onChanged: (value) {
//                     selectedProductDescription = value;
//                   },
//                 ),
//                 Divider(color: Colors.grey),
//               ],
//             ),
//             buildNumericTextFieldWithLabel(
//               'Quantity',
//               'Enter Quantity',
//               (value) {
//                 selectedQuantity = value;
//               },
//             ),
//             buildNumericTextFieldWithLabel(
//               'Unit Rate',
//               'Enter Unit Rate',
//               (value) {
//                 selectedUnitRate = value;
//               },
//             ),
//             buildNumericTextFieldWithLabel(
//               'Amount',
//               'Enter Amount',
//               (value) {
//                 selectedAmount = value;
//               },
//             ),
//             SizedBox(height: 15),
//             DeliveryDate(
//               title: "Delivery Date",
//               onDateSelected: (value) {
//                 setState(() {
//                   deliveryDate = value;
//                 });
//               },
//             ),
//             Divider(
//               color: Colors.grey,
//               height: 0,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Validation method
//
//   // Modified buildTextFieldWithLabel to accept onChanged callback
//   Widget buildNumericTextFieldWithLabel(
//       String label, String hint, Function(String) onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.blue,
//           ),
//         ),
//         TextFormField(
//           autofocus: false,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: InputBorder.none,
//             isDense: true,
//             contentPadding: EdgeInsets.symmetric(vertical: 8.0),
//           ),
//           onChanged: onChanged,
//         ),
//         Divider(color: Colors.grey),
//       ],
//     );
//   }
// }
//
// // Modify SelectProductCode widget to accept a callback for selected value
// class SelectProductCode extends StatefulWidget {
//   const SelectProductCode({
//     super.key,
//     this.title,
//     this.dropdowntitle,
//     required this.onSelected,
//   });
//
//   final String? title;
//   final String? dropdowntitle;
//   final Function(String) onSelected;
//
//   @override
//   State<SelectProductCode> createState() => _SelectProductCode();
// }
//
// class _SelectProductCode extends State<SelectProductCode> {
//   String? selectedValue;
//   int _currentPage = 0;
//   bool _isLoading = false;
//   bool _hasMoreData = true;
//   List<ProductCodeSpinnerModel> _data = [];
//   final int _pageSize = 10;
//
//   Future<void> _loadMoreData() async {
//     if (_isLoading || !_hasMoreData) return;
//
//     setState(() => _isLoading = true);
//
//     List<ProductCodeSpinnerModel> newData =
//         await DatabaseService().getProductCode();
//
//     setState(() {
//       _isLoading = false;
//       if (newData.length < _pageSize) {
//         _hasMoreData = false; // No more data to fetch
//       }
//       _data.addAll(newData);
//       _currentPage++;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadMoreData(); // Initial data load
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.title.toString(),
//             style: TextStyle(
//               color: Colors.blueAccent,
//               fontSize: 16,
//             ),
//           ),
//           DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: selectedValue,
//               hint: Text(
//                 selectedValue == null
//                     ? widget.dropdowntitle.toString()
//                     : "$selectedValue",
//                 style: TextStyle(fontSize: 16),
//               ),
//               isExpanded: true,
//               icon: Icon(Icons.arrow_drop_down, color: Colors.black),
//               itemHeight: 48,
//               items: _data.map<DropdownMenuItem<String>>((item) {
//                 return DropdownMenuItem<String>(
//                   value: item.itemCode.toString(),
//                   child: Text(item.itemCode.toString()),
//                 );
//               }).toList()
//                 ..add(
//                   DropdownMenuItem<String>(
//                     enabled: false,
//                     child: Center(
//                       child: _isLoading
//                           ? CircularProgressIndicator()
//                           : _hasMoreData
//                               ? TextButton(
//                                   onPressed: () {
//                                     _loadMoreData(); // Fetch more data
//                                   },
//                                   child: Text(
//                                     "Load More",
//                                     style: TextStyle(color: Colors.blue),
//                                   ),
//                                 )
//                               : Text(
//                                   "No more data",
//                                   style: TextStyle(color: Colors.grey),
//                                 ),
//                     ),
//                   ),
//                 ),
//               onChanged: (value) {
//                 setState(() {
//                   selectedValue = value;
//                   widget
//                       .onSelected(value!); // Pass selected value back to parent
//                 });
//               },
//             ),
//           ),
//           SizedBox(height: 15),
//         ],
//       ),
//     );
//   }
// }
//
// class DeliveryDate extends StatefulWidget {
//   const DeliveryDate({super.key, this.title, this.onDateSelected});
//
//   final String? title;
//   final Function(DateTime)? onDateSelected;
//
//   @override
//   State<DeliveryDate> createState() => _PoRefDate();
// }
//
// class _PoRefDate extends State<DeliveryDate> {
//   DateTime? selectedDate;
//
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime initialDate = DateTime.now();
//     DateTime firstDate = DateTime(2000);
//     DateTime lastDate = DateTime(2101);
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );
//
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//       if (widget.onDateSelected != null) {
//         widget.onDateSelected!(selectedDate!);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.title.toString(),
//             style: TextStyle(
//               color: Colors.blueAccent,
//               fontSize: 16,
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _selectDate(context),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     selectedDate != null
//                         ? DateFormat('dd-MMMM-yyyy').format(selectedDate!)
//                         : "Select Date",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Icon(Icons.calendar_today),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 15),
//         ],
//       ),
//     );
//   }
// }
