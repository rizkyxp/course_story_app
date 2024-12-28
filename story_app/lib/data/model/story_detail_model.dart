import 'package:json_annotation/json_annotation.dart';
import 'package:story_app/data/model/story_model.dart';

part 'story_detail_model.g.dart';

@JsonSerializable()
class DetailStoryModel {
  bool error;
  String message;
  Story story;

  DetailStoryModel({
    required this.error,
    required this.message,
    required this.story,
  });

  factory DetailStoryModel.fromJson(json) => _$DetailStoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$DetailStoryModelToJson(this);
}
