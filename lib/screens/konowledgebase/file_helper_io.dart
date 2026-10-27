import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

Future<void> openFileNative(String fileName, String filePath) async {
  Directory? dir;
  if (Platform.isAndroid) {
    dir = await getExternalStorageDirectory();
    if (!(await Permission.storage.isGranted)) {
      await Permission.storage.request();
    }
  } else {
    dir = await getApplicationDocumentsDirectory();
  }

  if (dir != null) {
    final file = File('${dir.path}/AttachmentsFile/$fileName');
    if (await file.exists()) {
      await OpenFile.open(file.path);
    } else {
      print("File not found: ${file.path}");
    }
  }
}
