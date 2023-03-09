import 'package:analytics/event.dart';
import 'package:analytics/plugin.dart';
import 'package:analytics/state.dart';

class InjectUserInfo extends PlatformPlugin {
  InjectUserInfo() : super(PluginType.before);

  @override
  Future<RawEvent> execute(RawEvent event) async {
    final userInfo = await analytics!.state.userInfo.state;
    event.anonymousId = userInfo.anonymousId;
    if (event.type == EventType.identify) {
      final identityEvent = event as IdentifyEvent;
      final mergedTraits = identityEvent.traits != null
          ? (userInfo.userTraits != null
              ? mergeUserTraits(identityEvent.traits as UserTraits,
                  userInfo.userTraits as UserTraits)
              : identityEvent.traits)
          : userInfo.userTraits;
      analytics!.state.userInfo.setState(UserInfo(
          event.anonymousId ?? userInfo.anonymousId,
          userId: event.userId ?? userInfo.userId,
          userTraits: mergedTraits,
          groupTraits: userInfo.groupTraits));

      identityEvent.traits = mergedTraits;
    } else if (event.type == EventType.alias) {
      final previousAnonId = userInfo.anonymousId;
      final previousUserId = userInfo.userId;
      analytics!.state.userInfo.setState(UserInfo(
          event.anonymousId ?? userInfo.anonymousId,
          userId: event.userId,
          userTraits: userInfo.userTraits,
          groupTraits: userInfo.groupTraits));
      (event as AliasEvent).previousId = previousUserId ?? previousAnonId;
    } else if (event.type == EventType.group) {
      final groupEvent = event as GroupEvent;
      final mergedTraits = groupEvent.traits != null
          ? (userInfo.groupTraits != null
              ? mergeGroupTraits(groupEvent.traits as GroupTraits,
                  userInfo.groupTraits as GroupTraits)
              : groupEvent.traits)
          : userInfo.groupTraits;
      analytics!.state.userInfo.setState(UserInfo(
          event.anonymousId ?? userInfo.anonymousId,
          userId: event.userId ?? userInfo.userId,
          userTraits: userInfo.userTraits,
          groupTraits: mergedTraits));

      groupEvent.traits = mergedTraits;
    }

    event.userId ??= userInfo.userId;
    event.anonymousId ??= userInfo.anonymousId;

    return event;
  }
}
