import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'test_reporter.dart';

/// A class to run tests with reporting capabilities
class TestRunner {
  final TestReporter _reporter;
  final bool _openReportOnFailure;
  final Stopwatch _stopwatch = Stopwatch();

  /// Creates a new TestRunner
  ///
  /// [openReportOnFailure] - Whether to automatically open the HTML report if any tests fail
  TestRunner({
    TestReporter? reporter,
    bool openReportOnFailure = true,
  })  : _reporter = reporter ?? TestReporter(),
        _openReportOnFailure = openReportOnFailure;

  /// Initialize the test runner
  Future<void> initialize() async {
    await _reporter.initialize();
    await createReportsDirectory();
  }

  /// Run a test with reporting
  void reportingTest(String description, Future<void> Function() body) {
    test(description, () async {
      _stopwatch.reset();
      _stopwatch.start();
      String? errorMessage;
      String? screenshotPath;
      bool passed = true;

      try {
        await body();
      } catch (e, stackTrace) {
        passed = false;
        errorMessage = '$e\n$stackTrace';

        // Take a screenshot for failed tests
        try {
          screenshotPath = await _reporter.takeScreenshot(description);
        } catch (screenshotError) {
          debugPrint('Failed to take screenshot: $screenshotError');
        }
      } finally {
        _stopwatch.stop();

        // Record the test result
        _reporter.recordTestResult(TestResult(
          testName: description,
          passed: passed,
          duration: _stopwatch.elapsed,
          errorMessage: errorMessage,
          screenshotPath: screenshotPath,
        ));
      }

      // If the test failed, make sure the test framework knows it
      if (!passed) {
        fail(errorMessage ?? 'Test failed without specific error message');
      }
    });
  }

  /// Generate HTML and PDF reports
  Future<Map<String, String>> generateReports() async {
    final reportPaths = await _reporter.generateReports();

    // Print report paths
    debugPrint('Test reports generated:');
    debugPrint('HTML Report: ${reportPaths['html']}');
    debugPrint('PDF Report: ${reportPaths['pdf']}');

    // Check if any tests failed and open the report if configured
    final results = await _reporter.getTestResults();
    final hasFailedTests = results.any((result) => !result.passed);

    if (hasFailedTests && _openReportOnFailure) {
      final htmlPath = reportPaths['html'];
      if (htmlPath != null) {
        await _reporter.openFile(htmlPath);
      }
    }

    return reportPaths;
  }

  /// Create a directory for test reports
  static Future<String> createReportsDirectory() async {
    final baseDir = await _getReportBaseDirectory();
    final reportsDir = Directory('$baseDir/reports');

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    return reportsDir.path;
  }

  /// Get the base directory for reports
  static Future<String> _getReportBaseDirectory() async {
    if (Platform.isIOS || Platform.isAndroid) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      // For desktop platforms
      final directory = await getDownloadsDirectory() ?? Directory.current;
      return directory.path;
    }
  }
}

// Stub for canLaunchUrl and launchUrl if url_launcher is not available
Future<bool> canLaunchUrl(Uri uri) async {
  return true;
}

Future<bool> launchUrl(Uri uri) async {
  debugPrint('Would launch: ${uri.toString()}');
  return true;
}
