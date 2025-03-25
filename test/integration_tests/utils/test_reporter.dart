import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';

/// A class to handle test reporting for the Pomodoro Timer app.
/// This class is responsible for:
/// - Recording test results
/// - Generating HTML and PDF reports
/// - Saving screenshots for failed tests
class TestReporter {
  final List<TestResult> _testResults = [];
  final String _appName = 'Pomodoro Timer';
  final String _testSuite = 'iCloud Sync Tests';
  late final String _reportDirectory;
  late final String _screenshotDirectory;
  late final DateTime _startTime;
  String? _deviceName;
  String? _osVersion;

  /// Initialize the test reporter
  Future<void> initialize() async {
    _startTime = DateTime.now();

    // Create report directories
    final baseDir = await _getReportBaseDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(_startTime);
    _reportDirectory = '$baseDir/reports/$timestamp';
    _screenshotDirectory = '$_reportDirectory/screenshots';

    await Directory(_reportDirectory).create(recursive: true);
    await Directory(_screenshotDirectory).create(recursive: true);

    // Get device info
    await _getDeviceInfo();
  }

  /// Get the base directory for reports
  Future<String> _getReportBaseDirectory() async {
    if (Platform.isIOS || Platform.isAndroid) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      // For desktop platforms
      final directory = await getDownloadsDirectory() ?? Directory.current;
      return directory.path;
    }
  }

  /// Get device information
  Future<void> _getDeviceInfo() async {
    try {
      _deviceName = 'Flutter Test Device';
      _osVersion = 'Flutter ${Platform.operatingSystem}';
    } catch (e) {
      _deviceName = 'Error getting device info';
      _osVersion = 'Unknown';
    }
  }

  /// Record a test result
  void recordTestResult(TestResult result) {
    _testResults.add(result);
  }

  /// Get all test results
  Future<List<TestResult>> getTestResults() async {
    return List.unmodifiable(_testResults);
  }

  /// Take a screenshot of the current screen
  Future<String?> takeScreenshot(String testName) async {
    try {
      final screenshotName =
          '${testName.replaceAll(RegExp(r'[^\w\s]+'), '_')}.png';
      final screenshotPath = '$_screenshotDirectory/$screenshotName';

      // In a real implementation, we would use integration_test to take a screenshot
      // For now, we'll just create an empty file
      final file = File(screenshotPath);
      await file.writeAsString('Placeholder for screenshot');

      return screenshotPath;
    } catch (e) {
      debugPrint('Error taking screenshot: $e');
      return null;
    }
  }

  /// Generate HTML and PDF reports
  Future<Map<String, String>> generateReports() async {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime);

    final htmlPath = await _generateHtmlReport(duration);
    final pdfPath = await _generateTextReport(duration);

    return {
      'html': htmlPath,
      'pdf': pdfPath,
    };
  }

  /// Generate HTML report
  Future<String> _generateHtmlReport(Duration testDuration) async {
    final htmlPath = '$_reportDirectory/report.html';
    final file = File(htmlPath);

    final passedTests = _testResults.where((result) => result.passed).length;
    final failedTests = _testResults.length - passedTests;
    final passRate = _testResults.isEmpty
        ? 100
        : (passedTests / _testResults.length * 100).toStringAsFixed(2);

    final html = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$_appName - $_testSuite Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        h1, h2, h3 {
            color: #2c3e50;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .summary {
            display: flex;
            justify-content: space-between;
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .summary-item {
            text-align: center;
            padding: 0 15px;
        }
        .summary-item h3 {
            margin-bottom: 5px;
        }
        .test-results {
            margin-top: 30px;
        }
        .test-result {
            margin-bottom: 15px;
            padding: 15px;
            border-radius: 5px;
            border-left: 5px solid;
        }
        .test-passed {
            background-color: #e8f5e9;
            border-left-color: #4caf50;
        }
        .test-failed {
            background-color: #ffebee;
            border-left-color: #f44336;
        }
        .test-name {
            font-weight: bold;
            margin-bottom: 5px;
        }
        .test-duration {
            color: #666;
            font-size: 0.9em;
        }
        .test-error {
            margin-top: 10px;
            padding: 10px;
            background-color: #fff;
            border-radius: 3px;
            overflow-x: auto;
        }
        .screenshot {
            margin-top: 15px;
        }
        .screenshot img {
            max-width: 100%;
            max-height: 300px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
        .chart-container {
            width: 100%;
            height: 300px;
            margin: 30px 0;
        }
        footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            text-align: center;
            font-size: 0.9em;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>$_appName - $_testSuite Report</h1>
        <div>
            <p><strong>Date:</strong> ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_startTime)}</p>
            <p><strong>Device:</strong> $_deviceName</p>
            <p><strong>OS:</strong> $_osVersion</p>
        </div>
    </div>
    
    <div class="summary">
        <div class="summary-item">
            <h3>Total Tests</h3>
            <p>${_testResults.length}</p>
        </div>
        <div class="summary-item">
            <h3>Passed</h3>
            <p>$passedTests</p>
        </div>
        <div class="summary-item">
            <h3>Failed</h3>
            <p>$failedTests</p>
        </div>
        <div class="summary-item">
            <h3>Pass Rate</h3>
            <p>$passRate%</p>
        </div>
        <div class="summary-item">
            <h3>Duration</h3>
            <p>${_formatDuration(testDuration)}</p>
        </div>
    </div>
    
    <div class="chart-container">
        <canvas id="resultsChart" width="400" height="300"></canvas>
    </div>
    
    <div class="test-results">
        <h2>Test Results</h2>
        ${_generateTestResultsHtml()}
    </div>
    
    <footer>
        <p>Generated on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}</p>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // Create pie chart for test results
        const ctx = document.getElementById('resultsChart').getContext('2d');
        const resultsChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: ['Passed', 'Failed'],
                datasets: [{
                    data: [$passedTests, $failedTests],
                    backgroundColor: ['#4caf50', '#f44336'],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Test Results'
                    }
                }
            }
        });
    </script>
