import 'package:parker/services/networking.dart';

// server url
const javaServerUrl = 'http://192.168.0.203:8080';

class ApiCall {
  /// class for API call
  /// for get request: getApiData() method
  /// for post request: sendApiData() method

  Future<dynamic> getApiData(String urlBody) async {
    /// for get request
    /// give url in argument
    /// return api response

    NetworkHelper networkHelper = NetworkHelper(
      javaServerUrl + urlBody,
    );

    var apiData = await networkHelper.getData();
    return apiData;
  }

  Future<dynamic> sendApiData(String urlBody) async {
    /// for post request
    /// give url in argument
    /// return api response

    NetworkHelper networkHelper = NetworkHelper(
      javaServerUrl + urlBody,
    );

    var apiData = await networkHelper.sendData();
    return apiData;
  }
}
