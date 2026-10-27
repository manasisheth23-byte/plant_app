import 'package:erpflutter/models/financialyear_model.dart';
import 'package:erpflutter/services/ApiProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/global_variables.dart';

class FinancialYearProvider extends ChangeNotifier {
  final ApiProvider _apiProvider = ApiProvider();
  FinancialYearTransaction? _selectedYear;
  bool _isLoading = false;
  String? _error;

  List<FinancialYearTransaction> _years = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FinancialYearTransaction> get years => _years;
  // 🔹 Selected year (used in drawer)
  FinancialYearTransaction? get selectedYear =>
      _selectedYear ?? defaultYear;
  Future<String?> getSelectedControlNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('SELECTED_FINANCIAL_YEAR');
  }
  static const String _selectedYearKey = 'CONTROLNO';
// 🔹 Change selected year
  Future<void> changeFinancialYear(FinancialYearTransaction year) async {
    _selectedYear = year;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedYearKey, year.controlNo ?? '');
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dynamic json =
      await _apiProvider.fetchTransactionsfinancial("13");



      // ✅ THIS IS THE ONLY CORRECT LINE
      _years =
          json.transactionDetails?.transactions ?? [];
      final prefs = await SharedPreferences.getInstance();
      final savedControlNo = prefs.getString(_selectedYearKey);

      if (savedControlNo != null && savedControlNo.isNotEmpty) {
        // 🔹 Try to restore saved year
        _selectedYear = _years.firstWhere(
              (e) => e.controlNo == savedControlNo,
          orElse: () {
            // 🔹 Saved value not found → fallback
            return defaultYear ?? _years.first;
          },
        );
      } else {
        // 🔹 No saved value → use default year
        _selectedYear = defaultYear ?? _years.first;
      }

      // ✅ ALWAYS update SharedPreferences with final value
      await prefs.setString(
        _selectedYearKey,
        _selectedYear?.controlNo ?? '',
      );
      print(_years);
      getData();
    } catch (e) {
      _error = e.toString();
      print(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ DEFAULT YEAR LOGIC
  FinancialYearTransaction? get defaultYear {
    try {

      return _years.firstWhere((e) => e.defaultYr == "1");
    } catch (_) {
      return _years.isNotEmpty ? _years.first : null;
    }
  }
  // ---------------- CLEAR ON LOGOUT ----------------
  void clear() {
    _selectedYear = null;
    _years.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
