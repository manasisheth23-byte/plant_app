import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audit_response_model.dart';
import '../repositories/barcode_repository.dart';

class AuditProvider with ChangeNotifier {
  final TextEditingController barcodeController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuditResponseModel? _auditData;
  AuditResponseModel? get auditData => _auditData;

  final BarcodeRepository _repository = BarcodeRepository();
  void clearAuditData() {
    _auditData = null;
    notifyListeners();
  }
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  // ✅ SINGLE CLEAR METHOD
  void clearAll() {
    barcodeController.clear();
    _auditData = null;
    _isLoading = false;
    notifyListeners();
  }
  Future<void> fetchBarcodeItems(String strFlag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('USERID');
    if (userId == null) return;

    _setLoading(true);

    try {
      _auditData = null;
      final data = await _repository.getAuditDetails(
        userId,
        strFlag,
        barcodeController.text.trim(),
      );
      _auditData = data;
    } catch (e) {
      print("❌ Error fetching barcode items: $e");
      _auditData = null;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    barcodeController.dispose();
    _auditData = null;
    super.dispose();
  }
}
