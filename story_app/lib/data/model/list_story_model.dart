import 'package:json_annotation/json_annotation.dart';

part 'list_story_model.g.dart';

@JsonSerializable()
class ListStory {
  String id;
  String name;
  String description;
  String photoUrl;
  DateTime createdAt;
  double? lat;
  double? lon;

  ListStory({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.lat,
    this.lon,
  });

  factory ListStory.fromJson(json) => _$ListStoryFromJson(json);

  Map<String, dynamic> toJson() => _$ListStoryToJson(this);
}
