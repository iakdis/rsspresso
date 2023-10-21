import 'package:flutter_riverpod/flutter_riverpod.dart';

final isRefreshingProvider = StateProvider<bool>(
  // Return the default type
  (ref) => true,
);
