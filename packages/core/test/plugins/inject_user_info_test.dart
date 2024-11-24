// test/inject_token_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugins/inject_user_info.dart';
import 'package:segment_analytics/state.dart';

import '../mocks/mocks.dart';


void main() {
  String writeKey = '123';
  List<RawEvent> batch = [
    TrackEvent("Event 1"),
    TrackEvent("Event 2"),
    TrackEvent("Event 3"),
  ];
  group('Inject User Info Tests', () {
    late InjectUserInfo userInfo;
    final UserTraits userT = UserTraits(firstName: "Christy", custom: {"myCustomTrait": "customValue"});
    final GroupTraits groupT = GroupTraits(name: "abc");

    setUp(() async {
      AnalyticsPlatform.instance = MockPlatform();
    });
 
    test('should inject user info into event context', () async {
      final httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));
      Analytics analytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              appStateStream: () => Mocks.streamSubscription()),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await analytics.init();

      userInfo = InjectUserInfo();
      UserInfo user = UserInfo("abcdefg123456789", userTraits: userT, groupTraits: groupT);
      analytics.state.userInfo.setState(user);
      // ignore: invalid_use_of_protected_member
      userInfo.pAnalytics = analytics;

      final resultEvent = await userInfo.execute(IdentifyEvent(traits: userT));
      final resultEvent1 = await userInfo.execute(AliasEvent("123"));
      final resultEvent2 = await userInfo.execute(GroupEvent("abc", traits: groupT));

      expect(resultEvent.anonymousId, 'abcdefg123456789');
      expect(resultEvent1.anonymousId, 'abcdefg123456789');
      expect(resultEvent2.anonymousId, 'abcdefg123456789');
    });
  });
}
