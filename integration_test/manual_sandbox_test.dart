import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_timemaster/main.dart' as app;
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_helper.dart';
import 'dart:io';
import 'dart:async';

/// Manual test helper for sandbox testing
/// This test enables sandbox testing mode and sets up detailed logging,
/// then allows the tester to manually interact with the app for a set time period
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Only run on iOS devices
  final bool isIOS = Platform.isIOS;
  if (!isIOS) {
    debugPrint(
      '⚠️ SKIPPING TESTS: Sandbox IAP tests require a real iOS device',
    );
    return;
  }

  group('Manual Sandbox Testing', () {
    testWidgets('Interactive Sandbox Test Mode', (WidgetTester tester) async {
      debugPrint('🧪 MANUAL TEST: Starting interactive sandbox testing mode');

      // Enable sandbox testing and verbose logging
      await SandboxTestingHelper.setSandboxTestingEnabled(true);
      await SandboxTestingHelper.setSandboxLogLevel('verbose');

      SandboxTestingHelper.logSandboxEvent(
        'ManualTest',
        'Interactive sandbox testing session started',
      );

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Print instructions
      debugPrint('');
      debugPrint('📱 MANUAL TESTING MODE ENABLED');
      debugPrint('--------------------------------');
      debugPrint('🔍 You can now manually test in-app purchases');
      debugPrint('📝 All actions will be logged by the SandboxTestingHelper');
      debugPrint('⏱️ This test will remain active for 5 minutes');
      debugPrint('   allowing you to navigate and test IAPs manually');
      debugPrint('📊 Check the app\'s sandbox testing logs for results');
      debugPrint('--------------------------------');

      // Log test session start
      SandboxTestingHelper.logSandboxEvent(
        'ManualTest',
        'App launched and ready for manual testing',
      );

      // Set a timer to keep the test running for the manual testing period
      const testDuration = Duration(minutes: 5);
      DateTime startTime = DateTime.now();
      DateTime endTime = startTime.add(testDuration);

      // Log the test duration
      debugPrint('⏱️ Test started at ${startTime.toString()}');
      debugPrint('⏱️ Test will end at ${endTime.toString()}');

      // Simple progress indicator as time passes
      Timer.periodic(const Duration(seconds: 30), (timer) {
        final now = DateTime.now();
        final remaining = endTime.difference(now);

        if (remaining.isNegative) {
          timer.cancel();
          return;
        }

        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        debugPrint('⏱️ Manual testing time remaining: ${minutes}m ${seconds}s');

        SandboxTestingHelper.logSandboxEvent(
          'ManualTest',
          'Testing time remaining: ${minutes}m ${seconds}s',
        );
      });

      // Keep the test active for the manual testing duration
      await Future.delayed(testDuration);

      // Log test completion
      SandboxTestingHelper.logSandboxEvent(
        'ManualTest',
        'Interactive sandbox testing session completed',
      );

      debugPrint('');
      debugPrint('✅ MANUAL TESTING COMPLETED');
      debugPrint('--------------------------------');
      debugPrint(
        '📊 You can view the test logs in the app\'s sandbox testing section',
      );
      debugPrint(
        '🔍 Check for any issues in the transaction queue or error logs',
      );
      debugPrint('--------------------------------');
    });
  });
}
