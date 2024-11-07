// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DestinationMetadata _$DestinationMetadataFromJson(Map<String, dynamic> json) =>
    DestinationMetadata(
      bundled: (json['bundled'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bundledIds: (json['bundledIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      unbundled: (json['unbundled'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DestinationMetadataToJson(
        DestinationMetadata instance) =>
    <String, dynamic>{
      'bundled': instance.bundled,
      'unbundled': instance.unbundled,
      'bundledIds': instance.bundledIds,
    };

TrackEvent _$TrackEventFromJson(Map<String, dynamic> json) => TrackEvent(
      json['event'] as String,
      properties: json['properties'] as Map<String, dynamic>?,
    )
      ..anonymousId = json['anonymousId'] as String?
      ..messageId = json['messageId'] as String?
      ..userId = json['userId'] as String?
      ..timestamp = json['timestamp'] as String?
      ..context = json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>)
      ..integrations = json['integrations'] as Map<String, dynamic>?
      ..metadata = json['_metadata'] == null
          ? null
          : DestinationMetadata.fromJson(
              json['_metadata'] as Map<String, dynamic>);

Map<String, dynamic> _$TrackEventToJson(TrackEvent instance) =>
    <String, dynamic>{
      'anonymousId': instance.anonymousId,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
      'context': instance.context?.toJson(),
      'integrations': instance.integrations,
      '_metadata': instance.metadata?.toJson(),
      'event': instance.event,
      'properties': instance.properties,
    };

IdentifyEvent _$IdentifyEventFromJson(Map<String, dynamic> json) =>
    IdentifyEvent(
      traits: json['traits'] == null
          ? null
          : UserTraits.fromJson(json['traits'] as Map<String, dynamic>),
      userId: json['userId'] as String?,
    )
      ..anonymousId = json['anonymousId'] as String?
      ..messageId = json['messageId'] as String?
      ..timestamp = json['timestamp'] as String?
      ..context = json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>)
      ..integrations = json['integrations'] as Map<String, dynamic>?
      ..metadata = json['_metadata'] == null
          ? null
          : DestinationMetadata.fromJson(
              json['_metadata'] as Map<String, dynamic>);

Map<String, dynamic> _$IdentifyEventToJson(IdentifyEvent instance) =>
    <String, dynamic>{
      'anonymousId': instance.anonymousId,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
      'context': instance.context?.toJson(),
      'integrations': instance.integrations,
      '_metadata': instance.metadata?.toJson(),
      'traits': instance.traits?.toJson(),
    };

GroupEvent _$GroupEventFromJson(Map<String, dynamic> json) => GroupEvent(
      json['groupId'] as String,
      traits: json['traits'] == null
          ? null
          : GroupTraits.fromJson(json['traits'] as Map<String, dynamic>),
    )
      ..anonymousId = json['anonymousId'] as String?
      ..messageId = json['messageId'] as String?
      ..userId = json['userId'] as String?
      ..timestamp = json['timestamp'] as String?
      ..context = json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>)
      ..integrations = json['integrations'] as Map<String, dynamic>?
      ..metadata = json['_metadata'] == null
          ? null
          : DestinationMetadata.fromJson(
              json['_metadata'] as Map<String, dynamic>);

Map<String, dynamic> _$GroupEventToJson(GroupEvent instance) =>
    <String, dynamic>{
      'anonymousId': instance.anonymousId,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
      'context': instance.context?.toJson(),
      'integrations': instance.integrations,
      '_metadata': instance.metadata?.toJson(),
      'groupId': instance.groupId,
      'traits': instance.traits?.toJson(),
    };

AliasEvent _$AliasEventFromJson(Map<String, dynamic> json) => AliasEvent(
      json['previousId'] as String,
      userId: json['userId'] as String?,
    )
      ..anonymousId = json['anonymousId'] as String?
      ..messageId = json['messageId'] as String?
      ..timestamp = json['timestamp'] as String?
      ..context = json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>)
      ..integrations = json['integrations'] as Map<String, dynamic>?
      ..metadata = json['_metadata'] == null
          ? null
          : DestinationMetadata.fromJson(
              json['_metadata'] as Map<String, dynamic>);

