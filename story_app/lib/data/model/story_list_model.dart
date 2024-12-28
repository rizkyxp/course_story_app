import 'package:json_annotation/json_annotation.dart';
import 'package:story_app/data/model/list_story_model.dart';

part 'story_list_model.g.dart';

@JsonSerializable()
class ListStoryModel {
  bool error;
  String message;
  List<ListStory> listStory;

  ListStoryModel({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory ListStoryModel.fromJson(json) => _$ListStoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListStoryModelToJson(this);
}
