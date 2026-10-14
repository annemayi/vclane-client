import 'dart:async';

extension StreamHelpers<T> on Stream<T> {
  Stream<T> throttle(Duration duration) {
    DateTime? lastEmit;
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          final now = DateTime.now();
          if (lastEmit == null || now.difference(lastEmit!) >= duration) {
            lastEmit = now;
            sink.add(data);
          }
        },
      ),
    );
  }
}
