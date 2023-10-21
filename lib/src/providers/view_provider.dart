import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/home_view.dart';
import '../utils/preferences/preferences.dart';

final viewProvider = StateProvider<HomeView?>(
  // Return the default type
  (ref) => PrefHomeView().get() != null
      ? HomeView.values.byName(PrefHomeView().get()!)
      : null,
);
