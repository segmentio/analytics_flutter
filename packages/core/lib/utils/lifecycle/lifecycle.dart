import 'dart:async';
import 'dart:io';

import 'package:analytics/utils/lifecycle/fgbg.dart';
import 'package:analytics/utils/lifecycle/widget_observer.dart';
import 'package:flutter/foundation.dart';

enum AppStatus { foreground, background }

abstract class LifeCycle extends Stream<AppStatus> {}

LifeCycle _getLifecycleStream() {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // For iOS and Android we will use the FgBg Lifecycle listener as it reports directly from native level
    // ignoring native popups
    return FGBGLifecycle();
  } else {
    // For Web and Desktop we use the WidgetObserver implementation directly from Flutter
    // TBF Flutter doesn't have a very reliable background signal for those platforms
    return WidgetObserverLifecycle();
  }
}

final LifeCycle lifecycle = _getLifecycleStream();
