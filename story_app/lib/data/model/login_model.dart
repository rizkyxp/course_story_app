import 'package:json_annotation/json_annotation.dart';
import 'package:story_app/data/model/login_result.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  bool error;
  String message;
  LoginResult loginResult;

  LoginModel({
    required this.error,
    required this.message,
    required this.loginResult,
  });

  factory LoginModel.fromJson(json) => _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
