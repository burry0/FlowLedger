import 'package:flutter/foundation.dart';

/// Tells open screens that data changed so they can reload.
abstract final class AppRefreshNotifier {
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void notifyChanged() => revision.value++;
}