Map<String, dynamic> _$AliasEventToJson(AliasEvent instance) =>
    <String, dynamic>{
      'anonymousId': instance.anonymousId,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
      'context': instance.context?.toJson(),
      'integrations': instance.integrations,
      '_metadata': instance.metadata?.toJson(),
      'previousId': instance.previousId,
    };

ScreenEvent _$ScreenEventFromJson(Map<String, dynamic> json) => ScreenEvent(
      json['name'] as String,
      properties: json['properties'] as Map<String, dynamic>?,
    )
      ..anonymousId = json['anonymousId'] as String?
      ..messageId = json['messageId'] as String?
      ..userId = json['userId'] as String?
      ..timestamp = json['timestamp'] as String?
      ..context = json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>)
      ..integrations = json['integrations'] as Map<String, dynamic>?
      ..metadata = json['_metadata'] == null
          ? null
          : DestinationMetadata.fromJson(
              json['_metadata'] as Map<String, dynamic>);

Map<String, dynamic> _$ScreenEventToJson(ScreenEvent instance) =>
    <String, dynamic>{
      'anonymousId': instance.anonymousId,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
      'context': instance.context?.toJson(),
      'integrations': instance.integrations,
      '_metadata': instance.metadata?.toJson(),
      'name': instance.name,
      'properties': instance.properties,
    };

