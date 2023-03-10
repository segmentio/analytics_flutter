import 'package:json_annotation/json_annotation.dart';
part 'types.g.dart';

@JsonSerializable(explicitToJson: true)
class AppsFlyerSettings {
  final String? appleAppID;
  final String appsFlyerDevKey;
  final bool httpFallback;
  final String? rokuAppID;
  final bool trackAttributionData;
  final String type;
  final Map<String, List<String>> versionSettings;

  AppsFlyerSettings(
      this.appleAppID,
      this.appsFlyerDevKey,
      this.httpFallback,
      this.rokuAppID,
      this.trackAttributionData,
      this.type,
      this.versionSettings);

  factory AppsFlyerSettings.fromJson(Map<String, dynamic> json) =>
      _$AppsFlyerSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppsFlyerSettingsToJson(this);
}
