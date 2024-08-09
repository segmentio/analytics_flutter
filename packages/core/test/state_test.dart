import 'package:segment_analytics/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group("State", () {

    test('UserInfo fromJson method', () {
      final result = UserInfo.fromJson({"anonymousId":"1234567890"});
      expect(result.anonymousId, "1234567890");
    });

    test('SegmentAPISettings fromJson method', () {
      final result = SegmentAPISettings.fromJson({"integrations":{"integrations":"1234567890"}});
      expect(result.integrations, {"integrations":"1234567890"});
    });

    test('RoutingRule fromJson method', () {
      final result = RoutingRule.fromJson({"scope":"scope", "target_type":"1234567890"});
      expect(result.targetType, "1234567890");
    });

    test('MatchTransformerer fromJson method', () {
      final result = Transformer.fromJson({"type":"scope"});
      expect(result.type, "scope");
    });

    test('TransformerConfig fromJson method', () {
      final result = TransformerConfig.fromJson({"allow": {"name":["event"]}});
      expect(result.allow, {"name":["event"]});
    });

    test('TransformerConfigSample fromJson method', () {
      final result = TransformerConfigSample.fromJson({"percent": 1, "path":"/test"});
      expect(result.percent, 1);
    });

    test('TransformerConfigMap fromJson method', () {
      final result = TransformerConfigMap.fromJson({"set": "/test"});
      expect(result.set, "/test");
    });
  });
}
