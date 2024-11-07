import 'dart:async';
import 'dart:io';

import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:segment_analytics/utils/lifecycle/fgbg.dart';
import 'package:segment_analytics/utils/lifecycle/widget_observer.dart';
import 'package:flutter/foundation.dart';

enum AppStatus { foreground, background }

abstract class LifeCycle extends Stream<AppStatus> {}

@visibleForTesting
LifeCycle getLifecycleStream() {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // For iOS and Android we will use the FgBg Lifecycle listener as it reports directly from native level
    // ignoring native popups
    return FGBGLifecycle(FGBGEvents.instance.stream);
  } else {
    // For Web and Desktop we use the WidgetObserver implementation directly from Flutter
    // TBF Flutter doesn't have a very reliable background signal for those platforms
    return WidgetObserverLifecycle();
  }
}

final LifeCycle lifecycle = getLifecycleStream();
