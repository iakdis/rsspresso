import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences/preferences.dart';

class TextDirectionNotifier extends Notifier<TextDirection> {
  @override
  TextDirection build() {
    // Return the default type
    return TextDirection.values.byName(PrefTextDirection().get());
  }

  void set(TextDirection direction) async {
    state = direction;
    await PrefTextDirection().set(direction.name);
  }
}

final textDirectionProvider =
    NotifierProvider<TextDirectionNotifier, TextDirection>(() {
  return TextDirectionNotifier();
});
