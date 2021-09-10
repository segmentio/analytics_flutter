import 'package:sovran/store.dart';
import 'package:uuid/uuid.dart';
import 'state.dart';

typedef Json = Map<String, dynamic>;

abstract class RawEvent {
  String? type;
  String? anonymousId;
  String? messageId;
  String? userId;
  String? timestamp;

  Json? context;
  Json? integrations;
  List<Json>? metrics;

  void applyRawEventData(RawEvent? event) {
    if (event != null) {
      anonymousId = event.anonymousId;
      messageId = event.messageId;
      userId = event.userId;
      timestamp = event.timestamp;
      context = event.context;
      integrations = event.integrations;
    }
  }

  RawEvent applyRawEventDataStore(Store store) {
    System? system = store.currentStateOfType<System>();
    UserInfo? userInfo = store.currentStateOfType<UserInfo>();

    var result = this;
    result.anonymousId = userInfo?.anonymousId;
    result.userId = userInfo?.userId;
    result.messageId = Uuid().v1();
    result.timestamp = DateTime.now().toIso8601String();
    result.integrations = system?.integrations;

    return result;
  }
}

class TrackEvent extends RawEvent {
  @override String? type = "track";

  late String event;
  Json? properties;

  TrackEvent(this.event, this.properties);

  TrackEvent.copyConstructor(TrackEvent existing) {
    this.event = existing.event;
    this.properties = existing.properties;
    applyRawEventData(existing);
  }
}

class IdentifyEvent extends RawEvent {
  @override String? type = "identify";

  Json? traits;

  IdentifyEvent({String? userId, Json? traits}) {
    this.userId = userId;
    this.traits = traits;
  }

  IdentifyEvent.copyConstructor(IdentifyEvent existing) {
    this.userId = existing.userId;
    this.traits = existing.traits;
    applyRawEventData(existing);
  }
}

class ScreenEvent extends RawEvent {
  @override String? type = "screen";

  String? name;
  String? category;
  Json? properties;

  ScreenEvent(String? category, {String? name, Json? properties}) {
    this.name = name;
    this.category = category;
    this.properties = properties;
  }

  ScreenEvent.copyConstructor(ScreenEvent existing) {
    this.name = existing.name;
    this.category = existing.category;
    this.properties = existing.properties;
    applyRawEventData(existing);
  }
}

class GroupEvent extends RawEvent {
  @override String? type = "group";

  String? groupId;
  Json? traits;

  GroupEvent({String? groupId, Json? traits}) {
    this.groupId = groupId;
    this.traits = traits;
  }

  GroupEvent.copyConstructor(GroupEvent existing) {
    this.groupId = existing.groupId;
    this.traits = existing.traits;
    applyRawEventData(existing);
  }
}

class AliasEvent extends RawEvent {
  @override String? type = "alias";

  String? userId;
  String? previousId;

  AliasEvent(String? newId) {
    this.userId = newId;
  }

  AliasEvent.copyConstructor(AliasEvent existing) {
    this.userId = existing.userId;
    applyRawEventData(existing);
  }
}