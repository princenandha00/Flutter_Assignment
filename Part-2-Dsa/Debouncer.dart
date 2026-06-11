import 'dart:async';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({
    required this.milliseconds,
  });

  void run(VoidCallback action) {
    _timer?.cancel();

    _timer = Timer(
      Duration(milliseconds: milliseconds),
      action,
    );
  }
}


// Usage

final debouncer =
    Debouncer(milliseconds: 500);

onChanged: (value) {
  debouncer.run(() {
    searchProduct(value);
  });
}
