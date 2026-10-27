import 'package:erpflutter/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_service.dart';
import '../../models/customer_name_spinner_model.dart';
import '../../models/get_document_type_model.dart';
import '../../models/lineinformationlist_model.dart';
import '../../models/sales_executive_model.dart';
import 'add_lines.dart';

class SalesOrder extends StatefulWidget {
  const SalesOrder({super.key});

  static int docid = 0;
  static int slid = 0;

  @override
  State<SalesOrder> createState() => _SalesOrderState();
}

class _SalesOrderState extends State<SalesOrder> {
  String? selectedDocumentType;
  String? selectedCustomerName;
  String? selectedSalesExecutive;
  DateTime? selectedDueDate;
  String? poRefNumber;
  DateTime? poRefDate;
  
  List<Map<String, dynamic>> lineInformation = [];

  void _showSnackBar(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      // You can also use Toast.LENGTH_SHORT
      gravity: ToastGravity.BOTTOM,
      // Position of the toast
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build sales order----->');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        foregroundColor: Colors.white,
        title: Text("Add Sales Order",style: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        )),
        actions: [
          IconButton(
            onPressed: () async{
              // docid: SalesOrder.docid,
              // slid: SalesOrder.slid,
              // poRefNumber: poRefNumber ?? "",
              // dueDate: selectedDueDate != null
              // ? DateFormat('dd-MMMM-yyyy').format(selectedDueDate!)
              //     : "",
              // customerName: selectedCustomerName ?? "",
              // documentType: selectedDocumentType ?? "",
              // poRefDate: poRefDate != null
              // ? DateFormat('dd-MMMM-yyyy').format(poRefDate!)
              //     : "",
              // salesExecutive: selectedSalesExecutive ?? "",

              SharedPreferences prefs = await SharedPreferences.getInstance();
              int userid = int.parse(prefs.getString("USERID").toString()) ?? 0;

              int id = await DatabaseService().addSalesOrder(
                soID: 0,
                slID: SalesOrder.slid,
                SLDESC: ''!,
                strPORef: poRefNumber ?? "",
                strPORefDate: poRefDate != null
              ? DateFormat('dd-MMM-yyyy').format(poRefDate!)
                  : "",
                strSONO: '',
                strduedate: selectedDueDate != null
              ? DateFormat('dd-MMM-yyyy').format(selectedDueDate!)
                  : "",
                strCreatedBY: userid,
                strCreatedOn: DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now()),
                lastUpdatedDate: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
                flag: "I",
                docID: SalesOrder.docid,
                createdByName: selectedCustomerName ?? '',
                salesPerson: SalesOrder.docid.toString(),
              );

              if(id != null && id > 0){
                if(!lineInformation.isEmpty){
                  await DatabaseService().addLineInformation(lineInformation, id);
                }
              }

              Navigator.pop(context);
              Get.snackbar('', "Sales Order Added Successfully");
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     if (selectedDocumentType == null) {
      //       _showSnackBar("Please select Document Type");
      //       return; // Stop further checks
      //     }
      //
      //     if (selectedCustomerName == null) {
      //       _showSnackBar("Please select Customer Name");
      //       return; // Stop further checks
      //     }
      //
      //     if (selectedSalesExecutive == null) {
      //       _showSnackBar("Please select Sales Executive");
      //       return; // Stop further checks
      //     }
      //
      //     if (selectedDueDate == null) {
      //       _showSnackBar("Please select Due Date");
      //       return; // Stop further checks
      //     }
      //
      //     if (poRefNumber == null || poRefNumber!.isEmpty) {
      //       _showSnackBar("Please enter PO/Ref Number");
      //       return; // Stop further checks
      //     }
      //
      //     if (poRefDate == null) {
      //       _showSnackBar("Please select PO/Ref Date");
      //       return; // Stop further checks
      //     }
      //
      //     // If all fields are valid, navigate to the next screen
      //     Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) => AddLineScreen(
      //         docid: SalesOrder.docid,
      //         slid: SalesOrder.slid,
      //         poRefNumber: poRefNumber ?? "",
      //         dueDate: selectedDueDate != null
      //             ? DateFormat('dd-MMMM-yyyy').format(selectedDueDate!)
      //             : "",
      //         customerName: selectedCustomerName ?? "",
      //         documentType: selectedDocumentType ?? "",
      //         poRefDate: poRefDate != null
      //             ? DateFormat('dd-MMMM-yyyy').format(poRefDate!)
      //             : "",
      //         salesExecutive: selectedSalesExecutive ?? "",
      //       ),
      //     )).then((value) {
      //       if(value != null){
      //         setState(() {
      //           lineInformation.add(value);
      //         });
      //       }
      //     });
      //   },
      //   backgroundColor: Colors.blueAccent,
      //   child: Icon(
      //     Icons.add,
      //     size: 35,
      //     color: Colors.white,
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DocumentTypeDetails(
                title: "Document Type",
                dropdowntitle: "Sales Order",
                onValueSelected: (value) {
                  setState(() {
                    selectedDocumentType = value;
                  });
                },
              ),
              CustomerNameDetails(
                title: "Customer Name",
                dropdowntitle: "Select Customer Name",
                onValueSelected: (value) {
                  setState(() {
                    selectedCustomerName = value;
                  });
                },
              ),
              SalesExicutiveDetails(
                title: "Sales Executive",
                dropdowntitle: "Select Sales Executive",
                onValueSelected: (value) {
                  setState(() {
                    selectedSalesExecutive = value;
                  });
                },
              ),
              DueDateWidget(
                title: "Due Date",
                onDateSelected: (date) {
                  setState(() {
                    selectedDueDate = date;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              PoRefNumber(
                title: "PO/Ref Number",
                onValueChanged: (value) {
                  setState(() {
                    poRefNumber = value;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              PoRefDate(
                title: "PO/Ref Date",
                onDateSelected: (date) {
                  setState(() {
                    poRefDate = date;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Center(
                  child: Text(
                    "Line Information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              LineItemWidget(lineInformation, key: UniqueKey()),
            ],
          ),
        ),
      ),
    );
  }
}

// DocumentTypeDetails**********************************************************************************
class DocumentTypeDetails extends StatefulWidget {
  const DocumentTypeDetails(
      {super.key, this.title, this.dropdowntitle, this.onValueSelected});

  final String? title;
  final String? dropdowntitle;
  final Function(String)? onValueSelected;

  @override
  State<DocumentTypeDetails> createState() => _DocumentTypeDetails();
}

class _DocumentTypeDetails extends State<DocumentTypeDetails> {
  String? selectedValue;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  List<DocumentTypeModel> _data = [];
  final int _pageSize = 10;

  Future<void> _loadAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var orStructId = prefs.getString("ORGSTRUCTID");

    print('ORG struct ID ----> $orStructId');
    List<DocumentTypeModel> allData = await DatabaseService().getDocumentsType(
      strOrgstructId: orStructId!,
      // strOrgstructId: '4',
    );

    print('Data------------> ${allData.toString()}');

    setState(() {
      _isLoading = false;
      _data = allData; // Set all fetched data
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAllData(); // Initial data load
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toString(),
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                selectedValue == null
                    ? widget.dropdowntitle.toString()
                    : "$selectedValue",
                style: TextStyle(fontSize: 16),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              itemHeight: 48,
              items: _data.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item.dOCID.toString(),
                  child: Text(item.dOCDESC.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                  SalesOrder.slid = int.parse(selectedValue.toString());
                });
                if (widget.onValueSelected != null) {
                  widget.onValueSelected!(value!);
                }
              },
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

// DocumentTypeDetails**********************************************************************************
class CustomerNameDetails extends StatefulWidget {
  CustomerNameDetails({
    super.key,
    this.title,
    this.dropdowntitle,
    this.onValueSelected,
  });

  final String? title;
  final String? dropdowntitle;
  final Function(String)? onValueSelected;

  @override
  State<CustomerNameDetails> createState() => _CustomerNameDetails();
}

class _CustomerNameDetails extends State<CustomerNameDetails> {
  CustomerNameModel? selectedValue;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  List<CustomerNameModel> _data = [];
  final int _pageSize = 10;

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() => _isLoading = true);

    List<CustomerNameModel> newData = await DatabaseService().getCustomerNames(
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );

    setState(() {
      _isLoading = false;
      if (newData.length < _pageSize) {
        _hasMoreData = false; // No more data to fetch
      }
      _data.addAll(newData);
      _currentPage++;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMoreData(); // Initial data load
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toString(),
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<CustomerNameModel>(
              value: selectedValue,
              hint: Text(
                selectedValue == null
                    ? widget.dropdowntitle.toString()
                    : "$selectedValue",
                style: TextStyle(fontSize: 16),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              itemHeight: 48,
              items: _data.map<DropdownMenuItem<CustomerNameModel>>((item) {
                return DropdownMenuItem<CustomerNameModel>(
                  value: item,
                  child: Text(item.sLDESC.toString()),
                );
              }).toList()
                ..add(
                  DropdownMenuItem<CustomerNameModel>(
                    enabled: false,
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : _hasMoreData
                              ? TextButton(
                                  onPressed:
                                      _loadMoreData, // Directly call _loadMoreData
                                  child: Text(
                                    "Load More",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                )
                              : Text(
                                  "No more data",
                                  style: TextStyle(color: Colors.grey),
                                ),
                    ),
                  ),
                ),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;

                  SalesOrder.slid = int.parse(selectedValue!.sLID.toString());

                });
                if (widget.onValueSelected != null) {
                  widget.onValueSelected!(value!.sLDESC ?? '');
                }
              },
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

// SalesExicutiveDetails**********************************************************************************
class SalesExicutiveDetails extends StatefulWidget {
  const SalesExicutiveDetails(
      {super.key, this.title, this.dropdowntitle, this.onValueSelected});

  final String? title;
  final String? dropdowntitle;
  final Function(String)? onValueSelected;

  @override
  State<SalesExicutiveDetails> createState() => _SalesExicutiveDetails();
}

class _SalesExicutiveDetails extends State<SalesExicutiveDetails> {
  String? selectedValue;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  List<SalesExicutiveUserMast> _data = [];
  final int _pageSize = 10;

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() => _isLoading = true);

    List<SalesExicutiveUserMast> newData =
        await DatabaseService().getSalesExicutiveUserMast(
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );

    setState(() {
      _isLoading = false;
      if (newData.length < _pageSize) {
        _hasMoreData = false; // No more data to fetch
      }
      _data.addAll(newData);
      _currentPage++;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMoreData(); // Initial data load
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toString(),
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                selectedValue == null
                    ? widget.dropdowntitle.toString()
                    : "$selectedValue",
                style: TextStyle(fontSize: 16),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              itemHeight: 48,
              items: _data.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item.USERNAME.toString(),
                  child: Text(item.USERNAME.toString()),
                );
              }).toList()
                ..add(
                  DropdownMenuItem<String>(
                    enabled: false,
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : _hasMoreData
                              ? TextButton(
                                  onPressed: () {
                                    _loadMoreData(); // Fetch more data
                                  },
                                  child: Text(
                                    "Load More",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                )
                              : Text(
                                  "No more data",
                                  style: TextStyle(color: Colors.grey),
                                ),
                    ),
                  ),
                ),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
                if (widget.onValueSelected != null) {
                  widget.onValueSelected!(value!);
                }
              },
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

// DueDateWidget**********************************************************************************
class DueDateWidget extends StatefulWidget {
  const DueDateWidget({super.key, this.title, this.onDateSelected});

  final String? title;
  final Function(DateTime)? onDateSelected;

  @override
  State<DueDateWidget> createState() => _DueDateWidget();
}

class _DueDateWidget extends State<DueDateWidget> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(selectedDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toString(),
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? DateFormat('dd-MMMM-yyyy').format(selectedDate!)
                        : "Select Date",
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

// PoRefNumber**********************************************************************************
class PoRefNumber extends StatefulWidget {
  const PoRefNumber({super.key, this.title, this.onValueChanged});

  final String? title;
  final Function(String)? onValueChanged;

  @override
  State<PoRefNumber> createState() => _PoRefNumber();
}

class _PoRefNumber extends State<PoRefNumber> {
  String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toString(),
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
          TextField(
            autofocus: false,
            onChanged: (text) {
              setState(() {
                value = text;
              });
              if (widget.onValueChanged != null) {
                widget.onValueChanged!(value!);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter PO/Ref Number",
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

// PoRefDate**********************************************************************************
class PoRefDate extends StatefulWidget {
  const PoRefDate({super.key, this.title, this.onDateSelected});

  final String? title;
  final Function(DateTime)? onDateSelected;

  @override
  State<PoRefDate> createState() => _PoRefDate();
}

class _PoRefDate extends State<PoRefDate> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(selectedDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toString(),
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? DateFormat('dd-MMMM-yyyy').format(selectedDate!)
                        : "Select Date",
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

// LineInformation Data

class LineItemWidget extends StatefulWidget {
  List<Map<String, dynamic>> lineInformation;
  
  LineItemWidget(this.lineInformation, {super.key});
  
  @override
  _LineItemWidgetState createState() => _LineItemWidgetState(lineInformation);
}

class _LineItemWidgetState extends State<LineItemWidget> {
  List<Map<String, dynamic>> lineInformation;
  
  _LineItemWidgetState(this.lineInformation);
  
  late Future<List<LineInformationList>> _lineItemsFuture;

  @override
  void initState() {
    super.initState();
    _lineItemsFuture = _fetchLineItems();
  }
  
  bool isEdit = false;

  Future<List<LineInformationList>> _fetchLineItems() async {

    print('Added info 3-------------->');

    // try {
    if(isEdit){
      return await DatabaseService().getLineinfoList("0");
    } else {
      print('Added info 4-------------->');

      if (lineInformation.isNotEmpty) {
        print('Added info 5-------------->');

        return List.generate(lineInformation.length, (i) {
          return LineInformationList(
            itemId: lineInformation[i]['ITEMID'],
            itemDesc: lineInformation[i]['ITEMDESC'],
            delDate: lineInformation[i]['DELDATE'],
            qty: lineInformation[i]['QTY'],
            mrp: lineInformation[i]['MRP'],
            sotId: lineInformation[i]['SOTID'],
            unitRate: lineInformation[i]['UNITRATE'],
          );
        });
      }

      return [];
    }
    // } catch (e) {
    //   print("Error fetching line items: $e");
    //   return [];
    // }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LineInformationList>>(
      future: _lineItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("An error occurred while fetching data."),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text("No line items found."),
          );
        } else {
          return Column(
            children: snapshot.data!.map((item) {
              return Container(
                margin: EdgeInsets.only(bottom: 10), // Space between items
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: -1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.itemDesc ?? "No Description",
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteItem(item);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "QTY - ${item.qty ?? 'N/A'}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: 250,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "MRP - ${item.mrp?.toString() ?? 'N/A'}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.delDate != null
                                ? DateFormat('dd-MM-yyyy')
                                .format(item.delDate! as DateTime)
                                : "No Date",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  void _deleteItem(LineInformationList item) {
    print("Delete item: ${item.itemDesc}");
  }
}
