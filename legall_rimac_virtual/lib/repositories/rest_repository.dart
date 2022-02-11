import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:legall_rimac_virtual/models/inspecciones_response.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/models/list_photo_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestRepository {
  final baseUrl = "http://104.209.133.102:8080";
  final keyToken = "KEY_TOKEN";
  static final RestRepository _instancia = RestRepository._internal();
  SharedPreferences _sharedPreferences;

  factory RestRepository() {
    return _instancia;
  }

  RestRepository._internal();

  initRepository() async {
    this._sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> updateScheduleRest(InspectionModel inspectionModel) async {
    final token = _sharedPreferences.getString(keyToken) ?? "";
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
    //Create Path Url
    var path = "$baseUrl/inspector/inspecciones/reprogramar";
    var url = Uri.parse(path);
    final fecha = inspectionModel
        .schedule[inspectionModel.schedule.length - 1].dateTime
        .toString();
    Map<String, dynamic> body = {
      "idInforme": "${inspectionModel.informeId}",
      "usuarioCreacion": "ADMIN",
      "fechaProgramada": "${fecha.substring(0, 10)}T${fecha.substring(11, 19)}"
    };

    final resp = await http.put(url, body: json.encode(body), headers: headers);

    print("------------------------------------------");
    print("RestApi inspectionModel : $inspectionModel");
    print("RestApi path :$path y el status code es ${resp.statusCode}");
    print("RestApi body :$body");
    //print("RestApi response :${utf8.decode(resp.bodyBytes)}");
  }

  Future<InspeccionesResponse> getInspecciones(String insured) async {

    Map<String,String> queryParams = {"insured":insured};
    //Create Token
    final token = _sharedPreferences.getString(keyToken) ?? "";
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };

    //Validate and Create Query String
    String queryString = (queryParams != null)
        ? "?${Uri(queryParameters: queryParams).query}"
        : "";

    //Create Path Url
    var url = Uri.parse(baseUrl + "/inspector/inspecciones/find" + queryString);

    print("RestApi path GET:$url");

    final resp = await http.get(url, headers: headers);

    final response = json.decode(utf8.decode(resp.bodyBytes));

    print("RestApi path GET:$url");
    print("RestApi header :$headers");
    print("RestApi response :${utf8.decode(resp.bodyBytes)}");
    InspeccionesResponse data;
    try{
      data =InspeccionesResponse.fromJson(response);
    }catch( e){
      print("Exception getInspecciones  ${e}");
    }
    print("getInspecciones  ${data.list.length}");
    return data;
  }

  Future<List<PhotoDetail>> getDetailPhotos() async {
    //Create Path Url
    var url = Uri.parse(baseUrl + "/inspector/files/detail-upload");

    print("RestApi path GET:$url");

    final resp = await http.get(url);

    final response = json.decode(utf8.decode(resp.bodyBytes));

    print("RestApi path GET:$url");
    print("RestApi response :${utf8.decode(resp.bodyBytes)}");
    List<PhotoDetail> data;
    try{
      data =ListPhotoDetail.fromJson(response).listPhotoDetail;
    }catch( e){
      print("Exception getDetailPhotos  ${e}");
    }
    return data;
  }

  Future<void> login() async {
    //Create Path Url
    var path = "$baseUrl/fps-auth-inspector/login";
    var url = Uri.parse(path);
    Map<String, dynamic> body = {
      'username': 'MOVIL',
      'password': 'Leg@ll-2021'
    };
    String encodedBody = body.keys.map((key) => "$key=${body[key]}").join("&");

    final resp = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: encodedBody,
      encoding: Encoding.getByName("utf-8"),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final response = json.decode(utf8.decode(resp.bodyBytes));
      _sharedPreferences.setString(keyToken, response["token"]);
    }
    print("RestApi path :$path  y el status code es ${resp.statusCode}");
    print("RestApi body :${json.encode(body)}");
    print("RestApi response :${utf8.decode(resp.bodyBytes)}");
  }
}
