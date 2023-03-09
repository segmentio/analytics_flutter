import 'package:pigeon/pigeon.dart';

class NativeContext {
  NativeContextApp? app;
  NativeContextDevice? device;
  NativeContextLibrary? library;
  String? locale;
  NativeContextNetwork? network;
  NativeContextOS? os;
  NativeContextScreen? screen;
  String? timezone;
  String? userAgent;
}

class NativeContextApp {
  String? build;
  String? name;
  String? namespace;
  String? version;
}

class NativeContextDevice {
  String? id;
  String? manufacturer;
  String? model;
  String? name;
  String? type;

  bool? adTrackingEnabled; // ios only
  String? advertisingId; // ios only
  String? trackingStatus;
  String? token;
}

class NativeContextLibrary {
  String? name;
  String? version;
}

class NativeContextOS {
  String? name;
  String? version;
}

class NativeContextNetwork {
  bool? cellular;
  bool? wifi;
  bool? bluetooth;
}

class NativeContextScreen {
  int? height;
  int? width;
  double? density; // android only
}

@HostApi()
abstract class NativeContextApi {
  @async
  NativeContext getContext(bool collectDeviceId);
}
