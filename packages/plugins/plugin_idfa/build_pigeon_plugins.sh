mkdir -p ios/Classes

flutter pub run pigeon \
  --input pigeon/idfa.dart \
  --dart_out lib/native_idfa.dart \
  --experimental_swift_out ios/Classes/Idfa.swift