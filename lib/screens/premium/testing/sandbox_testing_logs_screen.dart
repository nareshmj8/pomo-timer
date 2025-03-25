import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// A screen to display sandbox testing logs
/// This is useful for debugging IAP issues during testing
class SandboxTestingLogsScreen extends StatefulWidget {
  const SandboxTestingLogsScreen({Key? key}) : super(key: key);

  @override
  State<SandboxTestingLogsScreen> createState() =>
      _SandboxTestingLogsScreenState();
}

class _SandboxTestingLogsScreenState extends State<SandboxTestingLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await SandboxTestingHelper.getSandboxEvents();
      setState(() {
        _logs = logs.reversed.toList(); // Show newest first
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading logs: $e');
    }
  }

  Future<void> _clearLogs() async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Logs'),
        content: const Text(
            'Are you sure you want to clear all sandbox testing logs?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await SandboxTestingHelper.clearSandboxEvents();
              _loadLogs();
            },
            child: const Text('Clear'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLogs() async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/sandbox_testing_logs.txt');

      final buffer = StringBuffer();
      buffer.writeln('=== SANDBOX TESTING LOGS ===');
      buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
      buffer.writeln('');

      for (final log in _logs) {
        buffer.writeln('${log['timestamp']} [${log['category']}]');
        buffer.writeln('${log['message']}');
        buffer.writeln('---');
      }

      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Sandbox Testing Logs',
      );
    } catch (e) {
      debugPrint('Error sharing logs: $e');
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Failed to share logs: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredLogs() {
    if (_filter == 'All') {
      return _logs;
    } else {
      return _logs.where((log) => log['category'] == _filter).toList();
    }
  }

  Set<String> _getCategories() {
    return _logs.map((log) => log['category'] as String).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();
    final categories = _getCategories();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sandbox Testing Logs'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.share),
          onPressed: _shareLogs,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Filter bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: CupertinoColors.systemGrey6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Filter: '),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text(_filter, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            const Icon(CupertinoIcons.chevron_down, size: 14),
                          ],
                        ),
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => CupertinoActionSheet(
                              title: const Text('Filter by Category'),
                              actions: [
                                CupertinoActionSheetAction(
                                  child: const Text('All'),
                                  onPressed: () {
                                    setState(() => _filter = 'All');
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ...categories.map(
                                  (category) => CupertinoActionSheetAction(
                                    child: Text(category),
                                    onPressed: () {
                                      setState(() => _filter = category);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                isDefaultAction: true,
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Text('Refresh',
                            style: TextStyle(fontSize: 14)),
                        onPressed: _loadLogs,
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child:
                            const Text('Clear', style: TextStyle(fontSize: 14)),
                        onPressed: _clearLogs,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Logs list
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : filteredLogs.isEmpty
                      ? Center(
                          child: Text(
                            _filter == 'All'
                                ? 'No logs available'
                                : 'No logs for category "$_filter"',
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = filteredLogs[index];
                            final timestamp = DateTime.parse(log['timestamp']);
                            final timeString =
                                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
                            final dateString =
                                '${timestamp.day}/${timestamp.month}/${timestamp.year}';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                  color: CupertinoColors.systemGrey5
                                      .withOpacity(0.5),
                                  width: 0.5,
                                )),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '[${log['category']}]',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '$timeString · $dateString',
                                        style: TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    log['message'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
