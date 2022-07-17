import 'package:http/http.dart' as http;

class NetworkHelper {
  /// class to help with connection with API server

  // constructor
  NetworkHelper(this.url);

  final String url;

  Future sendData() async {
    /// http post request
    /// return API response if statusCode is 201
    /// else return statusCode

    http.Response response = await http.post(
      Uri.parse(url),
    );

    if (response.statusCode == 201) {
      String data = response.body;
      return data;
    } else {
      return response.statusCode;
    }
  }

  Future getData() async {
    /// http get request
    /// return API response if statusCode is 200
    /// else return statusCode

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String data = response.body;
      return data;
    } else {
      return response.statusCode;
    }
  }
}
