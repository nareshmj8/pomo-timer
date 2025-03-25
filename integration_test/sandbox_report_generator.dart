import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pomodoro_timemaster/main.dart' as app;
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test to generate a comprehensive report of sandbox testing results
/// This consolidates all test logs and creates a readable report
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate sandbox testing report', (WidgetTester tester) async {
    debugPrint('🧪 Starting sandbox test report generation...');

    // Launch app
    app.main();
    await tester.pumpAndSettle();

    // Wait for app to initialize
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Get sandbox test logs
    final events = await SandboxTestingHelper.getSandboxEvents();

    // Get any stored test results
    final prefs = await SharedPreferences.getInstance();
    final completedTestsJson =
        prefs.getString('completed_sandbox_tests') ?? '{}';
    final completedTests = Map<String, dynamic>.from(
      json.decode(completedTestsJson),
    );

    // Generate report
    final reportContent = await _generateReport(events, completedTests);

    // Save report to file
    final reportFile = await _saveReportToFile(reportContent);

    debugPrint('📋 Report generated successfully: ${reportFile.path}');

    // Log that we've generated a report
    SandboxTestingHelper.logSandboxEvent(
      'Report',
      'Generated comprehensive sandbox testing report',
    );
  });

  /// Generates a formatted report from test events and completed tests
  Future<String> _generateReport(
    List<Map<String, dynamic>> events,
    Map<String, dynamic> completedTests,
  ) async {
    final sb = StringBuffer();

    // Report header
    sb.writeln('# Sandbox Testing Report');
    sb.writeln('Generated on: ${DateTime.now().toLocal()}');
    sb.writeln('');

    // Summary section
    sb.writeln('## Test Summary');

    // Count completed tests
    int totalTestsRun = completedTests.length;
    int passedTests = completedTests.values.where((v) => v == true).length;

    sb.writeln('Total tests run: $totalTestsRun');
    sb.writeln('Tests passed: $passedTests');
    sb.writeln(
      'Success rate: ${totalTestsRun > 0 ? (passedTests / totalTestsRun * 100).toStringAsFixed(1) : 0}%',
    );
    sb.writeln('');

    // Categories completed
    sb.writeln('## Test Categories');

    // Group test IDs by category
    Map<String, List<String>> categorizedTests = {};

    completedTests.forEach((testId, passed) {
      final category = testId.split('_').first;
      categorizedTests.putIfAbsent(category, () => []);
      categorizedTests[category]!.add(testId);
    });

    // Display categories
    categorizedTests.forEach((category, tests) {
      final passedInCategory =
          tests.where((t) => completedTests[t] == true).length;
      sb.writeln('- $category: $passedInCategory/${tests.length} tests passed');
    });
    sb.writeln('');

    // Event log section
    sb.writeln('## Event Log');
    sb.writeln('');

    // Group events by category
    Map<String, List<Map<String, dynamic>>> categorizedEvents = {};

    for (final event in events) {
      final category = event['category'] as String;
      categorizedEvents.putIfAbsent(category, () => []);
      categorizedEvents[category]!.add(event);
    }

    // Display events by category
    categorizedEvents.forEach((category, categoryEvents) {
      sb.writeln('### $category');
      sb.writeln('');

      for (final event in categoryEvents) {
        final timestamp =
            DateTime.parse(event['timestamp'] as String).toLocal();
        final formattedTime =
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
        final message = event['message'] as String;

        sb.writeln('- [$formattedTime] $message');
      }

      sb.writeln('');
    });

    // Recommendations section
    sb.writeln('## Recommendations');
    sb.writeln('');

    if (passedTests < totalTestsRun * 0.8) {
      sb.writeln('⚠️ Low test pass rate. Additional testing recommended.');
    } else if (passedTests == totalTestsRun) {
      sb.writeln(
        '✅ All tests passed. In-app purchases appear to be working correctly in the sandbox environment.',
      );
    } else {
      sb.writeln('⚠️ Some tests failed. Review the logs for more details.');
    }

    // Look for specific error patterns
    bool hasNetworkIssues = false;
    bool hasPaymentSheetIssues = false;
    bool hasTransactionQueueIssues = false;

    for (final event in events) {
      final message = event['message'] as String;
      if (message.contains('network') || message.contains('connection')) {
        hasNetworkIssues = true;
      }
      if (message.contains('payment sheet') || message.contains('SKPayment')) {
        hasPaymentSheetIssues = true;
      }
      if (message.contains('queue') || message.contains('transaction')) {
        hasTransactionQueueIssues = true;
      }
    }

    if (hasNetworkIssues) {
      sb.writeln(
        '- Network connectivity issues detected. Ensure retry logic is robust.',
      );
    }
    if (hasPaymentSheetIssues) {
      sb.writeln(
        '- Payment sheet presentation issues detected. Verify StoreKit integration.',
      );
    }
    if (hasTransactionQueueIssues) {
      sb.writeln(
        '- Transaction queue issues detected. Verify queue processing logic.',
      );
    }

    return sb.toString();
  }

  /// Saves the report to a file in the app's documents directory
  Future<File> _saveReportToFile(String content) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final reportDir = Directory('${appDocDir.path}/sandbox_reports');

    if (!await reportDir.exists()) {
      await reportDir.create(recursive: true);
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File('${reportDir.path}/sandbox_report_$timestamp.md');

    return file.writeAsString(content);
  }
}
