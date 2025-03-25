import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'dart:async';

void main() {
  const String channelName = 'com.naresh.pomodorotimemaster/cloudkit';

  // Initialize the test binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudKitService processPendingOperations', () {
    test('handles PENDING_ERROR exception gracefully', () async {
      // Setup
      const channel = MethodChannel(channelName);

      // Reset any previous handlers
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      // Create a test service instance
      final service = CloudKitService();

      // Create a completer to track when saveData is called with a pending operation
      final completer = Completer<bool>();

      // Setup the mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        switch (call.method) {
          case 'checkConnectivity':
            return true;
          case 'isICloudAvailable':
            return true;
          case 'subscribeToChanges':
            return true;
          case 'saveData':
            // Check if this is for a pending operation
            if (call.arguments is Map &&
                call.arguments['test'] == 'data' &&
                call.arguments['for_testing'] == true) {
              // This is our test pending operation being processed
              debugPrint('Mock detected processing of pending operation');
              if (!completer.isCompleted) {
                completer.complete(true);
              }
              // Throw the PENDING_ERROR exception to test the error handling
              throw PlatformException(
                  code: 'PENDING_ERROR',
                  message: 'Test exception for pending operations');
            }
            // For regular saves, return success
            return true;
          default:
            return null;
        }
      });

      // Initialize the service - this will set _isAvailable to true
      await service.initialize();

      // Add a test pending operation
      service.addPendingOperationForTest({'test': 'data', 'for_testing': true});

      // Call processPendingOperations
      debugPrint('Calling processPendingOperations');
      final result = await service.processPendingOperations();
      debugPrint('Test received result: $result');

      // Wait for the saveData method channel call to be made for our pending operation
      // or time out after 1 second
      bool pendingOperationProcessed = false;
      try {
        pendingOperationProcessed =
            await completer.future.timeout(const Duration(seconds: 1));
      } catch (e) {
        // Timeout occurred
        pendingOperationProcessed = false;
      }

      // Verify the pending operation was processed (saveData was called)
      expect(pendingOperationProcessed, true,
          reason: 'The pending operation was not processed');

      // The implementation specifically returns true for PENDING_ERROR as a special test case
      expect(result, true,
          reason:
              'processPendingOperations should handle PENDING_ERROR and return true');
    });
  });
}
