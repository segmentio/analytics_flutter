import 'package:analytics/event.dart';

mixin ClientMethods {
  Future track(String event, {Map<String, dynamic>? properties});
  Future screen(String name, {Map<String, dynamic>? properties});
  Future identify({String? userId, UserTraits? userTraits});
  Future group(String groupId, {GroupTraits? groupTraits});
  Future alias(String newUserId);
  Future flush();
  Future reset({bool? resetAnonymousId});
}
