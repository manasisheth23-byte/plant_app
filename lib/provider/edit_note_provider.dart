import 'package:flutter/material.dart';
import '../models/SalesOrderListModel.dart';
import '../models/edit_note_model.dart';
import '../services/ApiProvider.dart';

class EditNoteProvider with ChangeNotifier {
  EditNoteModel? _editNoteModel;
  bool _loading = false;
  String _errorMessage = '';

  EditNoteModel? get editNoteModel => _editNoteModel;
  bool get loading => _loading;
  String get errorMessage => _errorMessage;

  final ApiProvider _apiService = ApiProvider();

  Future<void> EditNote(String content, String subject, String activityid, String flag) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _editNoteModel = await _apiService.EditNote(content, subject, activityid, flag);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
