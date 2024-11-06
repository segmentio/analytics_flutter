import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/native_context.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
part 'event.g.dart';

mixin JSONSerialisable {
  Map<String, dynamic> toJson();
}

enum EventType {
  track('track'),
  identify('identify'),
  screen('screen'),
  group('group'),
  alias('alias');

  final String name;
  const EventType(this.name);

  @override
  String toString() {
    return name;
  }
}

RawEvent eventFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'track':
      return TrackEvent.fromJson(json);
    case 'identify':
      return IdentifyEvent.fromJson(json);
    case 'group':
      return GroupEvent.fromJson(json);
    case 'alias':
      return AliasEvent.fromJson(json);
    case 'screen':
      return ScreenEvent.fromJson(json);
    default:
      throw JSONUnableToDeserialize('event', 'Invalid type: ${json['type']}');
  }
}

abstract class RawEvent with JSONSerialisable {
  final EventType type;
  String? anonymousId;
  String? messageId;
  String? userId;
  String? timestamp;

  Context? context;

  Map<String, dynamic>? integrations;

  @JsonKey(name: "_metadata")
  DestinationMetadata? metadata;

  RawEvent(this.type, {this.anonymousId, this.userId});
}

@JsonSerializable(explicitToJson: true)
class DestinationMetadata {
  List<String> bundled;
  List<String> unbundled;
  List<String> bundledIds;

  DestinationMetadata(
      {this.bundled = const [],
      this.bundledIds = const [],
      this.unbundled = const []});

  factory DestinationMetadata.fromJson(Map<String, dynamic> json) =>
      _$DestinationMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$DestinationMetadataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TrackEvent extends RawEvent {
  String event;
  Map<String, dynamic>? properties;

  TrackEvent(this.event, {this.properties}) : super(EventType.track);

  factory TrackEvent.fromJson(Map<String, dynamic> json) =>
      _$TrackEventFromJson(json);
  @override
  Map<String, dynamic> toJson() => eventToJson(_$TrackEventToJson(this), this);
}

@JsonSerializable(explicitToJson: true)
class IdentifyEvent extends RawEvent {
  UserTraits? traits;
  IdentifyEvent({this.traits, String? userId})
      : super(EventType.identify, userId: userId);

  factory IdentifyEvent.fromJson(Map<String, dynamic> json) =>
      _$IdentifyEventFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      eventToJson(_$IdentifyEventToJson(this), this);
}

@JsonSerializable(explicitToJson: true)
class GroupEvent extends RawEvent {
  String groupId;
  GroupTraits? traits;

  GroupEvent(this.groupId, {this.traits}) : super(EventType.group);

  factory GroupEvent.fromJson(Map<String, dynamic> json) =>
      _$GroupEventFromJson(json);
  @override
  Map<String, dynamic> toJson() => eventToJson(_$GroupEventToJson(this), this);
}

@JsonSerializable(explicitToJson: true)
class AliasEvent extends RawEvent {
  String previousId;

  AliasEvent(this.previousId, {String? userId})
      : super(EventType.alias, userId: userId);

  factory AliasEvent.fromJson(Map<String, dynamic> json) =>
      _$AliasEventFromJson(json);
  @override
  Map<String, dynamic> toJson() => eventToJson(_$AliasEventToJson(this), this);
}

@JsonSerializable(explicitToJson: true)
class ScreenEvent extends RawEvent {
  String name;
  Map<String, dynamic>? properties;

  ScreenEvent(this.name, {this.properties}) : super(EventType.screen);

