import 'package:flutter/foundation.dart';

final ValueNotifier<int?> appShellNavigationRequest = ValueNotifier<int?>(null);

void openAppShellTab(int index) {
  appShellNavigationRequest.value = index;
}
