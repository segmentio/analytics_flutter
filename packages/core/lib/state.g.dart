// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      json['anonymousId'] as String,
      userId: json['userId'] as String?,
      groupTraits: json['groupTraits'] == null
          ? null
          : GroupTraits.fromJson(json['groupTraits'] as Map<String, dynamic>),
      userTraits: json['userTraits'] == null
          ? null
          : UserTraits.fromJson(json['userTraits'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) {
  final val = <String, dynamic>{
    'anonymousId': instance.anonymousId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userId', instance.userId);
  writeNotNull('userTraits', instance.userTraits?.toJson());
  writeNotNull('groupTraits', instance.groupTraits?.toJson());
  return val;
}

DeepLinkData _$DeepLinkDataFromJson(Map<String, dynamic> json) => DeepLinkData(
      json['referringApplication'] as String,
      json['url'] as String,
    );

Map<String, dynamic> _$DeepLinkDataToJson(DeepLinkData instance) =>
    <String, dynamic>{
      'referringApplication': instance.referringApplication,
      'url': instance.url,
    };

SegmentAPISettings _$SegmentAPISettingsFromJson(Map<String, dynamic> json) =>
    SegmentAPISettings(
      json['integrations'] as Map<String, dynamic>,
      middlewareSettings: json['middlewareSettings'] == null
          ? null
          : MiddlewareSettings.fromJson(
              json['middlewareSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SegmentAPISettingsToJson(SegmentAPISettings instance) {
  final val = <String, dynamic>{
    'integrations': instance.integrations,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('middlewareSettings', instance.middlewareSettings?.toJson());
  return val;
}

MiddlewareSettings _$MiddlewareSettingsFromJson(Map<String, dynamic> json) =>
    MiddlewareSettings(
      routingRules: (json['routingRules'] as List<dynamic>?)
              ?.map((e) => RoutingRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MiddlewareSettingsToJson(MiddlewareSettings instance) =>
    <String, dynamic>{
      'routingRules': instance.routingRules.map((e) => e.toJson()).toList(),
    };

RoutingRule _$RoutingRuleFromJson(Map<String, dynamic> json) => RoutingRule(
      json['scope'] as String,
      json['target_type'] as String,
      destinationName: json['destinationName'] as String?,
      matchers: (json['matchers'] as List<dynamic>?)
              ?.map((e) => Matcher.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      transformers: (json['transformers'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) => Transformer.fromJson(e as Map<String, dynamic>))
                  .toList())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RoutingRuleToJson(RoutingRule instance) {
  final val = <String, dynamic>{
    'scope': instance.scope,
    'target_type': instance.targetType,
    'matchers': instance.matchers.map((e) => e.toJson()).toList(),
    'transformers': instance.transformers
        .map((e) => e.map((e) => e.toJson()).toList())
        .toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('destinationName', instance.destinationName);
  return val;
}

Matcher _$MatcherFromJson(Map<String, dynamic> json) => Matcher(
      json['type'] as String,
      json['ir'] as String,
    );

Map<String, dynamic> _$MatcherToJson(Matcher instance) => <String, dynamic>{
      'type': instance.type,
      'ir': instance.ir,
    };

Transformer _$TransformerFromJson(Map<String, dynamic> json) => Transformer(
      json['type'] as String,
      config: json['config'] == null
          ? null
          : TransformerConfig.fromJson(json['config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TransformerToJson(Transformer instance) {
  final val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('config', instance.config?.toJson());
  return val;
}

TransformerConfig _$TransformerConfigFromJson(Map<String, dynamic> json) =>
    TransformerConfig(
      allow: (json['allow'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      drop: (json['drop'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      map: (json['map'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, TransformerConfigMap.fromJson(e as Map<String, dynamic>)),
      ),
      sample: json['sample'] == null
          ? null
          : TransformerConfigSample.fromJson(
              json['sample'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TransformerConfigToJson(TransformerConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('allow', instance.allow);
  writeNotNull('drop', instance.drop);
  writeNotNull('sample', instance.sample?.toJson());
  writeNotNull('map', instance.map?.map((k, e) => MapEntry(k, e.toJson())));
  return val;
}

TransformerConfigSample _$TransformerConfigSampleFromJson(
        Map<String, dynamic> json) =>
    TransformerConfigSample(
      (json['percent'] as num).toInt(),
      json['path'] as String,
    );

Map<String, dynamic> _$TransformerConfigSampleToJson(
        TransformerConfigSample instance) =>
    <String, dynamic>{
      'percent': instance.percent,
      'path': instance.path,
    };

TransformerConfigMap _$TransformerConfigMapFromJson(
        Map<String, dynamic> json) =>
    TransformerConfigMap(
      copy: json['copy'] as String?,
      move: json['move'] as String?,
      set: json['set'],
      enableToString: json['to_string'] as bool?,
    );

Map<String, dynamic> _$TransformerConfigMapToJson(
    TransformerConfigMap instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('set', instance.set);
  writeNotNull('copy', instance.copy);
  writeNotNull('move', instance.move);
  writeNotNull('to_string', instance.enableToString);
  return val;
}
