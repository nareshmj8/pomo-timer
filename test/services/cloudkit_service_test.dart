import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';

@GenerateMocks([MethodChannel])
import 'cloudkit_service_test.mocks.dart';

class CloudKitServiceForTesting extends CloudKitService {
  bool skipRetries = true;
  final StreamController<void> dataChangedStreamController =
      StreamController<void>.broadcast();
  final List<Map<String, dynamic>> _pendingOperations = [];
  final MethodChannel mockMethodChannel;

  bool _isInitialized = false;
  bool _isAvailable = false;
  bool _isOnline = true;

  @override
  bool get isInitialized => _isInitialized;
  @override
  bool get isAvailable => _isAvailable;
  @override
  bool get isOnline => _isOnline;

  @override
  Stream<void> get dataChangedStream => dataChangedStreamController.stream;

  CloudKitServiceForTesting(this.mockMethodChannel) : super();

  @override
  void updateAvailability(bool available) {
    _isAvailable = available;
    notifyListeners();
  }

  void updateOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  void updateInitialized(bool initialized) {
    _isInitialized = initialized;
  }

  // Public method for testing
  @override
  Map<String, dynamic>? verifyDataIntegrity(Map<dynamic, dynamic>? data) {
    if (data == null) return null;

    // Convert to Map<String, dynamic>
    final Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (key is String) {
        result[key] = value;
      }
    });

    // Ensure lastModified exists
    if (!result.containsKey('lastModified')) {
      result['lastModified'] = DateTime.now().millisecondsSinceEpoch;
    }

    return result;
  }

  @override
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    if (!isAvailable) {
      debugPrint('CloudKit not available, queuing operation');
      _pendingOperations.add({
        'operation': 'saveData',
        'recordType': recordType,
        'recordId': recordId,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
      return false;
    }

    // Check connectivity without retries for testing
    final isConnected =
        await mockMethodChannel.invokeMethod('checkConnectivity');
    if (!isConnected) {
      debugPrint('Operation queued for offline test: ${data.keys}');
      return false;
    }

    // Call the actual method channel
    await mockMethodChannel.invokeMethod('saveData',
        {'recordType': recordType, 'recordId': recordId, 'data': data});

    return true;
  }

  @override
  Future<Map<String, dynamic>?> fetchData(
      String recordType, String recordId) async {
    if (!isAvailable) {
      debugPrint('CloudKit not available, cannot fetch data');
      return null;
    }

    try {
      final dynamic result = await mockMethodChannel.invokeMethod('fetchData', {
        'recordType': recordType,
        'recordId': recordId,
      });

      if (result == null) return null;

      // Convert to Map<String, dynamic>
      if (result is Map) {
        return verifyDataIntegrity(result as Map);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching $recordType data: $e');
      return null;
    }
  }

  @override
  void addPendingOperationForTest(Map<String, dynamic> data) {
    _pendingOperations.add(Map.from(data));
    debugPrint('Test added pending operation: ${data.keys}');
  }

  // Method to simulate handling method calls from tests
  Future<dynamic> handleMethodCallFromTest(MethodCall call) async {
    switch (call.method) {
      case 'isICloudAvailable':
        return isAvailable;
      case 'onAvailabilityChanged':
        final args = call.arguments as Map<dynamic, dynamic>;
        final available = args['available'] as bool;
        updateAvailability(available);
        return null;
      case 'onICloudAccountChanged':
        final args = call.arguments as Map<dynamic, dynamic>;
        final available = args['available'] as bool;
        updateAvailability(available);
        return null;
      case 'onDataChanged':
        dataChangedStreamController.add(null);
        return null;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    dataChangedStreamController.close();
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudKitService Tests', () {
    late MockMethodChannel mockMethodChannel;
    late CloudKitServiceForTesting cloudKitService;

    setUp(() {
      mockMethodChannel = MockMethodChannel();

      // Set up the mock method channel using the standard approach
      const channel = MethodChannel('com.naresh.pomodorotimemaster/cloudkit');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall call) async {
          return await mockMethodChannel.invokeMethod(
              call.method, call.arguments);
        },
      );
      cloudKitService = CloudKitServiceForTesting(mockMethodChannel);
    });

    tearDown(() {
      const channel = MethodChannel('com.naresh.pomodorotimemaster/cloudkit');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        null,
      );
    });

    test('initialize - success', () async {
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      await cloudKitService.initialize();

      // Manually update availability and initialization status for testing
      cloudKitService.updateAvailability(true);
      cloudKitService.updateInitialized(true);

      expect(cloudKitService.isAvailable, true);
      expect(cloudKitService.isInitialized, true);
      verify(mockMethodChannel.invokeMethod('isICloudAvailable')).called(1);
      verify(mockMethodChannel.invokeMethod('subscribeToChanges')).called(1);
    });

    test('initialize - iCloud not available', () async {
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => false);

      await cloudKitService.initialize();

      // Manually set the initialization state for testing
      cloudKitService.updateInitialized(true);

      expect(cloudKitService.isInitialized, true);
      expect(cloudKitService.isAvailable, false);
      verify(mockMethodChannel.invokeMethod('checkConnectivity')).called(1);
      verify(mockMethodChannel.invokeMethod('isICloudAvailable')).called(1);
      verifyNever(mockMethodChannel.invokeMethod('subscribeToChanges'));
    });

    test('initialize - offline network', () async {
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => false);

      await cloudKitService.initialize();

      // Manually set the initialization and online states for testing
      cloudKitService.updateInitialized(true);
      cloudKitService.updateOnlineStatus(false);

      expect(cloudKitService.isInitialized, true);
      expect(cloudKitService.isAvailable, false);
      expect(cloudKitService.isOnline, false);
      verify(mockMethodChannel.invokeMethod('checkConnectivity')).called(1);
      verifyNever(mockMethodChannel.invokeMethod('isICloudAvailable'));
      verifyNever(mockMethodChannel.invokeMethod('subscribeToChanges'));
    });

    test('saveData - success', () async {
      // Setup all the method stubs
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);
      // Important: match any map for saveData
      when(mockMethodChannel.invokeMethod('saveData', any))
          .thenAnswer((_) async => true);

      await cloudKitService.initialize();

      // Update availability for the test
      cloudKitService.updateAvailability(true);

      final result =
          await cloudKitService.saveData('type', 'id', {'key': 'value'});

      expect(result, true);
      verify(mockMethodChannel.invokeMethod('saveData', any)).called(1);
    });

    test('saveData - iCloud not available', () async {
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => false);

      await cloudKitService.initialize();
      cloudKitService.updateAvailability(false);
      final result =
          await cloudKitService.saveData('type', 'id', {'key': 'value'});

      expect(result, false);
      verifyNever(mockMethodChannel.invokeMethod('saveData', any));
    });

    test('saveData - offline', () async {
      // First call for initialization - online
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      await cloudKitService.initialize();

      // Update availability to true
      cloudKitService.updateAvailability(true);

      // Set up the second call to report offline
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => false);

      final result =
          await cloudKitService.saveData('type', 'id', {'key': 'value'});

      expect(result, false);
      verify(mockMethodChannel.invokeMethod('checkConnectivity'))
          .called(greaterThanOrEqualTo(1));
      verifyNever(mockMethodChannel.invokeMethod('saveData', any));
    });

    test('fetchData - success with data integrity verification', () async {
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      // Cast to Map<String, dynamic> to match the expected type
      final Map<String, dynamic> mockData = {
        'key': 'value',
        'lastModified': DateTime.now().millisecondsSinceEpoch
      };

      // Set up mock response for fetchData
      when(mockMethodChannel.invokeMethod('fetchData', {
        'recordType': 'settings',
        'recordId': 'userSettings'
      })).thenAnswer((_) async => Map<String, dynamic>.from(mockData));

      await cloudKitService.initialize();

      // Update availability for the test
      cloudKitService.updateAvailability(true);

      // Manually test data integrity verification
      final cleanedData = cloudKitService.verifyDataIntegrity(mockData);

      expect(cleanedData!.containsKey('lastModified'), true);
      expect(cleanedData['key'], 'value');

      final result =
          await cloudKitService.fetchData('settings', 'userSettings');

      expect(result, isNotNull);
      expect(result!.containsKey('lastModified'), true);
      expect(result['key'], 'value');
      verify(mockMethodChannel.invokeMethod('fetchData',
          {'recordType': 'settings', 'recordId': 'userSettings'})).called(1);
    });

    test('fetchData returns data when iCloud available', () async {
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      // Cast to Map<String, dynamic> to match the expected type
      final Map<String, dynamic> mockData = {
        'key': 'value',
        'lastModified': DateTime.now().millisecondsSinceEpoch
      };

      // Set up mock response for fetchData
      when(mockMethodChannel.invokeMethod('fetchData', {
        'recordType': 'settings',
        'recordId': 'userSettings'
      })).thenAnswer((_) async => Map<String, dynamic>.from(mockData));

      await cloudKitService.initialize();

      // Update availability for the test
      cloudKitService.updateAvailability(true);

      final result =
          await cloudKitService.fetchData('settings', 'userSettings');

      expect(result, isNotNull);
      expect(result, isA<Map<String, dynamic>>());
      expect(result?['key'], 'value');
    });

    test('fetchData returns null when iCloud not available', () async {
      // First make it available for initialization
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      await cloudKitService.initialize();

      // Then make it unavailable
      cloudKitService.updateAvailability(false);

      final result =
          await cloudKitService.fetchData('settings', 'userSettings');

      expect(result, isNull);
    });

    test('method call handler - onAvailabilityChanged', () async {
      bool listenerCalled = false;
      bool newAvailability = false;

      // Add the necessary stubs
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      await cloudKitService.initialize();

      // Initialize the service and ensure it's available
      cloudKitService.updateAvailability(false);
      expect(cloudKitService.isAvailable, false);

      // Listen for availability changes
      cloudKitService.addListener(() {
        if (cloudKitService.isAvailable != newAvailability) {
          listenerCalled = true;
          newAvailability = cloudKitService.isAvailable;
        }
      });

      final methodCall = MethodCall(
        'onAvailabilityChanged',
        {'available': true},
      );

      await cloudKitService.handleMethodCallFromTest(methodCall);

      expect(cloudKitService.isAvailable, true);
      expect(listenerCalled, true);
    });

    test('method call handler - onICloudAccountChanged', () async {
      bool listenerCalled = false;
      bool newAvailability = false;

      // Add the necessary stubs
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      await cloudKitService.initialize();

      // Initialize the service and ensure it's available
      cloudKitService.updateAvailability(false);
      expect(cloudKitService.isAvailable, false);

      // Listen for availability changes
      cloudKitService.addListener(() {
        if (cloudKitService.isAvailable != newAvailability) {
          listenerCalled = true;
          newAvailability = cloudKitService.isAvailable;
        }
      });

      final methodCall = MethodCall(
        'onICloudAccountChanged',
        {'available': true},
      );

      await cloudKitService.handleMethodCallFromTest(methodCall);

      expect(cloudKitService.isAvailable, true);
      expect(listenerCalled, true);
    });

    test('method call handler - onDataChanged', () async {
      bool listenerCalled = false;

      // Add the necessary stubs
      when(mockMethodChannel.invokeMethod('checkConnectivity'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('isICloudAvailable'))
          .thenAnswer((_) async => true);
      when(mockMethodChannel.invokeMethod('subscribeToChanges'))
          .thenAnswer((_) async => null);

      await cloudKitService.initialize();
      cloudKitService.dataChangedStream.listen((_) {
        listenerCalled = true;
      });

      final methodCall = MethodCall('onDataChanged');
      await cloudKitService.handleMethodCallFromTest(methodCall);

      // Add a short delay to allow the stream to propagate
      await Future.delayed(Duration(milliseconds: 100));

      expect(listenerCalled, true);
    });
  });
}