</body>
</html>
''';

    await file.writeAsString(html);
    return htmlPath;
  }

  /// Generate HTML for test results
  String _generateTestResultsHtml() {
    final buffer = StringBuffer();

    for (final result in _testResults) {
      final statusClass = result.passed ? 'test-passed' : 'test-failed';

      buffer.write('''
      <div class="test-result $statusClass">
          <div class="test-name">${result.testName}</div>
          <div class="test-duration">Duration: ${_formatDuration(result.duration)}</div>
      ''');

      if (!result.passed && result.errorMessage != null) {
        buffer.write('''
          <div class="test-error">
              <pre>${result.errorMessage}</pre>
          </div>
        ''');
      }

      if (!result.passed && result.screenshotPath != null) {
        buffer.write('''
          <div class="screenshot">
              <img src="screenshots/${result.screenshotPath!.split('/').last}" alt="Test Failure Screenshot">
          </div>
        ''');
      }

      buffer.write('</div>');
    }

    return buffer.toString();
  }

  /// Generate text report (instead of PDF)
  Future<String> _generateTextReport(Duration testDuration) async {
    // Create a simple text file instead of a PDF
    final textPath = '$_reportDirectory/report.txt';
    final file = File(textPath);

    final passedTests = _testResults.where((result) => result.passed).length;
    final failedTests = _testResults.length - passedTests;
    final passRate = _testResults.isEmpty
        ? 100
        : (passedTests / _testResults.length * 100).toStringAsFixed(2);

    final content = '''
$_appName - $_testSuite Report
==============================

Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_startTime)}
Device: $_deviceName
OS: $_osVersion

Summary:
--------
Total Tests: ${_testResults.length}
Passed: $passedTests
Failed: $failedTests
Pass Rate: $passRate%
Duration: ${_formatDuration(testDuration)}

Test Results:
-------------
${_generateTestResultsText()}

Generated on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
''';

    await file.writeAsString(content);
    return textPath;
  }

  /// Generate text for test results
  String _generateTestResultsText() {
    final buffer = StringBuffer();

    for (final result in _testResults) {
      buffer.writeln(
          '${result.passed ? 'PASSED' : 'FAILED'}: ${result.testName}');
      buffer.writeln('Duration: ${_formatDuration(result.duration)}');

      if (!result.passed && result.errorMessage != null) {
        buffer.writeln('Error: ${result.errorMessage}');
      }

      if (!result.passed && result.screenshotPath != null) {
        buffer.writeln('Screenshot: ${result.screenshotPath}');
      }

      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Format a duration as mm:ss.ms
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;

    return '$minutes:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';
  }

  /// Open a file with the default application
  Future<bool> openFile(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      return await _launchUrl(uri);
    } catch (e) {
      debugPrint('Error opening file: $e');
      return false;
    }
  }

  /// Launch a URL (stub implementation)
  Future<bool> _launchUrl(Uri uri) async {
    debugPrint('Would launch: ${uri.toString()}');
    return true;
  }
}

/// A class to represent a test result
class TestResult {
  final String testName;
  final bool passed;
  final Duration duration;
  final String? errorMessage;
  final String? screenshotPath;

  TestResult({
    required this.testName,
    required this.passed,
    required this.duration,
    this.errorMessage,
    this.screenshotPath,
  });
}
