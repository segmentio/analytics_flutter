import 'package:pigeon/pigeon.dart';

enum TrackingStatus { authorized, denied, notDetermined, restricted, unknown }

class NativeIdfaData {
  bool? adTrackingEnabled;
  String? advertisingId;
  TrackingStatus? trackingStatus;
}

@HostApi()
abstract class NativeIdfaApi {
  @async
  NativeIdfaData getTrackingAuthorizationStatus();
}
