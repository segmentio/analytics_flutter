// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustSettings _$AdjustSettingsFromJson(Map<String, dynamic> json) =>
    AdjustSettings(
      json['appToken'] as String,
      disabled: json['disabled'] as bool? ?? false,
      customEvents: (json['customEvents'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      delayTime: (json['delayTime'] as num?)?.toInt(),
      setDelay: json['setDelay'] as bool?,
      setEnvironmentProduction: json['setEnvironmentProduction'] as bool?,
      setEventBufferingEnabled: json['setEventBufferingEnabled'] as bool?,
      trackAttributionData: json['trackAttributionData'] as bool?,
    );

Map<String, dynamic> _$AdjustSettingsToJson(AdjustSettings instance) =>
    <String, dynamic>{
      'disabled': instance.disabled,
      'appToken': instance.appToken,
      'setEnvironmentProduction': instance.setEnvironmentProduction,
      'setEventBufferingEnabled': instance.setEventBufferingEnabled,
      'trackAttributionData': instance.trackAttributionData,
      'setDelay': instance.setDelay,
      'customEvents': instance.customEvents,
      'delayTime': instance.delayTime,
    };
