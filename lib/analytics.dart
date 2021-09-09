import 'package:sovran/store.dart';
import 'timeline.dart';
import 'configuration.dart';
import 'storage.dart';

class Analytics {

  // Internal properties
  late final Configuration _configuration;
  late final Store _store;
  late final Storage _storage;

  // Public properties
  late final Timeline timeline;


  Analytics(Configuration configuration) {
    this._configuration = configuration;
    this._store = Store();
    this._storage = Storage(this._store, this._configuration.values.writeKey);
    this.timeline = new Timeline();

    // Provide default state

    // Get started
  }
}