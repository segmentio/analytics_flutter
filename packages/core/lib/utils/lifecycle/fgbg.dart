import 'dart:async';

import 'package:segment_analytics/utils/lifecycle/lifecycle.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

class FGBGLifecycle extends LifeCycle {
  final Stream<FGBGType> stream;

  FGBGLifecycle(this.stream);

  @override
  StreamSubscription<AppStatus> listen(void Function(AppStatus event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return stream
        .map((event) => (event == FGBGType.foreground)
            ? AppStatus.foreground
            : AppStatus.background)
        .listen(onData, onDone: onDone, onError: onError);
  }
}
