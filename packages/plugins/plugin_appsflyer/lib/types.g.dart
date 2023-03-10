// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppsFlyerSettings _$AppsFlyerSettingsFromJson(Map<String, dynamic> json) =>
    AppsFlyerSettings(
      json['appleAppID'] as String?,
      json['appsFlyerDevKey'] as String,
      json['httpFallback'] as bool,
      json['rokuAppID'] as String?,
      json['trackAttributionData'] as bool,
      json['type'] as String,
      (json['versionSettings'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$AppsFlyerSettingsToJson(AppsFlyerSettings instance) =>
    <String, dynamic>{
      'appleAppID': instance.appleAppID,
      'appsFlyerDevKey': instance.appsFlyerDevKey,
      'httpFallback': instance.httpFallback,
      'rokuAppID': instance.rokuAppID,
      'trackAttributionData': instance.trackAttributionData,
      'type': instance.type,
      'versionSettings': instance.versionSettings,
    };
