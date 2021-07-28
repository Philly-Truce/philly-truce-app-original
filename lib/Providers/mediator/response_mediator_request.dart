import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/CustomException.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'add_mediator.dart';

class ResponseMediatorRequestClient {
  final _baseUrl = '${AddMediatorApiClient.baseUrl}';
  http.Client httpClient = http.Client();

  Future<String> responseUserRequest(int requestBackupId) async {
    Data userData = await SaveDataLocal.getUserDataFromLocal();

    final Map<String, String> data = new Map<String, String>();
    data['UserId'] = userData.user_id.toString();
    data['Token'] = userData.unique_token;

    final Map<String, String> bodyParameter = new Map<String, String>();
    bodyParameter['request_backup_id'] = requestBackupId.toString();

    final url = '$_baseUrl/Response_to_mediator_request';
    var responseJson;
    try {
      final response = await httpClient
          .post(url, body: bodyParameter, headers: data)
          .timeout(
        Duration(minutes: 1),
        onTimeout: () {
          print('Flutter Fully Truce' + 'time out');
          Fluttertoast.showToast(
              msg: 'Something went wrong . please try again');
          return null;
        },
      );
      responseJson = _response(response);
    } on SocketException {
      Fluttertoast.showToast(
          msg:
              'Some thing went Wrong . to response mediator request Please Try again later');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
    /*if (response.statusCode == 200) {
      print('Flutter Fully Truce' + json.decode(response.body)['message']);
      if (json.decode(response.body)['statusCode'] == 3)
        return json.decode(response.body)['message'].toString();
      else
        return json.decode(response.body)['message'].toString();
      // return UserInformationModel.fromJson(json.decode(response.body)).data;
    } else {
      return json.decode(response.body)['message'].toString();

    }*/
  }
}

dynamic _response(http.Response response) {
  switch (response.statusCode) {
    case 200:
      return json.decode(response.body)['message'].toString();
    case 400:
    case 401:

    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:

    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode :${response.statusCode}');
  }
}
