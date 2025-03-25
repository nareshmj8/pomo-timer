import 'package:flutter_test/flutter_test.dart';
import 'comprehensive_icloud_sync_test_with_reports.dart' as comprehensive_test;

/// A simple script to run the integration tests with reporting.
///
/// This script can be run with:
/// flutter drive --driver=test_driver/integration_test.dart --target=test/integration_tests/run_tests_with_reports.dart
void main() {
  // Initialize test binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Running all tests with reporting', () {
    testWidgets('iCloud Sync Tests', (WidgetTester tester) async {
      // Run the iCloud sync tests
      comprehensive_test.main();
    });
  });
}
