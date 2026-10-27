import 'package:erpflutter/models/bussiness_partners_list_model.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_service.dart';
import '../../utils/SizeConfig.dart';

class SupplierController with ChangeNotifier {
  bool isLoading = true;
  DatabaseService _databaseService = DatabaseService();
  int numberOfPostsPerRequest = 10;
  String searchValue = '';

  PagingController<int, BusinessPartnersListModel> pagingController =
  PagingController(firstPageKey: 0);
  bool checkedValue = false;
  String searchflag = "0";
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  double? screenWidth;
  double? screenHeight;
  int i = 1;
  int callValue = 0;
  double? blockSizeHorizontal;
  List<BusinessPartnersListModel>? getSuppliersList = [];
  SharedPreferences? prefs;

  SupplierController() {
    searchValue = "";
    callValue = 0;
    getSuppliersList!.clear();
    searchflag = "0";
    pagingController.refresh();

    // Initialize the page request listener
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey, 'CUSTOMER');
    });
  }

  Future<void> fetchPage(int pageKey, String strModulename) async {
    getSuppliersList!.clear();
    List<BusinessPartnersListModel>? postList = [];
    try {
      if (searchflag == '1') {
        if (searchValue.length >= 2) {
          getSuppliersList = await _databaseService.getBusinessPartnersSearchList(strModulename, searchValue);
        }
      } else {
        final stopwatch = Stopwatch()..start();
        getSuppliersList = await _databaseService.getBusinessPartnersPaginateList(strModulename, pageKey);
        stopwatch.stop();
        print('Function Execution Time : ${stopwatch.elapsed}');
      }

      postList.clear();
      postList.addAll(getSuppliersList!);

      final isLastPage = postList!.length < numberOfPostsPerRequest;
      if (isLastPage) {
        pagingController.appendLastPage(postList);
      } else {
        final nextPageKey = pageKey + postList.length;
        pagingController.appendPage(postList, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }
}
