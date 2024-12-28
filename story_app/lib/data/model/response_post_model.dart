import 'package:json_annotation/json_annotation.dart';

part 'response_post_model.g.dart';

@JsonSerializable()
class ResponsePostModel {
  bool error;
  String message;

  ResponsePostModel({
    required this.error,
    required this.message,
  });

  factory ResponsePostModel.fromJson(json) => _$ResponsePostModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResponsePostModelToJson(this);
}
