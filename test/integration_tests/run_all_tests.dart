import 'package:flutter_test/flutter_test.dart';

import 'icloud_sync_test.dart' as icloud_sync_test;
import 'multi_device_sync_test.dart' as multi_device_sync_test;
import 'cloudkit_native_test.dart' as cloudkit_native_test;
import 'background_sync_test.dart' as background_sync_test;

void main() {
  group('iCloud Sync Integration Tests', () {
    icloud_sync_test.main();
  });

  group('Multi-Device Sync Tests', () {
    multi_device_sync_test.main();
  });

  group('CloudKit Native Tests', () {
    cloudkit_native_test.main();
  });

  group('Background Sync Tests', () {
    background_sync_test.main();
  });
}
