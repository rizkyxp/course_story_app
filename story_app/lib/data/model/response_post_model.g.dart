// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponsePostModel _$ResponsePostModelFromJson(Map<String, dynamic> json) =>
    ResponsePostModel(
      error: json['error'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ResponsePostModelToJson(ResponsePostModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
    };
