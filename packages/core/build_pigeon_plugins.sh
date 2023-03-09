mkdir -p ios/Classes
mkdir -p android/main/kotlin

flutter pub run pigeon \
  --input pigeon/context.dart \
  --dart_out lib/native_context.dart \
  --experimental_swift_out ios/Classes/Context.swift \
  --experimental_kotlin_out android/src/main/kotlin/com/segment/analytics/Context.kt \
  --java_package "com.segment.flutter"