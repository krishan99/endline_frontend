import 'dart:convert';

import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as Foundation;

class CustomException implements Exception {
  String cause;

  @override
  String toString() {
    return cause;
  }

  CustomException(this.cause);
}

class MyServerException extends CustomException {
  MyServerException(String cause) : super(cause);
}

class ForbiddenException extends MyServerException {
  ForbiddenException(String cause) : super(cause);
}

class AccountDoesNotExistException extends ForbiddenException {
  AccountDoesNotExistException(String cause) : super(cause);
}

class JsonEncodingException extends MyServerException {
  JsonEncodingException(String cause) : super(cause);
}

class InvalidException extends MyServerException {
  InvalidException(String cause) : super(cause);
}

class NotFoundException extends MyServerException {
  NotFoundException(String cause) : super(cause);
}

class InvalidEmailException extends MyServerException {
  InvalidEmailException({String cause}) : super(cause ?? "Your email address appears to be malformed.");
}

class InvalidPasswordException extends MyServerException {
  InvalidPasswordException({String cause}) : super(cause ?? "Your password is wrong.");
}

class EmailAlreadyInUseException extends MyServerException {
  EmailAlreadyInUseException({String cause}) : super(cause ?? "There's already an account associated with this email.");
}

class UserNotFoundException extends MyServerException {
  UserNotFoundException({String cause}) : super(cause ?? "User with this email doesn't exist.");
}

class UserDisabledException extends MyServerException {
  UserDisabledException({String cause}) : super(cause ?? "User with this email has been disabled.");
}

class TooManyRequestsException extends MyServerException {
  TooManyRequestsException({String cause}) : super(cause ?? "Too many requests. Try again later.");
}

class OperationNotAllowedException extends MyServerException {
  OperationNotAllowedException({String cause}) : super(cause ?? "Signing in with Email and Password is not enabled.");
}

class MyServer {
  static const bool USE_LOCAL = false;
  static const String socketPath = USE_LOCAL ? "http://0.0.0.0:8000/" : 'http://3.129.96.170:81';
  static const String path = USE_LOCAL
      ? "http://0.0.0.0:8000/"
      : "https://krishan.io/";
  static const Duration timeout =
      Duration(seconds: Foundation.kDebugMode ? 10 : 10);

  static Map<String, String> defaultHeaders = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Map<String, String> headers = defaultHeaders;

  static String _getURL({@required String route}) {
    return "$path$route";
  }

  static Future<Map<String, dynamic>> post(String route, {@required Map body}) async {
    final url = _getURL(route: route);

    // await Future.delayed(Duration(seconds: 3));

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    updateCookie(response);

    return getMap(response);
  }

  static void resetHeaders() {
    headers = defaultHeaders;
  }

  static Future<Map<String, dynamic>> get(String route) async {
    final url = _getURL(route: route);

    // await Future.delayed(Duration(seconds: 3));

    final response = await http.get(
      url,
      headers: headers,
    );

    updateCookie(response);

    return getMap(response);
  }

  static Map<String, dynamic> getMap(http.Response r) {
    if (r.statusCode == 500) {
      throw MyServerException("Server Error");
    }

    final body = jsonDecode(r.body);

    if (r.statusCode == 200) {
      return body;
    }

    final message = body['message'] as String;

    print("ERROR: $message");

    switch (message) {
      case "User not signed up":
        throw AccountDoesNotExistException("This User is Not Signed Up");
      default:
        switch (r.statusCode) {
          case 403:
            throw ForbiddenException(message);
          case 405:
            throw JsonEncodingException(message);
          case 404:
            throw NotFoundException(message);
          default:
            throw Exception(message);
        }
    }
  }

  static void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  // MyServer._();
}

extension QueueRequests on MyServer {
  static Future<Queue> getQueue({@required qid}) async {
    Map<String, dynamic> body = await MyServer.get("api/v1/queue/retrieve");
    return Queue.fromMap(body);
  }
}

class ApiResponse<T> {
  Status status;
  T data;
  String message;

  bool get isError {
    return status == Status.ERROR;
  }

  bool get isSuccess {
    return status == Status.COMPLETED;
  }

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }

  static Future<ApiResponse<T>> fromFunction<T>(
      Future<T> Function() function) async {
    try {
      T value = await function();
      return ApiResponse.completed(value);
    } catch (error) {
      return ApiResponse.error(error.toString());
    }
  }
}

enum Status { LOADING, COMPLETED, ERROR }
