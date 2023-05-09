import 'package:analytics/utils/queue.dart';
import 'package:flutter_test/flutter_test.dart';

class SimpleState {
  String one;
  String two;

  SimpleState({required this.one, required this.two});
}

void main() {
  test('handles multiple operations in a sync queue', () async {
    final queue = ConcurrencyQueue<int>();
    var counter = 0;

    final future1 =
        queue.enqueue(() => Future.delayed(const Duration(seconds: 2), () {
              counter++;
              return counter;
            }));

    final future2 =
        queue.enqueue(() => Future.delayed(const Duration(seconds: 1), () {
              counter++;
              return counter;
            }));

    // Future2 will execute after future1 regardless if we await for it first
    final result2 = await future2;
    expect(result2, 2);

    final result1 = await future1;
    expect(result1, 1);
  });
}
