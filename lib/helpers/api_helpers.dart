Map<String,String> get commonHeader=> {
  "Content-Type": "application/json",
  // "App-Language": app_language.$!,
  "Accept": "application/json",
  // "System-Key":AppConfig.system_key
};

String companyConfig = "Authenticate/InitialConfig?"; //get
String loginApi = "Authenticate/ReturnLoginInfo"; //post
String UpdateUserDeviceInfo  = "Notification/UpdateUserDeviceInfo";//post
String syncILedger  = "CommonLibrary/SyncILedger";//post
String syncSLedger  = "CommonLibrary/SyncSLedger";//post
String ClientEngagement  = "CRM/ClientEngagement";//post
String GetDefaultVal  = "CommonLibrary/GetDefaultVal";//post
String FillDocMast  = "CommonLibrary/FillDocMast";//post
String fillStatusList  = "CommonLibrary/FillStatusList";//post
String ProcessNfgQualityLookup  = "QualityControl/ProcessNFGQualityLookup";//post
String GetTransDetailsForQC  = "QualityControl/GetTransDetailsForQC";//post
String FillLocations  = "CommonLibrary/FillLocations";//post
String RejectionReworkHelpForQC  = "QualityControl/RejectionReworkHelpForQC";//post
String ChangePassword  = "Authenticate/ChangePassword";//post
String GetItemBalance  = "CommonLibrary/GetItemBalance";//post
String syncPriceMaster  = "CommonLibrary/SyncPriceMaster";//post
String fillUserList  = "CommonLibrary/FillUserList";//post
String getSOList  = "SalesOrder/GetSOList";//post
String GetBIPageSheet  = "CommonLibrary/GetBIPageSheet";//post
String AddSO  = "SalesOrder/AddSO";//post
String GetApprovalList  = "Approval/GetApprovalList";//post
String ApproveReject  = "Approval/ApproveReject";//post
String GetApproveHistory  = "Approval/GetApproveHistory";//post
String DownloadAttachmentFile  = "CommonLibrary/GetFile";//post
String DownloadAttachmentDOC  = "Approval/ExportDoc";//post
String GetActivities  = "Activities/GetActivities";//post
String AddActivity  = "Activities/AddActivity";//post