  factory ScreenEvent.fromJson(Map<String, dynamic> json) =>
      _$ScreenEventFromJson(json);
  @override
  Map<String, dynamic> toJson() => eventToJson(_$ScreenEventToJson(this), this);
}

Map<String, dynamic> eventToJson<T extends RawEvent>(
    Map<String, dynamic> json, T event) {
  json["type"] = event.type.toString();
  return json;
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UserTraits extends JSONExtendableImpl {
  Address? address;
  Company? company;
  int? age;
  String? avatar;
  String? birthday;
  String? createdAt;
  String? description;
  String? email;
  String? firstName;
  String? gender;
  String? id;
  String? lastName;
  String? name;
  String? phone;
  String? title;
  String? username;
  String? website;
  UserTraits(
      {this.address,
      this.age,
      this.avatar,
      this.birthday,
      this.company,
      this.createdAt,
      this.description,
      this.email,
      this.firstName,
      this.gender,
      this.id,
      this.lastName,
      this.name,
      this.phone,
      this.title,
      this.username,
      this.website,
      super.custom});

  factory UserTraits.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$UserTraitsFromJson, UserTraits._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$UserTraitsToJson(this));

  static final Set<String> _builtInKeys = {
    "address",
    "company",
    "age",
    "avatar",
    "birthday",
    "createdAt",
    "description",
    "email",
    "firstName",
    "gender",
    "id",
    "lastName",
    "name",
    "phone",
    "title",
    "username",
    "website"
  };
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class GroupTraits extends JSONExtendableImpl {
  Address? address;
  String? avatar;
  String? createdAt;
  String? description;
  String? email;
  String? employees;
  String? id;
  String? industry;
  String? name;
  String? phone;
  String? website;
  String? plan;

  GroupTraits(
      {this.address,
      this.avatar,
      this.createdAt,
      this.description,
      this.email,
      this.employees,
      this.id,
      this.industry,
      this.name,
      this.phone,
      this.plan,
      this.website,
      super.custom});

  factory GroupTraits.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$GroupTraitsFromJson, GroupTraits._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$GroupTraitsToJson(this));

  static final Set<String> _builtInKeys = {
    "address",
    "avatar",
    "createdAt",
    "description",
    "email",
    "employees",
    "id",
    "industry",
    "name",
    "phone",
    "website",
    "plan"
  };
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Address extends JSONExtendableImpl {
  String? city;
  String? country;
  String? postalCode;
  String? state;
  String? street;

  Address(
      {this.city,
      this.country,
      this.postalCode,
      this.state,
      this.street,
      super.custom});

  factory Address.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(json, _$AddressFromJson, Address._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$AddressToJson(this));

  static final Set<String> _builtInKeys = {
    "city",
    "country",
    "postalCode",
    "state",
    "street"
  };
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Company extends JSONExtendableImpl {
  String? name;
  String? id;
  String? industry;
  int? employeeCount;
  String? plan;

  Company(
      {this.employeeCount,
      this.id,
      this.industry,
      this.name,
      this.plan,
      super.custom});

  factory Company.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(json, _$CompanyFromJson, Company._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$CompanyToJson(this));

  static final Set<String> _builtInKeys = {
    "name",
    "id",
    "industry",
    "employeeCount",
    "plan"
  };
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Context extends JSONExtendableImpl {
  ContextApp app;
  ContextDevice device;
  ContextLibrary library;
  String locale;
  ContextNetwork network;
  ContextOS os;
  ContextScreen screen;
  String timezone;
  String? instanceId;
  UserTraits traits;

  Context(this.app, this.device, this.library, this.locale, this.network,
      this.os, this.screen, this.timezone, this.traits,
      {this.instanceId, super.custom});
  Context.fromNative(NativeContext nativeContext, this.traits)
      : app = nativeContext.app == null
            ? ContextApp("", "", "", "")
            : ContextApp.fromNative(nativeContext.app as NativeContextApp),
        device = nativeContext.device == null
            ? ContextDevice("", "", "", "")
            : ContextDevice.fromNative(
                nativeContext.device as NativeContextDevice),
        library = nativeContext.library == null
            ? ContextLibrary("", "")
            : ContextLibrary.fromNative(
                nativeContext.library as NativeContextLibrary),
        locale = nativeContext.locale ?? "",
        network = nativeContext.network == null
            ? ContextNetwork(false, false)
            : ContextNetwork.fromNative(
                nativeContext.network as NativeContextNetwork),
        os = nativeContext.os == null
            ? ContextOS("", "")
            : ContextOS.fromNative(nativeContext.os as NativeContextOS),
        screen = nativeContext.screen == null
            ? ContextScreen(0, 0)
            : ContextScreen.fromNative(
                nativeContext.screen as NativeContextScreen),
        timezone = nativeContext.timezone ?? "";

  factory Context.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(json, _$ContextFromJson, Context._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$ContextToJson(this));

  static final Set<String> _builtInKeys = {
    "app",
    "device",
    "library",
    "locale",
    "networm",
    "os",
    "screen",
    "timezone",
    "traits"
  };
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ContextApp extends JSONExtendableImpl {
  String build;
  String name;
  String namespace;
  String version;

  ContextApp(this.build, this.name, this.namespace, this.version,
      {super.custom});
  ContextApp.fromNative(NativeContextApp nativeContextApp)
      : build = nativeContextApp.build ?? "",
        name = nativeContextApp.name ?? "",
        namespace = nativeContextApp.namespace ?? "",
        version = nativeContextApp.version ?? "";

  factory ContextApp.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$ContextAppFromJson, ContextApp._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$ContextAppToJson(this));

  static final Set<String> _builtInKeys = {
    "build",
    "name",
    "namespace",
    "version"
  };
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ContextDevice extends JSONExtendableImpl {
  String? id;
  String manufacturer;
  String model;
  String name;
  String type;

  bool? adTrackingEnabled; // ios only
  String? advertisingId; // ios only
  String? trackingStatus;
  String? token;

  ContextDevice(this.manufacturer, this.model, this.name, this.type,
      {this.id,
      this.adTrackingEnabled,
      this.advertisingId,
      this.token,
      this.trackingStatus,
      super.custom});
  ContextDevice.fromNative(NativeContextDevice nativeContextDevice)
      : id = nativeContextDevice.id,
        manufacturer = nativeContextDevice.manufacturer ?? "",
        model = nativeContextDevice.model ?? "",
        name = nativeContextDevice.name ?? "",
        type = nativeContextDevice.type ?? "",
        adTrackingEnabled = nativeContextDevice.adTrackingEnabled,
        advertisingId = nativeContextDevice.advertisingId,
        trackingStatus = nativeContextDevice.trackingStatus,
        token = nativeContextDevice.token;

  factory ContextDevice.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$ContextDeviceFromJson, ContextDevice._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$ContextDeviceToJson(this));

  static final Set<String> _builtInKeys = {
    "id",
    "manufacturer",
    "model",
    "name",
    "type",
    "adTrackingEnabled",
    "advertisingId",
    "trackingStatus",
    "token"
  };
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ContextLibrary extends JSONExtendableImpl {
  String name;
  String version;

  ContextLibrary(this.name, this.version, {super.custom});
  ContextLibrary.fromNative(NativeContextLibrary nativeContextLibrary)
      : name = nativeContextLibrary.name ?? "",
        version = nativeContextLibrary.version ?? "";

  factory ContextLibrary.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$ContextLibraryFromJson, ContextLibrary._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$ContextLibraryToJson(this));

  static final Set<String> _builtInKeys = {"name", "version"};
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ContextOS extends JSONExtendableImpl {
  String name;
  String version;

  ContextOS(this.name, this.version, {super.custom});
  ContextOS.fromNative(NativeContextOS nativeContextOS)
      : name = nativeContextOS.name ?? "",
        version = nativeContextOS.version ?? "";

  factory ContextOS.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$ContextOSFromJson, ContextOS._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$ContextOSToJson(this));

  static final Set<String> _builtInKeys = {"name", "version"};
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ContextNetwork extends JSONExtendableImpl {
  bool cellular;
  bool wifi;

  ContextNetwork(this.cellular, this.wifi, {super.custom});
  ContextNetwork.fromNative(NativeContextNetwork nativeContextNetwork)
      : cellular = nativeContextNetwork.cellular ?? false,
        wifi = nativeContextNetwork.wifi ?? false;

  factory ContextNetwork.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$ContextNetworkFromJson, ContextNetwork._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$ContextNetworkToJson(this));

  static final Set<String> _builtInKeys = {"cellular", "wifi"};
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ContextScreen extends JSONExtendableImpl {
  int height;
  int width;
  double? density; // android only

  ContextScreen(this.height, this.width,
      {this.density, super.custom});
  ContextScreen.fromNative(NativeContextScreen nativeContextScreen)
      : height = nativeContextScreen.height ?? 0,
        width = nativeContextScreen.width ?? 0,
        density = nativeContextScreen.density;

  factory ContextScreen.fromJson(Map<String, dynamic> json) =>
      JSONExtendable.fromJson(
          json, _$ContextScreenFromJson, ContextScreen._builtInKeys);
  Map<String, dynamic> toJson() => _toJson(_$ContextScreenToJson(this));

  static final Set<String> _builtInKeys = {"height", "width", "density"};
}

abstract class JSONExtendableImpl with JSONExtendable {
  @override
  late Map<String, dynamic> custom;
  JSONExtendableImpl({Map<String, dynamic>? custom}) {
    this.custom = custom ?? {};
  }
}

mixin JSONExtendable {
  Map<String, dynamic> get custom;
  Map<String, dynamic> _toJson(Map<String, dynamic> main) {
    Map<String, dynamic> all = {};
    main.forEach((key, value) {
      if (key != "custom") {
        all[key] = value;
      }
    });

    custom.forEach((key, value) {
      all[key] = value;
    });

    return all;
  }

  static T fromJson<T extends JSONExtendable>(Map<String, dynamic> json,
      T Function(Map<String, dynamic>) innerFromJson, Set<String> builtInKeys) {
    if (json.containsKey("custom")) {
      json["custom"] = {"custom": json["custom"]};
    } else {
      final Map<String, dynamic> custom = {};
      json["custom"] = custom;
    }

    final t = innerFromJson(json);

    json.forEach((key, value) {
      if (key != "custom" && !builtInKeys.contains(key)) {
        t.custom[key] = value;
      }
    });
    return t;
  }
}

void applyRawEventData(RawEvent event) {
  event.messageId ??= const Uuid().v4();
  event.timestamp ??= DateTime.now().toUtc().toIso8601String();
}

UserTraits mergeUserTraits(UserTraits a, UserTraits b) {
  return UserTraits(
      address: a.address != null && b.address != null
          ? mergeAddress(a.address as Address, b.address as Address)
          : a.address ?? b.address,
      age: a.age ?? b.age,
      avatar: a.avatar ?? b.avatar,
      birthday: a.birthday ?? b.birthday,
      company: a.company != null && b.company != null
          ? mergeCompany(a.company as Company, b.company as Company)
          : a.company ?? b.company,
      createdAt: a.createdAt ?? b.createdAt,
      description: a.description ?? b.description,
      email: a.email ?? b.email,
      firstName: a.firstName ?? b.firstName,
      gender: a.gender ?? b.gender,
      id: a.id ?? b.id,
      lastName: a.lastName ?? b.lastName,
      name: a.name ?? b.name,
      phone: a.phone ?? b.phone,
      title: a.title ?? b.title,
      username: a.username ?? b.username,
      website: a.website ?? b.website,
      custom: a.custom.isEmpty ? b.custom : a.custom);
}

GroupTraits mergeGroupTraits(GroupTraits a, GroupTraits b) {
  return GroupTraits(
      address: a.address != null && b.address != null
          ? mergeAddress(a.address as Address, b.address as Address)
          : a.address ?? b.address,
      avatar: a.avatar ?? b.avatar,
      createdAt: a.createdAt ?? b.createdAt,
      description: a.description ?? b.description,
      email: a.email ?? b.email,
      employees: a.employees ?? b.employees,
      id: a.id ?? b.id,
      industry: a.industry ?? b.industry,
      name: a.name ?? b.name,
      phone: a.phone ?? b.phone,
      plan: a.plan ?? b.plan,
      website: a.website ?? b.website,
      custom: a.custom.isEmpty ? b.custom : a.custom);
}

Company mergeCompany(Company a, Company b) {
  return Company(
      employeeCount: a.employeeCount ?? b.employeeCount,
      id: a.id ?? b.id,
      industry: a.industry ?? b.industry,
      name: a.name ?? b.name,
      plan: a.plan ?? b.plan);
}

Address mergeAddress(Address a, Address b) {
  return Address(
      city: a.city ?? b.city,
      country: a.country ?? b.country,
      postalCode: a.postalCode ?? b.postalCode,
      state: a.state ?? b.state,
      street: a.street ?? b.street);
}

Context mergeContext(Context a, Context b) {
  return Context(
      a.app,
      mergeContextDevice(a.device, b.device),
      a.library,
      a.locale,
      a.network,
      a.os,
      mergeContextScreen(a.screen, b.screen),
      a.timezone,
      a.traits,
      instanceId: a.instanceId ?? b.instanceId);
}

ContextDevice mergeContextDevice(ContextDevice a, ContextDevice b) {
  return ContextDevice(a.manufacturer, a.model, a.name, a.type,
      adTrackingEnabled: a.adTrackingEnabled ?? b.adTrackingEnabled,
      advertisingId: a.advertisingId ?? b.advertisingId,
      id: a.id ?? b.id,
      token: a.token ?? b.token,
      trackingStatus: a.trackingStatus ?? b.trackingStatus);
}

ContextScreen mergeContextScreen(ContextScreen a, ContextScreen b) {
  return ContextScreen(a.height, b.width, density: a.density ?? b.density);
}
