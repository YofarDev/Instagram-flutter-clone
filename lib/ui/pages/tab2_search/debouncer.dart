import 'dart:async';

/// Restart a timer of 300 milliseconds every time this is called
/// Used with search field (to start searching few milliseconds after user stop typing)

class Debouncer {
  final Duration delay;
  Timer _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(Function action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}
