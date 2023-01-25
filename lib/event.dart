// Event
import 'types.dart';

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

  String toJson() {
    return name;
  }
}

abstract class SegmentEvent {
  EventType type;
  late String anonymousId;
  late String messageId;
  String? userId;
  late String timestamp;
  late JSONMap context;
  late JSONMap integrations;
  late DestinationMetadata metadata; // _metadata when serialized

  SegmentEvent({required this.type});
}

class IdentifyEvent extends SegmentEvent {
  JSONMap? traits;

  IdentifyEvent({required String userId, this.traits})
      : super(type: EventType.identify) {
    this.userId = userId;
  }
}

class AliasEvent extends SegmentEvent {
  String previousId;

  AliasEvent({required this.previousId, String? userId})
      : super(type: EventType.alias) {
    this.userId = userId;
  }
}

class GroupEvent extends SegmentEvent {
  JSONMap? traits;
  String groupId;

  GroupEvent({required this.groupId, this.traits})
      : super(type: EventType.group);
}

class ScreenEvent extends SegmentEvent {
  String name;
  JSONMap? properties;

  ScreenEvent({required this.name, this.properties})
      : super(type: EventType.screen);
}

class TrackEvent extends SegmentEvent {
  String name;
  JSONMap? properties;

  TrackEvent({required this.name, this.properties})
      : super(type: EventType.track);
}

class DestinationMetadata {}
