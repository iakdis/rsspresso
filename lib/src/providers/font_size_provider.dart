import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences/preferences.dart';

const double minFontSize = 12;
const double maxFontSize = 20;

class FontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    // Return the default type
    return PrefFontSize().get();
  }

  void set(double size) async {
    state = size;
    await PrefFontSize().set(size);
  }
}

final fontSizeProvider = NotifierProvider<FontSizeNotifier, double>(() {
  return FontSizeNotifier();
});