UserTraits _$UserTraitsFromJson(Map<String, dynamic> json) => UserTraits(
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      age: (json['age'] as num?)?.toInt(),
      avatar: json['avatar'] as String?,
      birthday: json['birthday'] as String?,
      company: json['company'] == null
          ? null
          : Company.fromJson(json['company'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      description: json['description'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      gender: json['gender'] as String?,
      id: json['id'] as String?,
      lastName: json['lastName'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      title: json['title'] as String?,
      username: json['username'] as String?,
      website: json['website'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserTraitsToJson(UserTraits instance) {
  final val = <String, dynamic>{
    'custom': instance.custom,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('address', instance.address?.toJson());
  writeNotNull('company', instance.company?.toJson());
  writeNotNull('age', instance.age);
  writeNotNull('avatar', instance.avatar);
  writeNotNull('birthday', instance.birthday);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('description', instance.description);
  writeNotNull('email', instance.email);
  writeNotNull('firstName', instance.firstName);
  writeNotNull('gender', instance.gender);
  writeNotNull('id', instance.id);
  writeNotNull('lastName', instance.lastName);
  writeNotNull('name', instance.name);
  writeNotNull('phone', instance.phone);
  writeNotNull('title', instance.title);
  writeNotNull('username', instance.username);
  writeNotNull('website', instance.website);
  return val;
}

GroupTraits _$GroupTraitsFromJson(Map<String, dynamic> json) => GroupTraits(
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String?,
      description: json['description'] as String?,
      email: json['email'] as String?,
      employees: json['employees'] as String?,
      id: json['id'] as String?,
      industry: json['industry'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      plan: json['plan'] as String?,
      website: json['website'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GroupTraitsToJson(GroupTraits instance) {
  final val = <String, dynamic>{
    'custom': instance.custom,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('address', instance.address?.toJson());
  writeNotNull('avatar', instance.avatar);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('description', instance.description);
  writeNotNull('email', instance.email);
  writeNotNull('employees', instance.employees);
  writeNotNull('id', instance.id);
  writeNotNull('industry', instance.industry);
  writeNotNull('name', instance.name);
  writeNotNull('phone', instance.phone);
  writeNotNull('website', instance.website);
  writeNotNull('plan', instance.plan);
  return val;
}

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      state: json['state'] as String?,
      street: json['street'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) {
  final val = <String, dynamic>{
    'custom': instance.custom,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('city', instance.city);
  writeNotNull('country', instance.country);
  writeNotNull('postalCode', instance.postalCode);
  writeNotNull('state', instance.state);
  writeNotNull('street', instance.street);
  return val;
}

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
      employeeCount: (json['employeeCount'] as num?)?.toInt(),
      id: json['id'] as String?,
      industry: json['industry'] as String?,
      name: json['name'] as String?,
      plan: json['plan'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CompanyToJson(Company instance) {
  final val = <String, dynamic>{
    'custom': instance.custom,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('id', instance.id);
  writeNotNull('industry', instance.industry);
  writeNotNull('employeeCount', instance.employeeCount);
  writeNotNull('plan', instance.plan);
  return val;
}

Context _$ContextFromJson(Map<String, dynamic> json) => Context(
      ContextApp.fromJson(json['app'] as Map<String, dynamic>),
      ContextDevice.fromJson(json['device'] as Map<String, dynamic>),
      ContextLibrary.fromJson(json['library'] as Map<String, dynamic>),
      json['locale'] as String,
      ContextNetwork.fromJson(json['network'] as Map<String, dynamic>),
      ContextOS.fromJson(json['os'] as Map<String, dynamic>),
      ContextScreen.fromJson(json['screen'] as Map<String, dynamic>),
      json['timezone'] as String,
      UserTraits.fromJson(json['traits'] as Map<String, dynamic>),
      instanceId: json['instanceId'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextToJson(Context instance) {
  final val = <String, dynamic>{
    'custom': instance.custom,
    'app': instance.app.toJson(),
    'device': instance.device.toJson(),
    'library': instance.library.toJson(),
    'locale': instance.locale,
    'network': instance.network.toJson(),
    'os': instance.os.toJson(),
    'screen': instance.screen.toJson(),
    'timezone': instance.timezone,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('instanceId', instance.instanceId);
  val['traits'] = instance.traits.toJson();
  return val;
}

ContextApp _$ContextAppFromJson(Map<String, dynamic> json) => ContextApp(
      json['build'] as String,
      json['name'] as String,
      json['namespace'] as String,
      json['version'] as String,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextAppToJson(ContextApp instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'build': instance.build,
      'name': instance.name,
      'namespace': instance.namespace,
      'version': instance.version,
    };

ContextDevice _$ContextDeviceFromJson(Map<String, dynamic> json) =>
    ContextDevice(
      json['manufacturer'] as String,
      json['model'] as String,
      json['name'] as String,
      json['type'] as String,
      id: json['id'] as String?,
      adTrackingEnabled: json['adTrackingEnabled'] as bool?,
      advertisingId: json['advertisingId'] as String?,
      token: json['token'] as String?,
      trackingStatus: json['trackingStatus'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextDeviceToJson(ContextDevice instance) {
  final val = <String, dynamic>{
    'custom': instance.custom,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['manufacturer'] = instance.manufacturer;
  val['model'] = instance.model;
  val['name'] = instance.name;
  val['type'] = instance.type;
  writeNotNull('adTrackingEnabled', instance.adTrackingEnabled);
  writeNotNull('advertisingId', instance.advertisingId);
  writeNotNull('trackingStatus', instance.trackingStatus);
  writeNotNull('token', instance.token);
  return val;
}

ContextLibrary _$ContextLibraryFromJson(Map<String, dynamic> json) =>
    ContextLibrary(
      json['name'] as String,
      json['version'] as String,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextLibraryToJson(ContextLibrary instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'name': instance.name,
      'version': instance.version,
    };

ContextOS _$ContextOSFromJson(Map<String, dynamic> json) => ContextOS(
      json['name'] as String,
      json['version'] as String,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextOSToJson(ContextOS instance) => <String, dynamic>{
      'custom': instance.custom,
      'name': instance.name,
      'version': instance.version,
    };

ContextNetwork _$ContextNetworkFromJson(Map<String, dynamic> json) =>
    ContextNetwork(
      json['cellular'] as bool,
      json['wifi'] as bool,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextNetworkToJson(ContextNetwork instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'cellular': instance.cellular,
      'wifi': instance.wifi,
    };

ContextScreen _$ContextScreenFromJson(Map<String, dynamic> json) =>
    ContextScreen(
      (json['height'] as num).toInt(),
      (json['width'] as num).toInt(),
      density: (json['density'] as num?)?.toDouble(),
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextScreenToJson(ContextScreen instance) {
  final val = <String, dynamic>{
    'custom': instance.custom,
    'height': instance.height,
    'width': instance.width,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('density', instance.density);
  return val;
}
