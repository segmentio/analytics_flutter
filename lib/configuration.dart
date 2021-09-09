
class Configuration {
  late final Values _values;
  Configuration(String writeKey) {
    this._values = Values._(writeKey);
  }

  Configuration application(dynamic application) {
    _values._application = application;
    return this;
  }

  Configuration trackApplicationLifecycleEvents(bool enabled) {
    _values._trackApplicationLifecycleEvents = enabled;
    return this;
  }

  Configuration trackDeeplinks(bool enabled) {
    _values._trackDeepLinks = enabled;
    return this;
  }

  Configuration flushAt(int count) {
    _values._flushAt = count;
    return this;
  }

  Configuration flushInterval(int interval) {
    _values._flushInterval = interval;
    return this;
  }

  Configuration defaultSettings(Settings settings) {
    _values._defaultSettings = settings;
    return this;
  }

  Configuration autoAddSegmentDestination(bool shouldAdd) {
    _values._autoAddSegmentDestination = shouldAdd;
    return this;
  }

  Configuration apiHost(String host) {
    _values._apiHost = host;
    return this;
  }

  Configuration cdnHost(String host) {
    _values._cdnHost = host;
    return this;
  }
}

class Values {
  late final String _writeKey;
  dynamic _application;
  bool _trackApplicationLifecycleEvents = true;
  bool _trackDeepLinks = true;
  int _flushAt = 20;
  int _flushInterval = 30;
  Settings? _defaultSettings = null;
  bool _autoAddSegmentDestination = true;
  String _apiHost = HTTPClient.getDefaultAPIHost();
  String _cdnHost = HTTPClient.getDefaultCDNHost();

  Values._(this._writeKey);
}