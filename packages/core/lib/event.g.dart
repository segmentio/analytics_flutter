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
      integrations: json['integrations'] as Map<String, dynamic>?,
    )
      ..anonymousId = json['anonymousId'] as String?
      ..messageId = json['messageId'] as String?
      ..userId = json['userId'] as String?
      ..timestamp = json['timestamp'] as String?
      ..context = json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>)
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
      integrations: json['integrations'] as Map<String, dynamic>?,
    )
      ..anonymousId = json['anonymousId'] as String?
      ..messageId = json['messageId'] as String?
      ..userId = json['userId'] as String?
      ..timestamp = json['timestamp'] as String?
      ..context = json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>)
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

Map<String, dynamic> _$UserTraitsToJson(UserTraits instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      if (instance.address?.toJson() case final value?) 'address': value,
      if (instance.company?.toJson() case final value?) 'company': value,
      if (instance.age case final value?) 'age': value,
      if (instance.avatar case final value?) 'avatar': value,
      if (instance.birthday case final value?) 'birthday': value,
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.description case final value?) 'description': value,
      if (instance.email case final value?) 'email': value,
      if (instance.firstName case final value?) 'firstName': value,
      if (instance.gender case final value?) 'gender': value,
      if (instance.id case final value?) 'id': value,
      if (instance.lastName case final value?) 'lastName': value,
      if (instance.name case final value?) 'name': value,
      if (instance.phone case final value?) 'phone': value,
      if (instance.title case final value?) 'title': value,
      if (instance.username case final value?) 'username': value,
      if (instance.website case final value?) 'website': value,
    };

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

Map<String, dynamic> _$GroupTraitsToJson(GroupTraits instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      if (instance.address?.toJson() case final value?) 'address': value,
      if (instance.avatar case final value?) 'avatar': value,
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.description case final value?) 'description': value,
      if (instance.email case final value?) 'email': value,
      if (instance.employees case final value?) 'employees': value,
      if (instance.id case final value?) 'id': value,
      if (instance.industry case final value?) 'industry': value,
      if (instance.name case final value?) 'name': value,
      if (instance.phone case final value?) 'phone': value,
      if (instance.website case final value?) 'website': value,
      if (instance.plan case final value?) 'plan': value,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      state: json['state'] as String?,
      street: json['street'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'custom': instance.custom,
      if (instance.city case final value?) 'city': value,
      if (instance.country case final value?) 'country': value,
      if (instance.postalCode case final value?) 'postalCode': value,
      if (instance.state case final value?) 'state': value,
      if (instance.street case final value?) 'street': value,
    };

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
      employeeCount: (json['employeeCount'] as num?)?.toInt(),
      id: json['id'] as String?,
      industry: json['industry'] as String?,
      name: json['name'] as String?,
      plan: json['plan'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'custom': instance.custom,
      if (instance.name case final value?) 'name': value,
      if (instance.id case final value?) 'id': value,
      if (instance.industry case final value?) 'industry': value,
      if (instance.employeeCount case final value?) 'employeeCount': value,
      if (instance.plan case final value?) 'plan': value,
    };

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

Map<String, dynamic> _$ContextToJson(Context instance) => <String, dynamic>{
      'custom': instance.custom,
      'app': instance.app.toJson(),
      'device': instance.device.toJson(),
      'library': instance.library.toJson(),
      'locale': instance.locale,
      'network': instance.network.toJson(),
      'os': instance.os.toJson(),
      'screen': instance.screen.toJson(),
      'timezone': instance.timezone,
      if (instance.instanceId case final value?) 'instanceId': value,
      'traits': instance.traits.toJson(),
    };

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

Map<String, dynamic> _$ContextDeviceToJson(ContextDevice instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      if (instance.id case final value?) 'id': value,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'name': instance.name,
      'type': instance.type,
      if (instance.adTrackingEnabled case final value?)
        'adTrackingEnabled': value,
      if (instance.advertisingId case final value?) 'advertisingId': value,
      if (instance.trackingStatus case final value?) 'trackingStatus': value,
      if (instance.token case final value?) 'token': value,
    };

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
      json['bluetooth'] as bool,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextNetworkToJson(ContextNetwork instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'cellular': instance.cellular,
      'wifi': instance.wifi,
      'bluetooth': instance.bluetooth,
    };

ContextScreen _$ContextScreenFromJson(Map<String, dynamic> json) =>
    ContextScreen(
      (json['height'] as num).toInt(),
      (json['width'] as num).toInt(),
      density: (json['density'] as num?)?.toDouble(),
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ContextScreenToJson(ContextScreen instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'height': instance.height,
      'width': instance.width,
      if (instance.density case final value?) 'density': value,
    };
