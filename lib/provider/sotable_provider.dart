import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart';
import '../models/so_table_model.dart';
import '../models/sotable_dropdown_nodel.dart';
import '../services/so_table_service.dart';
import '../services/sotable_dropdown.dart';

class SoReportProvider with ChangeNotifier {
  List<Data> _soData = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;


  List<Data> get soData => _soData;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  SoTableDropdownModel? _dropdownData;
  SoTableDropdownModel? get dropdownData => _dropdownData;

  bool _isLoadingDropdown = false;
  bool get isLoadingDropdown => _isLoadingDropdown;

  // Selected values with default values for initial state
  String? selectedExWorkColor;
  String? selectedCddColor;
  String? selectedCustomer;
  String? selectedFgCode;
  String? selectedSoNo;
  String? selectedProject;
  String? selectedItemSubgroup;
  String? selectedAlert;
  String? selectplant = '4'; // Default plant ID as '4'
  Map<String, dynamic> _initialFilterState = {};

  void storeInitialFilterState() {
    _initialFilterState = {
      'plant': selectplant,
      'exWorkColor': selectedExWorkColor,
      'cddColor': selectedCddColor,
      'customer': selectedCustomer,
      'fgCode': selectedFgCode,
      'soNo': selectedSoNo,
      'project': selectedProject,
      'itemSubgroup': selectedItemSubgroup,
      'alert': selectedAlert,
    };
  }

  bool get hasFiltersChanged {
    return _initialFilterState['plant'] != selectplant ||
        _initialFilterState['exWorkColor'] != selectedExWorkColor ||
        _initialFilterState['cddColor'] != selectedCddColor ||
        _initialFilterState['customer'] != selectedCustomer ||
        _initialFilterState['fgCode'] != selectedFgCode ||
        _initialFilterState['soNo'] != selectedSoNo ||
        _initialFilterState['project'] != selectedProject ||
        _initialFilterState['itemSubgroup'] != selectedItemSubgroup ||
        _initialFilterState['alert'] != selectedAlert;
  }

  void resetToInitial(BuildContext context) {
    selectplant = _initialFilterState['plant'];
    selectedExWorkColor = _initialFilterState['exWorkColor'];
    selectedCddColor = _initialFilterState['cddColor'];
    selectedCustomer = _initialFilterState['customer'];
    selectedFgCode = _initialFilterState['fgCode'];
    selectedSoNo = _initialFilterState['soNo'];
    selectedProject = _initialFilterState['project'];
    selectedItemSubgroup = _initialFilterState['itemSubgroup'];
    selectedAlert = _initialFilterState['alert'];

    _currentPage = 1;
    soData.clear();
    fetchSoData(context);
    notifyListeners();
  }

  void resetToDefaults(BuildContext context) {
    selectplant = '4';
    selectedExWorkColor = null;
    selectedCddColor = null;
    selectedCustomer = null;
    selectedFgCode = null;
    selectedSoNo = null;
    selectedProject = null;
    selectedItemSubgroup = null;
    selectedAlert = null;

    _currentPage = 1;
    soData.clear();
    fetchSoData(context);
    notifyListeners();
  }



  Future<void> fetchSoData1( {bool loadMore = false, bool applyFilter = false}) async {
    if (loadMore) {
      if (!_hasMoreData || _isLoadingMore) return;
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final response = await SoReportService.fetchSoData1(

          pageNo: _currentPage,
          applyFilter: applyFilter,
          filterParams: {
            'SONO': selectedSoNo ?? '',
            'CUSTOMER': selectedCustomer ?? '',
            'ALERTSID': selectedAlert ?? '0',
            'ITEMCODE': selectedFgCode ?? '',
            'COLORID': selectedExWorkColor ?? '0',
            'PROJID': selectedProject ?? '0',
            'ITEMSUBGRPID': selectedItemSubgroup ?? '0',
            'SELORGSTRUCTID': selectplant ?? '4',
            'CDDCOLORID': selectedCddColor ?? '0',
          },
      );

      final newData = response.data ?? [];

      if (loadMore) {
        _soData.addAll(newData);
      } else {
        _soData = newData;
      }

      _hasMoreData = newData.isNotEmpty;
      _currentPage++;
    } catch (e) {
      print("Error fetching SO data: $e");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  Future<void> fetchSoData( BuildContext mcontext,{bool loadMore = false, bool applyFilter = false}) async {
    if (loadMore) {
      if (!_hasMoreData || _isLoadingMore) return;
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final response = await SoReportService.fetchSoData(
        context: mcontext,
          pageNo: _currentPage,
          applyFilter: applyFilter,
          filterParams: {
            'SONO': selectedSoNo ?? '',
            'CUSTOMER': selectedCustomer ?? '',
            'ALERTSID': selectedAlert ?? '0',
            'ITEMCODE': selectedFgCode ?? '',
            'COLORID': selectedExWorkColor ?? '0',
            'PROJID': selectedProject ?? '0',
            'ITEMSUBGRPID': selectedItemSubgroup ?? '0',
            'SELORGSTRUCTID': selectplant ?? '4',
            'CDDCOLORID': selectedCddColor ?? '0',
          },
      );

      final newData = response.data ?? [];

      if (loadMore) {
        _soData.addAll(newData);
      } else {
        _soData = newData;
      }

      _hasMoreData = newData.isNotEmpty;
      _currentPage++;
    } catch (e) {
      print("Error fetching SO data: $e");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;

        notifyListeners();

    }
  }

  Future<void> fetchDropdownData() async {
    try {
      _isLoadingDropdown = true;
      notifyListeners();

      final ApiServiceFilterDropDown apiService = ApiServiceFilterDropDown();
      _dropdownData = await apiService.fetchSOTableDropdownData();

      // Set default plant if not already set
      if (selectplant == null && _dropdownData?.data?.plant.isNotEmpty == true) {
        selectplant = _dropdownData!.data!.plant.first.orgstrucid.toString();
      }

      _isLoadingDropdown = false;
      notifyListeners();
    } catch (e) {
      _isLoadingDropdown = false;
      notifyListeners();
      print('Error fetching dropdown data: $e');
    }
  }

  // Update methods for dropdowns
  void updateExWorkColor(String? value) {
    selectedExWorkColor = value;
    notifyListeners();
  }

  void updateCddColor(String? value) {
    selectedCddColor = value;
    notifyListeners();
  }

  void updateCustomer(String? value) {
    selectedCustomer = value;
    notifyListeners();
  }

  void updateFgCode(String? value) {
    selectedFgCode = value;
    notifyListeners();
  }

  void updateSoNo(String? value) {
    selectedSoNo = value;
    notifyListeners();
  }

  void updateProject(String? value) {
    selectedProject = value;
    notifyListeners();
  }

  void updateItemSubgroup(String? value) {
    selectedItemSubgroup = value;
    notifyListeners();
  }

  void updateAlert(String? value) {
    selectedAlert = value;
    notifyListeners();
  }

  void updatePlant(String? value) {
    selectplant = value;
    notifyListeners();
  }

  void reset(BuildContext context) {
    selectedExWorkColor = null;
    selectedCddColor = null;
    selectedCustomer = null;
    selectedFgCode = null;
    selectedSoNo = null;
    selectedProject = null;
    selectedItemSubgroup = null;
    selectedAlert = null;
    selectplant = '4'; // Reset to default plant
    _currentPage = 1; // Reset pagination
    notifyListeners();
    fetchSoData(context); // Reload initial data
  }

  // Modified applyFilter
  void applyFilter() {
    if (hasFiltersChanged) {
      _currentPage = 1;
      fetchSoData1(applyFilter: true);
    }
  }

}




