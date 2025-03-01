import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/settings_provider.dart';

class BackupService {
  static Future<void> exportData(
      BuildContext context, SettingsProvider settings) async {
    try {
      final now = DateTime.now();
      final fileName =
          'pomo_timer_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';

      // Export data to JSON
      final data = settings.exportData();
      final jsonString = jsonEncode(data);

      // Check if the data is not empty
      if (data.isEmpty) {
        throw Exception('No data to export');
      }

      if (Platform.isIOS) {
        // For iOS, use the documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');

        // Check if file already exists
        if (await file.exists()) {
          await file.delete();
        }

        await file.writeAsString(jsonString);

        // Verify file was written correctly
        final verifyContent = await file.readAsString();
        if (verifyContent != jsonString) {
          throw Exception('File verification failed');
        }

        if (context.mounted) {
          await _showAlert(
            context,
            'Success',
            'Backup saved to Documents folder:\n$fileName',
          );
        }
      } else {
        // For Android and other platforms, use file picker to save
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save backup file',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsString(jsonString);

          // Verify file was written correctly
          final verifyContent = await file.readAsString();
          if (verifyContent != jsonString) {
            throw Exception('File verification failed');
          }

          if (context.mounted) {
            await _showAlert(
              context,
              'Success',
              'Backup saved successfully',
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        await _showAlert(
          context,
          'Error',
          'Failed to export data: ${e.toString()}',
        );
      }
    }
  }

  static Future<void> importData(
      BuildContext context, SettingsProvider settings) async {
    try {
      if (Platform.isIOS) {
        // For iOS, use the documents directory
        final directory = await getApplicationDocumentsDirectory();
        final files = directory
            .listSync()
            .where((file) =>
                file.path.endsWith('.json') &&
                file.path.contains('pomo_timer_backup'))
            .toList();

        if (files.isEmpty) {
          if (context.mounted) {
            await _showAlert(
              context,
              'No Backups Found',
              'No backup files found in Documents folder. Please export a backup first.',
            );
          }
          return;
        }

        // Sort files by date (most recent first)
        files.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

        // Show file picker sheet
        if (context.mounted) {
          await showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: const Text('Select Backup File'),
              message: const Text('Choose a backup file to restore'),
              actions: files.map((file) {
                final fileName = file.path.split('/').last;
                final modifiedDate = file.statSync().modified;
                return CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _processBackupFile(context, settings, file as File);
                  },
                  child:
                      Text('$fileName\nModified: ${_formatDate(modifiedDate)}'),
                );
              }).toList(),
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          );
        }
      } else {
        // For Android and other platforms, use file picker
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null) {
          final file = File(result.files.single.path!);
          if (context.mounted) {
            await _processBackupFile(context, settings, file);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        await _showAlert(
          context,
          'Error',
          'Failed to import data: ${e.toString()}',
        );
      }
    }
  }

  static Future<void> _processBackupFile(
      BuildContext context, SettingsProvider settings, File file) async {
    try {
      // Check file size (prevent extremely large files)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception('Backup file is too large');
      }

      final jsonString = await file.readAsString();

      // Validate JSON format
      Map<String, dynamic> data;
      try {
        data = jsonDecode(jsonString);
      } catch (e) {
        throw Exception('Invalid JSON format');
      }

      // Validate backup file structure
      if (!data.containsKey('sessionDuration') ||
          !data.containsKey('shortBreakDuration') ||
          !data.containsKey('longBreakDuration')) {
        throw Exception('Invalid backup file format: missing required fields');
      }

      // Show confirmation dialog before importing
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Import Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'This will replace all your current settings and data. Are you sure you want to continue?'),
                const SizedBox(height: 8),
                Text(
                  'Backup contains:\n• ${data['history']?.length ?? 0} history entries\n• Timer settings\n• Theme and sound preferences',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await settings.importData(data);
                    if (context.mounted) {
                      await _showAlert(
                        context,
                        'Success',
                        'Data imported successfully',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      await _showAlert(
                        context,
                        'Error',
                        'Failed to import data: ${e.toString()}',
                      );
                    }
                  }
                },
                child: const Text('Import'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        await _showAlert(
          context,
          'Error',
          e.toString().contains('Exception:')
              ? e.toString().split('Exception: ')[1]
              : 'Invalid backup file format',
        );
      }
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> _showAlert(
    BuildContext context,
    String title,
    String message,
  ) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
