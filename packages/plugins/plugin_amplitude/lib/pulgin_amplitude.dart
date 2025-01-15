import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:amplitude_flutter/amplitude.dart';

class AmplitudePlugin extends DestinationPlugin {
  final String apiKey;
  final String instanceName;
  late Amplitude _amplitudeInstance;

  AmplitudePlugin(this.apiKey, this.instanceName) : super('amplitude') {
    _amplitudeInstance = Amplitude.getInstance(instanceName: instanceName);
  }

  @override
  void configure(Analytics analytics) {
    super.configure(analytics);
    _amplitudeInstance.init(apiKey);
  }

  @override
  Future<RawEvent?> track(TrackEvent event) async {
    await _amplitudeInstance.logEvent(event.event, eventProperties: event.properties);
    return event;
  }

  @override
  Future<RawEvent?> identify(IdentifyEvent event) async {
    await _amplitudeInstance.setUserId(event.userId);
    if (event.traits != null) {
      final Identify identify = Identify();
      await Future.wait(event.traits!.toJson().entries.map((entry) async {
        identify.set(entry.key, entry.value.toString());
      }));
      _amplitudeInstance.identify(identify);
    }
    return event;
  }

  @override
  Future flush() async {
    _amplitudeInstance.uploadEvents();
  }

  @override
  void reset() {
    _amplitudeInstance.setUserId(null);
    _amplitudeInstance.clearUserProperties();
  }

}
