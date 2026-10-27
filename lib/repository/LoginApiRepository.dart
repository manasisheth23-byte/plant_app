





import '../models/CheckDeviceRequestModel.dart';
import '../models/CheckDeviceResponseModel.dart';
import '../models/ClientEngagementReqestModel.dart';
import '../models/ClientEngagementResponseModel.dart';
import '../models/FillDocMastRequestModel.dart';
import '../models/FillDocMastResponseModel.dart';
import '../models/FillLocationsRequestModel.dart';
import '../models/FillLocationsResponseModel.dart';
import '../models/FillStatusListRequestModel.dart';
import '../models/FillStatusListResponseModel.dart';
import '../models/GetDefaultValRequestModel.dart';
import '../models/GetDefaultValResponseModel.dart';
import '../models/GetTransDetailsForQCRequestModel.dart';
import '../models/GetTransDetailsForQCResponseModel.dart';
import '../models/LoginRequestModel.dart';
import '../models/LoginResponseModel.dart';
import '../models/ProcessNFGQualityLookupRequestModel.dart';
import '../models/ProcessNFGQualityLookupResponseModel.dart';
import '../models/RejectionReworkHelpForQCRequestModel.dart';
import '../models/RejectionReworkHelpForQCResponseModel.dart';
import '../models/UpdateUserDeviceInfoRequestModel.dart';
import '../models/UpdateUserDeviceInfoResponseModel.dart';
import '../services/ApiProvider.dart';

class LoginApiRepository{
  ApiProvider _apiProvider = ApiProvider();



  // Future<LoginResponseModel> getLoginData(LoginRequestModel data){
  //   return _apiProvider.getLoginDetails(data);
  // }
  // Future<UpdateUserDeviceInfoResponseModel> UpdateUserDeviceInfoData(UpdateUserDeviceInfoRequestModel data){
  //   return _apiProvider.UpdateUserDeviceInfoDetails(data);
  // }
  Future<ClientEngagementResponseModel> ClientEngagementData(ClientEngagementReqestModel data){
    return _apiProvider.ClientEngagementDetails(data);
  }
  Future<GetDefaultValResponseModel> GetDefaultValData(GetDefaultValRequestModel data){
    return _apiProvider.GetDefaultValDetails(data);
  }
  Future<FillDocMastResponseModel> FillDocMastData(FillDocMastRequestModel data){
    return _apiProvider.FillDocMastDetails(data);
  }

  Future<FillStatusListResponseModel> FillStatusListData(FillStatusListRequestModel data){
    return _apiProvider.FillStatusListDetails(data);
  }
  Future<ProcessNfgQualityLookupResponseModel> ProcessNFGQualityLookupData(ProcessNFGQualityLookupRequestModel data){
    return _apiProvider.ProcessNFGQualityLookupDetails(data);
  }
  Future<GetTransDetailsForQcResponseModel> GetTransDetailsForQCData(GetTransDetailsForQCRequestModel data){
    return _apiProvider.GetTransDetailsForQCDetails(data);
  }
  Future<FillLocationsResponseModel> FillLocationsData(FillLocationsRequestModel data){
    return _apiProvider.FillLocationsDetails(data);
  }
  Future<RejectionReworkHelpForQcResponseModel> RejectionReworkHelpForQCData(RejectionReworkHelpForQCRequestModel data){
    return _apiProvider.RejectionReworkHelpForQCDetails(data);
  }
  Future<CheckDeviceResponseModel> getCheckDevice(CheckDeviceRequestModel data){
    return _apiProvider.getCheckDeviceDetails(data);
  }
}


