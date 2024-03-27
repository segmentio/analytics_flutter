import 'package:segment_analytics/utils/store/impl.dart';

mixin Store {
  Future<Map<String, dynamic>?> getPersisted(String key);

  Future setPersisted(String key, Map<String, dynamic> value);

  Future get ready;

  void dispose();
}

StoreImpl storeFactory() {
  return StoreImpl();
}
