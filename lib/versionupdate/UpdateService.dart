import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ffi';
import 'package:win32/win32.dart';
import 'package:path_provider/path_provider.dart';


class UpdateService {
  Future<void> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;

    final res = await http.get(Uri.parse(
        'https://yourdomain.com/update.json'));

    final data = jsonDecode(res.body);
    final latestVersion = data['version'];
    final downloadUrl = data['url'];

    if (latestVersion != currentVersion) {
      await _downloadAndInstall(downloadUrl);
    }
  }

  Future<void> _downloadAndInstall(String url) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}\\update.exe';

    final res = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(res.bodyBytes);

    // Launch installer
    ShellExecute(
      0,
      TEXT('open'),
      TEXT(filePath),
      nullptr,
      nullptr,
      SW_SHOWNORMAL,
    );

    // Exit current app
    exit(0);
  }
}
