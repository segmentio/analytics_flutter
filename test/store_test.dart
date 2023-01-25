import 'package:analytics_flutter/store.dart';
import 'package:flutter_test/flutter_test.dart';

class SimpleState {
  String one;
  String two;

  SimpleState({required this.one, required this.two});
}

void main() {
  test('holds state, listeners work', () async {
    final store = ConcurrencySafeState<String>("");
    const newValue = "newValue";

    store.addListener(() async {
      final currentValue = await store.getValue();
      expect(currentValue, newValue);
    });

    var current = await store.getValue();
    expect(current, "");

    await store.setValue((currentValue) => Future.value(newValue));
    current = await store.getValue();
    expect(current, newValue);
  });

  test('is concurrency safe', () async {
    final store = ConcurrencySafeState(SimpleState(one: "one", two: "two"));

    // We're triggering 2 updates to the store that we don't await,
    // however we await the getValue, we expect the getter to return only after
    // the ops are done

    final op1 = store.setValue(
        (currentValue) => Future.delayed(const Duration(seconds: 1), () {
              currentValue.one = "1";
              return currentValue;
            }));

    final op2 = store.setValue(
        (currentValue) => Future.delayed(const Duration(seconds: 1), () {
              currentValue.two = "2";
              return currentValue;
            }));

    final current = await store.getValue();
    expect(current.one, "1");
    expect(current.two, "2");
  });
}
