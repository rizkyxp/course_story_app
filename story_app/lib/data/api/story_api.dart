import 'dart:convert';
import 'dart:typed_data';

import 'package:story_app/data/model/login_model.dart';
import 'package:story_app/data/model/response_post_model.dart';
import 'package:story_app/data/model/story_detail_model.dart';
import 'package:story_app/data/model/story_list_model.dart';
import 'package:http/http.dart' as http;

class StoryApi {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<ResponsePostModel> register(String username, String email, String password) async {
    final body = {"name": username, "email": email, "password": password};

    final response = await http.post(Uri.parse('$_baseUrl/register'), body: body);

    if (response.statusCode == 201) {
      return ResponsePostModel.fromJson(json.decode(response.body));
    } else {
      final responseBody = json.decode(response.body);
      throw Exception('${responseBody['message'] ?? 'Unknown error'}');
    }
  }

  Future<LoginModel> login(String email, String password) async {
    final body = {
      "email": email,
      "password": password,
    };

    final response = await http.post(Uri.parse('$_baseUrl/login'), body: body);

    if (response.statusCode == 200) {
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      final responseBody = json.decode(response.body);
      throw Exception('${responseBody['message'] ?? 'Unknown error'}');
    }
  }

  Future<ResponsePostModel> addNewStory(
    List<int> bytes,
    String fileName,
    String description,
    String token,
    double lat,
    double lon,
  ) async {
    const String url = "$_baseUrl/stories";

    final uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);

    final multiPartFile = http.MultipartFile.fromBytes(
      "photo",
      bytes,
      filename: fileName,
    );
    final Map<String, String> fields = {
      "description": description,
      "lat": lat.toString(),
      "lon": lon.toString(),
    };
    final Map<String, String> headers = {"Content-type": "multipart/form-data", "Authorization": "Bearer $token"};

    request.files.add(multiPartFile);
    request.fields.addAll(fields);
    request.headers.addAll(headers);

    final http.StreamedResponse streamedResponse = await request.send();
    final int statusCode = streamedResponse.statusCode;

    final Uint8List responseList = await streamedResponse.stream.toBytes();
    final String responseData = String.fromCharCodes(responseList);

    if (statusCode == 201) {
      final ResponsePostModel uploadResponse = ResponsePostModel.fromJson(
        json.decode(responseData),
      );
      return uploadResponse;
    } else {
      throw Exception("Upload file error");
    }
  }

  Future<ListStoryModel> getListStory(String token, int pageItems) async {
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final Map<String, String> queryParams = {
      'page': '$pageItems',
    };

    final response =
        await http.get(Uri.parse('$_baseUrl/stories').replace(queryParameters: queryParams), headers: headers);

    if (response.statusCode == 200) {
      return ListStoryModel.fromJson(json.decode(response.body));
    } else {
      final responseBody = json.decode(response.body);
      throw Exception('${responseBody['message'] ?? 'Unknown error'}');
    }
  }

  Future<DetailStoryModel> getDetailStory(String token, String id) async {
    final headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse('$_baseUrl/stories/$id'), headers: headers);

    if (response.statusCode == 200) {
      return DetailStoryModel.fromJson(json.decode(response.body));
    } else {
      final responseBody = json.decode(response.body);
      throw Exception('${responseBody['message'] ?? 'Unknown error'}');
    }
  }
}
