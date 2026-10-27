

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/LoginResponseModel.dart';
import '../utils/global_variables.dart';




class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const _keyUsername = "username";
  static const _keyPassword = "password";
  static const _keyIsLoggedIn = "isLoggedIn";
  static const _keyUserId = "userId";
  static const _keyUserName = "userName";
  static const _keyUserType = "userType";
  static const _keyToken = "token";
  static const _keyIsVerified = "isVerified";
  static const _keyEnableBiometric = "enableBiometric";
  static const _keyMobileNo = "mobileNo";
  static const _tokenKey = "auth_token";
  static const String _isApiLoginKey = "is_api_login";
  static const _keyRememberMe = 'remember_me';
  static const _orgstructId = "orgstructId";
  static const _postId = "postId";
  static const _controlno = "controlno";
  static const _Imagedesc = "imagedesc";
  static Future<void> saveIsApiLogin(bool value) async {
    const storage = FlutterSecureStorage();

    await storage.write(
      key: _isApiLoginKey,
      value: value.toString(), // store as string
    );
  }
  static Future<bool> getIsApiLogin() async {
    const storage = FlutterSecureStorage();

    String? value = await storage.read(key: _isApiLoginKey);

    return value == "true";
  }
  static Future<void> updateOrgStructId(String orgStructId) async {
    await _storage.write(
      key: _orgstructId,
      value: orgStructId,
    );
  }
  /// 🔥 Save Full User Data
  static Future<void> saveUser(LoginResponseModel user) async {
    final loginData = user.data;

    if (loginData == null) return;

    await _storage.write(key: _keyUserId, value: loginData.userid);
    await _storage.write(key: _orgstructId, value: loginData.orgstrucid);
    await _storage.write(key: _postId, value: loginData.posid);
    await _storage.write(key: _controlno, value: loginData.controlno);
    await _storage.write(key: _keyUserName, value: loginData.username);
    await _storage.write(key: _keyUserType, value: loginData.usertypeid);
    await _storage.write(key: _keyToken, value: loginData.token);
    await _storage.write(key: _Imagedesc, value: loginData.imgdesc);
    await _storage.write(
        key: _keyIsVerified,
        value: (loginData.status.toLowerCase() == "true").toString());
    await _storage.write(
        key: _keyEnableBiometric, value: loginData.eNABLEBIOMETRIC);
    await _storage.write(key: _keyMobileNo, value: loginData.MOBILENO);

    await _storage.write(key: _keyIsLoggedIn, value: "true");
  }

  /// 🔥 Save Login Credentials
  static Future<void> saveCredentials(
      String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
  }
  static Future<Map<String, String>?> getCredentials() async {
    String? username = await _storage.read(key: _keyUsername);
    String? password = await _storage.read(key: _keyPassword);

    if (username == null || password == null) {
      return null;
    }

    return {
      "username": username,
      "password": password,
    };
  }
  /// 🔥 Get Logged In User
  static Future<LoginResponseModel?> getUser() async {
    String? userId = await _storage.read(key: _keyUserId);
    String? orgstructId = await _storage.read(key: _orgstructId);
    String? postId = await _storage.read(key: _postId);
    String? controlno = await _storage.read(key: _controlno);
    String? userName = await _storage.read(key: _keyUserName);
    String? userType = await _storage.read(key: _keyUserType);
    String? token = await _storage.read(key: _keyToken);
    String? Imagedesc = await _storage.read(key: _Imagedesc);
    String? IsVerified = await _storage.read(key: _keyIsVerified);
    String? enableBiometric =
    await _storage.read(key: _keyEnableBiometric);
    String? mobileNo = await _storage.read(key: _keyMobileNo);

    if (userId == null || token == null) {
      return null;
    }

    return LoginResponseModel(
      data: LoginResponseModelData(
        status: "true",
        message: "",
        userid: userId,
        usertypeid: userType ?? "",
        usertype: "",
        loginid: "",
        username: userName ?? "",
        email: "",
        token: token,
        BusinessType: "",
        eNABLEBIOMETRIC: enableBiometric ?? "false",
        MOBILENO: mobileNo ?? "", imgdesc: Imagedesc ??"", posid: postId ??'',
        posdesc: '', slid: '', slcode: '', sldesc: '', buids: '',
        orgstrucid: orgstructId ??"", orgdesc: '', controlno: controlno ??'', finyeardesc: '', sdate: '', edate: '',
        tokenCreatedOn: '', tokenExpiresOn: '', rfidflag: '', timelogout: '', shiftdate: '', shiftdesc: '',
        FORCEUPDATE: '', ISVERIFIED: IsVerified ?? "false", RESETDATA: '', KIOSKMODEID: '', KIOSKMODEDESC: '', ISOTP: '', branchid: '', branchcode: '', branchname: '',

        crmcustid: '', crmcustcode: '', crmcustname: '', mobilesync: '', MESSAGE: '',
      ),
    );
  }
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  /// 🔥 Get Token
  /*static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }*/
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: "token");
    } catch (e) {
      await _storage.delete(key: "token");
      return null;
    }
  }
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
  Future<void> clearIsVerify() async {
    await _storage.delete(key: _keyIsVerified);
  }
  /// 🔥 Check Login
  static Future<bool> isLoggedIn() async {
    String? value = await _storage.read(key: _keyIsLoggedIn);
    return value == "true";
  }
  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(
      key: _keyIsLoggedIn,
      value: value.toString(),
    );
  }

  static Future<void> setIsVerifiedn(bool value) async {
    await _storage.write(
      key: _keyIsVerified,
      value: value.toString(),
    );
  }
  static Future<bool> getIsVerifiedn() async {
    String? value = await _storage.read(key: _keyIsVerified);
    return value == "true";
  }
  /// 🔥 Clear All Data (Logout)
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static Future<void> setUsername(String username) async {
    await _storage.write(key: _keyUsername, value: username);
  }

  static Future<void> setPassword(String password) async {
    await _storage.write(key: _keyPassword, value: password);
  }

  static Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _keyRememberMe, value: value.toString());
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  static Future<bool> isRememberMe() async {
    String? value = await _storage.read(key: _keyRememberMe);
    return value == 'true';
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyRememberMe);
  }
}


