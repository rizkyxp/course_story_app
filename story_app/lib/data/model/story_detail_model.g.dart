// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailStoryModel _$DetailStoryModelFromJson(Map<String, dynamic> json) =>
    DetailStoryModel(
      error: json['error'] as bool,
      message: json['message'] as String,
      story: Story.fromJson(json['story']),
    );

Map<String, dynamic> _$DetailStoryModelToJson(DetailStoryModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'story': instance.story,
    };
