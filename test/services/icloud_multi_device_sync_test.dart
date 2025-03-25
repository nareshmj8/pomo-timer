import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Mock class for testing multi-device synchronization
class CloudKitMultiDeviceTester extends CloudKitService {
  // Mock devices with their separate cloud and local data
  final Map<String, Map<String, dynamic>> _deviceLocalData = {};
  Map<String, dynamic> _sharedCloudData = {};

  // Device currently being tested
  String _currentDevice = 'device1';

  // Track when cloud data changed for each device
  final Map<String, bool> _cloudDataChanged = {};

  // Last device that updated the cloud
  String? _lastUpdatingDevice;

  // Constructor to initialize with test data
  CloudKitMultiDeviceTester() {
    // Initialize shared cloud data
    _sharedCloudData = {
      'sessionDuration': 25.0,
      'shortBreakDuration': 5.0,
      'longBreakDuration': 15.0,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };

    // Initialize devices with the same data
    _deviceLocalData['device1'] = Map<String, dynamic>.from(_sharedCloudData);
    _deviceLocalData['device2'] = Map<String, dynamic>.from(_sharedCloudData);
    _deviceLocalData['device3'] = Map<String, dynamic>.from(_sharedCloudData);

    // Initialize change tracking
    _cloudDataChanged['device1'] = false;
    _cloudDataChanged['device2'] = false;
    _cloudDataChanged['device3'] = false;
  }

  // Switch the active device
  void switchActiveDevice(String deviceId) {
    assert(_deviceLocalData.containsKey(deviceId),
        'Device $deviceId does not exist');
    _currentDevice = deviceId;
  }

  // Get the local data for the current device
  Map<String, dynamic> getCurrentDeviceLocalData() {
    return _deviceLocalData[_currentDevice]!;
  }

  // Get the shared cloud data
  Map<String, dynamic> getSharedCloudData() {
    return _sharedCloudData;
  }

  // Method to simulate device receiving cloud changes notification
  void notifyDeviceOfCloudChanges([String? deviceId]) {
    final device = deviceId ?? _currentDevice;
    debugPrint('Device $device notified of cloud changes');
    _cloudDataChanged[device] = true;
  }

  // Reset cloud changed flag
  void resetCloudChangedFlag([String? deviceId]) {
    final device = deviceId ?? _currentDevice;
    _cloudDataChanged[device] = false;
  }

  // Check if device has been notified of cloud changes
  bool hasCloudChanges([String? deviceId]) {
    final device = deviceId ?? _currentDevice;
    return _cloudDataChanged[device] ?? false;
  }

  @override
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    debugPrint('Device $_currentDevice saving data: $data');

    // Update the current device's local data
    _deviceLocalData[_currentDevice] = Map<String, dynamic>.from(data);

    // Update the timestamp for this update
    _deviceLocalData[_currentDevice]!['lastUpdated'] =
        DateTime.now().millisecondsSinceEpoch;

    // Update the shared cloud data
    _sharedCloudData =
        Map<String, dynamic>.from(_deviceLocalData[_currentDevice]!);
    _lastUpdatingDevice = _currentDevice;

    // Simulate notifying other devices
    for (final deviceId in _deviceLocalData.keys) {
      if (deviceId != _currentDevice) {
        debugPrint('Notifying device $deviceId of cloud changes');
        _cloudDataChanged[deviceId] = true;
      }
    }