/*
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = "auth_token";
  static const _keyUsername = "username";
  static const _keyPassword = "password";
  static const _keyIsLoggedIn = "isLoggedIn";
  static const _keyUserId = "userId";
  static const _keyUserName = "userName";
  static const _keyUserType = "userType";
  static const _keyToken = "token";
  static const _keyIsVerified = "isVerified";
  static Future<void> saveUser(LoginResponseModel user) async {
    await _storage.write(key: _keyUserId, value: user.userId.toString());
    await _storage.write(key: _keyUserName, value: user.userName);
    await _storage.write(key: _keyUserType, value: user.uTypeId.toString());
    await _storage.write(key: _keyToken, value: user.token);
    await _storage.write(
        key: _keyIsVerified, value: user.isVerified.toString());
    await _storage.write(key: _keyIsLoggedIn, value: "true");
  }
  static Future<void> saveCredentials(
      String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyIsLoggedIn, value: "true");
  }
  static Future<LoginResponseModel?> getUser() async {
    String? userId = await _storage.read(key: _keyUserId);
    String? userName = await _storage.read(key: _keyUserName);
    String? userType = await _storage.read(key: _keyUserType);
    String? token = await _storage.read(key: _keyToken);
    String? isVerified = await _storage.read(key: _keyIsVerified);

    if (userId == null || token == null) {
      return null; // No logged in user
    }

    return LoginResponseModel(
      userId: int.tryParse(userId) ?? 0,
      userName: userName ?? "",
      message: "",
      uTypeId: int.tryParse(userType ?? "0") ?? 0,
      isVerified: isVerified == "true",
      mobileNo: "",
      bioKey: "",
      forceUpdate: false,
      enableBiometric: false,
      token: token,
    );
  }
  // Get Username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  // Get Password
  static Future<String?> getPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  // Check Login
  static Future<bool> isLoggedIn() async {
    String? value = await _storage.read(key: _keyIsLoggedIn);
    return value == "true";
  }
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
  // Clear All
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}*/
