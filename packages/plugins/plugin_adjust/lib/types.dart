import 'package:json_annotation/json_annotation.dart';
part 'types.g.dart';

@JsonSerializable(explicitToJson: true)
class AdjustSettings {
  final bool disabled;
  final String appToken;
  final bool? setEnvironmentProduction;
  @Deprecated("""
  this setting has been removed in the adjust sdk 
  it will be removed in the next version of the plugin
  and has currently no effect
  """)
  final bool? setEventBufferingEnabled;
  final bool? trackAttributionData;
  @Deprecated("""
  this setting has been removed in the adjust sdk 
  it will be removed in the next version of the plugin
  and has currently no effect
  """)
  final bool? setDelay;
  final Map<String, String>? customEvents;
  final int? delayTime;

  /// under which property key the partner parameters are stored
  /// the map behind that key will then be forwarded to the adjust sdk
  /// as partner parameters
  final String? partnerParameterKey;

  AdjustSettings(
    this.appToken, {
    this.disabled = false,
    this.customEvents,
    this.delayTime,
    this.setDelay,
    this.setEnvironmentProduction,
    this.setEventBufferingEnabled,
    this.trackAttributionData,
    this.partnerParameterKey,
  });

  factory AdjustSettings.fromJson(Map<String, dynamic> json) =>
      _$AdjustSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AdjustSettingsToJson(this);
}
