mkdir -p ios/segment_analytics_plugin_idfa/Sources/segment_analytics_plugin_idfa

flutter pub run pigeon \
  --input pigeon/idfa.dart \
  --dart_out lib/native_idfa.dart \
  --experimental_swift_out ios/segment_analytics_plugin_idfa/Sources/segment_analytics_plugin_idfa/Idfa.swift