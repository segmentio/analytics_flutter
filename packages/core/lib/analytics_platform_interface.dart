import 'package:analytics/analytics_web.dart'
    if (dart.library.io) 'package:analytics/analytics_pigeon.dart';
import 'package:analytics/native_context.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AnalyticsPlatform extends PlatformInterface {
  /// Constructs a AnalyticsPlatform.
  AnalyticsPlatform() : super(token: _token);

  static final Object _token = Object();

  static AnalyticsPlatform _instance = AnalyticsPlatformImpl();

  /// The default instance of [AnalyticsPlatform] to use.
  ///
  /// Defaults to [MethodChannelAnalytics].
  static AnalyticsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AnalyticsPlatform] when
  /// they register themselves.
  static set instance(AnalyticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<NativeContext> getContext({bool collectDeviceId = false}) =>
      throw UnimplementedError('platformVersion() has not been implemented.');

  /// A broadcast stream for receiving incoming link change events.
  ///
  /// The [Stream] emits opened links as [String]s.
  Stream<Map<String, dynamic>> get linkStream => throw UnimplementedError(
      'getLinksStream has not been implemented on the current platform.');
}