    return true;
  }

  @override
  Future<Map<String, dynamic>?> fetchData(
      String recordType, String recordId) async {
    debugPrint('Device $_currentDevice fetching data from cloud');

    // If there are cloud changes, update local data
    if (_cloudDataChanged[_currentDevice] == true) {
      _deviceLocalData[_currentDevice] =
          Map<String, dynamic>.from(_sharedCloudData);
      resetCloudChangedFlag();
    }

    return Map<String, dynamic>.from(_sharedCloudData);
  }

  // Method to simulate conflicts by having two devices update in sequence
  Future<void> simulateMultiDeviceUpdates() async {
    // Device 1 updates sessionDuration
    switchActiveDevice('device1');
    Map<String, dynamic> device1Data =
        Map<String, dynamic>.from(getCurrentDeviceLocalData());
    device1Data['sessionDuration'] = 30.0;
    await saveData('sessionDuration', 'device1', device1Data);

    // At this point the cloud has device1's update

    // Device 2 updates shortBreakDuration without being notified of device1's changes
    switchActiveDevice('device2');
    // We deliberately don't sync device2 with the cloud here to simulate a conflict
    resetCloudChangedFlag('device2'); // Clear the notification to simulate this

    // Now device2 makes changes to its local copy without knowing about cloud changes
    Map<String, dynamic> device2Data =
        Map<String, dynamic>.from(getCurrentDeviceLocalData());
    device2Data['shortBreakDuration'] = 8.0;
    await saveData('shortBreakDuration', 'device2', device2Data);

    // At this point the cloud has device2's update but device1 doesn't know about it

    // Switch back to device1 which is still unaware of device2's changes
    switchActiveDevice('device1');
  }

  // Method to check if a device is in sync with the cloud
  bool isDeviceInSyncWithCloud(String deviceId) {
    final cloudLastUpdated = _sharedCloudData['lastUpdated'];
    final deviceLastUpdated = _deviceLocalData[deviceId]!['lastUpdated'];
    return cloudLastUpdated == deviceLastUpdated;
  }

  // Method to sync a device with the cloud
  Future<bool> syncDeviceWithCloud(String deviceId) async {
    switchActiveDevice(deviceId);
    notifyDeviceOfCloudChanges();
    await fetchData('sessionDuration', 'device1');
    return isDeviceInSyncWithCloud(deviceId);
  }

  // Method to make sequential updates for testing convergence
  Future<void> simulateSequentialUpdates() async {
    // Device 1 updates
    switchActiveDevice('device1');
    var deviceData = Map<String, dynamic>.from(getCurrentDeviceLocalData());
    deviceData['sessionDuration'] = 50.0;
    await saveData('sessionDuration', 'device1', deviceData);

    // Device 2 syncs then makes its own update
    await syncDeviceWithCloud('device2');
    switchActiveDevice('device2');
    deviceData = Map<String, dynamic>.from(getCurrentDeviceLocalData());
    deviceData['shortBreakDuration'] = 10.0;
    await saveData('shortBreakDuration', 'device2', deviceData);

    // Device 3 syncs then makes its own update
    await syncDeviceWithCloud('device3');
    switchActiveDevice('device3');
    deviceData = Map<String, dynamic>.from(getCurrentDeviceLocalData());
    deviceData['longBreakDuration'] = 25.0;
    await saveData('longBreakDuration', 'device3', deviceData);
  }
}

