import 'package:erpflutter/database/database_service.dart';
import 'package:erpflutter/screens/skupricelist/pricedetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:intl/intl.dart';
import '../../Dashboard.dart';
import '../../models/priceList_Model.dart';

class SKUPriceList extends StatefulWidget {
  const SKUPriceList({super.key});

  @override
  State<SKUPriceList> createState() => _SKUPriceListState();
}

class _SKUPriceListState extends State<SKUPriceList> {
  bool _isSearching = false;
  String _searchQuery = '';
  int _currentPage = 0;
  final int _pageSize = 10; // Number of records per page
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<PriseListModel> _priceList = [];
  List<PriseListModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Load initial data
  }

  Future<void> _loadData() async {
    if (_isLoadingMore || !_hasMoreData) return; // Prevent multiple triggers
    setState(() {
      _isLoadingMore = true;
    });

    final data =
        await DatabaseService().getPaginatedPriseList(_currentPage, _pageSize);

    setState(() {
      _isLoadingMore = false;
      if (data.isEmpty) {
        _hasMoreData = false; // No more data to load
      } else {
        _currentPage++;
        _priceList.addAll(data); // Add new data to the existing list
      }
    });
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingMore = true;
    });

    final data = await DatabaseService().getPriseList(); // Fetch all data

    setState(() {
      _isLoadingMore = false;
      _searchResults = data;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchQuery = '';
    });
    _loadAllData(); // Fetch all data for search
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchResults.clear(); // Clear search results when search stops
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    var displayedData = _isSearching
        ? _searchResults.where((item) {
            final itemCode = item.itemCode?.toLowerCase() ?? '';
            final itemDesc = item.itemDesc?.toLowerCase() ?? "";
            final query = _searchQuery.toLowerCase();
            return itemCode.contains(query) || itemDesc.contains(query);
          }).toList()
        : _priceList;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white, // Border color when focused
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintStyle: TextStyle(color: Colors.white70),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                onChanged: _updateSearchQuery,
              )
            : Text("Price List"),
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back),
          onPressed: () {
                  _stopSearch();

            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Dashboard(),
            ));
          },
              )
            : null,
        actions: [
          !_isSearching
              ? IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _startSearch,
                )
              : SizedBox(),
        ],
      ),
      body: displayedData.isEmpty && _isSearching && _searchQuery.isNotEmpty
          ? const Center(
              child: Text(
              "No Data Found",
              style: TextStyle(fontWeight: FontWeight.bold),
            ))
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isSearching &&
                    !_isLoadingMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _loadData(); // Load more data when reaching the bottom
                }
                return false;
              },
              child: ListView.builder(
                itemCount: displayedData.length +
                    (_hasMoreData && !_isSearching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == displayedData.length &&
                      _hasMoreData &&
                      !_isSearching) {
                    return Center(
                      child:
                          CircularProgressIndicator(), // Show loading indicator at the end
                    );
                  }

                  var getData = displayedData[index];

               String itemDescriptionFirstLetter=    getData.itemDesc!=null && getData.itemDesc.isNotEmpty ? getData.itemDesc[0].toUpperCase() : "";

                  return ProductCard(
                    wef: getData.wef,
                    itemCode: getData.itemCode,
                    itemDesc: getData.itemDesc,
                    unitRate: getData.unitRate,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PriceDetails(
                            unitRate: getData.unitRate,
                            itemCode: getData.itemCode,
                            itemDesc: getData.itemDesc,
                            wef: itemDescriptionFirstLetter,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  ProductCard({
    super.key,
    this.pid,
    this.itemId,
    this.itemCode,
    this.itemDesc,
    this.wef,
    this.unitRate,
    this.onTap,
  });

  final int? pid;
  final int? itemId;
  final String? itemCode;
  final String? itemDesc;
  final String? wef;
  final double? unitRate;
  Callback? onTap;

  String get formattedDate {
    try {
      final date = DateFormat('dd-MMM-yyyy')
          .parse(wef ?? ''); // Parse the original date format
      return DateFormat('dd MMM').format(date); // Desired date format
    } catch (e) {
      return 'Invalid Date'; // Handle parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
                  child: Text(formattedDate,
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  // Wrap the Column with Expanded

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        itemCode.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
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
                        "₹ ${unitRate?.toStringAsFixed(2) ?? '0.00'}",

                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis to prevent overflow
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
