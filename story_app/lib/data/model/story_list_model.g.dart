// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListStoryModel _$ListStoryModelFromJson(Map<String, dynamic> json) =>
    ListStoryModel(
      error: json['error'] as bool,
      message: json['message'] as String,
      listStory:
          (json['listStory'] as List<dynamic>).map(ListStory.fromJson).toList(),
    );

Map<String, dynamic> _$ListStoryModelToJson(ListStoryModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'listStory': instance.listStory,
    };
