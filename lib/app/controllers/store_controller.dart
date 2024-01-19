import 'package:dio/dio.dart';

class StoreController {
  final String baseUrl = "https://fakestoreapi.com";

  // general methods: handle error from query
  // ignore: deprecated_member_use
  String handleError(DioError error) {
    String errorDescription = '';
    switch (error.type) {
      case DioExceptionType.cancel:
        errorDescription = "";
        break;
      case DioExceptionType.connectionTimeout:
        errorDescription =
            "Connection timed out. Please check your internet connection and try again.";
        break;
      case DioExceptionType.sendTimeout:
        errorDescription =
            "Request timed out while sending data. Please try again.";
        break;
      case DioExceptionType.unknown:
        errorDescription = "An unknown error occurred. Please try again later.";
        break;
      case DioExceptionType.connectionError:
        errorDescription =
            "Unable to establish a connection with the server. Please check your internet connection and try again.";
        break;
      case DioExceptionType.receiveTimeout:
        errorDescription =
            "Request timed out while waiting for a response. Please try again.";
        break;

      default:
        errorDescription = "An unknown error occurred. Please try again later.";
        break;
    }

    return errorDescription;
  }
}