@GenerateMocks([])
void main() {
  late CloudKitMultiDeviceTester cloudService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cloudService = CloudKitMultiDeviceTester();
  });

  group('iCloud Multi-Device Sync Tests', () {
    test('Should update cloud when device makes changes', () async {
      // Start with device1
      cloudService.switchActiveDevice('device1');

      // Get initial data
      final initialData = cloudService.getCurrentDeviceLocalData();
      expect(initialData['sessionDuration'], equals(25.0));

      // Update data on device1
      var updatedData = Map<String, dynamic>.from(initialData);
      updatedData['sessionDuration'] = 35.0;
      await cloudService.saveData('sessionDuration', 'device1', updatedData);

      // Verify cloud data was updated
      final cloudData = cloudService.getSharedCloudData();
      expect(cloudData['sessionDuration'], equals(35.0));
    });

    test('Should update device when cloud changes', () async {
      // Start with device1 and make changes
      cloudService.switchActiveDevice('device1');
      var device1Data =
          Map<String, dynamic>.from(cloudService.getCurrentDeviceLocalData());
      device1Data['sessionDuration'] = 40.0;
      await cloudService.saveData('sessionDuration', 'device1', device1Data);

      // Switch to device2
      cloudService.switchActiveDevice('device2');

      // Get device2 initial data before cloud notification
      final device2InitialData = cloudService.getCurrentDeviceLocalData();
      expect(device2InitialData['sessionDuration'], equals(25.0));

      // Fetch data on device2 (which should use the notification state)
      await cloudService.fetchData('sessionDuration', 'device2');

      // Verify device2 local data was updated
      final device2UpdatedData = cloudService.getCurrentDeviceLocalData();
      expect(device2UpdatedData['sessionDuration'], equals(40.0));
    });

    test('Should handle simultaneous updates from multiple devices', () async {
      // Simulate updates from multiple devices
      await cloudService.simulateMultiDeviceUpdates();

      // Device1 should be out of sync with shortBreakDuration
      final device1Data = cloudService.getCurrentDeviceLocalData();
      expect(device1Data['sessionDuration'], equals(30.0));
      expect(device1Data['shortBreakDuration'], equals(5.0)); // Not updated yet

      // Verify cloud has device2's update (the most recent one)
      final cloudData = cloudService.getSharedCloudData();
      expect(
          cloudData['sessionDuration'], equals(25.0)); // Overwritten by device2
      expect(cloudData['shortBreakDuration'], equals(8.0)); // From device2

      // Notify device1 of changes and sync
      cloudService.notifyDeviceOfCloudChanges();
      await cloudService.fetchData('sessionDuration', 'device1');

      // Verify device1 now has all changes from the cloud
      final updatedDevice1Data = cloudService.getCurrentDeviceLocalData();
      expect(updatedDevice1Data['sessionDuration'], equals(25.0)); // From cloud
      expect(
          updatedDevice1Data['shortBreakDuration'], equals(8.0)); // From cloud
    });

    test('Should sync multiple devices with cloud', () async {
      // Device 1 updates data
      cloudService.switchActiveDevice('device1');
      var device1Data =
          Map<String, dynamic>.from(cloudService.getCurrentDeviceLocalData());
      device1Data['sessionDuration'] = 45.0;
      device1Data['longBreakDuration'] = 20.0;
      await cloudService.saveData('sessionDuration', 'device1', device1Data);

      // Sync device2 and device3 with cloud
      final device2InSync = await cloudService.syncDeviceWithCloud('device2');
      final device3InSync = await cloudService.syncDeviceWithCloud('device3');

      // Verify all devices are in sync
      expect(device2InSync, isTrue);
      expect(device3InSync, isTrue);

      // Verify device2 has updated data
      cloudService.switchActiveDevice('device2');
      final device2Data = cloudService.getCurrentDeviceLocalData();
      expect(device2Data['sessionDuration'], equals(45.0));
      expect(device2Data['longBreakDuration'], equals(20.0));

      // Verify device3 has updated data
      cloudService.switchActiveDevice('device3');
      final device3Data = cloudService.getCurrentDeviceLocalData();
      expect(device3Data['sessionDuration'], equals(45.0));
      expect(device3Data['longBreakDuration'], equals(20.0));
    });

    test('All devices should eventually converge on the same data', () async {
      // Make sequential changes with each device properly syncing
      await cloudService.simulateSequentialUpdates();

      // Cloud should have the most recent changes (device3)
      final cloudData = cloudService.getSharedCloudData();
      expect(cloudData['sessionDuration'], equals(50.0)); // From device1
      expect(cloudData['shortBreakDuration'], equals(10.0)); // From device2
      expect(cloudData['longBreakDuration'], equals(25.0)); // From device3

      // Sync all devices to ensure everyone has the latest data
      await cloudService.syncDeviceWithCloud('device1');
      await cloudService.syncDeviceWithCloud('device2');

      // All devices should have the same data
      cloudService.switchActiveDevice('device1');
      final finalDevice1Data = cloudService.getCurrentDeviceLocalData();
      cloudService.switchActiveDevice('device2');
      final finalDevice2Data = cloudService.getCurrentDeviceLocalData();
      cloudService.switchActiveDevice('device3');
      final finalDevice3Data = cloudService.getCurrentDeviceLocalData();

      // Verify all devices have the same values
      expect(finalDevice1Data['sessionDuration'], equals(50.0));
      expect(finalDevice1Data['shortBreakDuration'], equals(10.0));
      expect(finalDevice1Data['longBreakDuration'], equals(25.0));

      expect(finalDevice2Data['sessionDuration'], equals(50.0));
      expect(finalDevice2Data['shortBreakDuration'], equals(10.0));
      expect(finalDevice2Data['longBreakDuration'], equals(25.0));

      expect(finalDevice3Data['sessionDuration'], equals(50.0));
      expect(finalDevice3Data['shortBreakDuration'], equals(10.0));
      expect(finalDevice3Data['longBreakDuration'], equals(25.0));
    });
  });
}
