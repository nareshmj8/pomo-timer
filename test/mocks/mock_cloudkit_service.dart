import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';

class MockCloudKitService extends ChangeNotifier implements CloudKitService {
  bool _isInitialized = false;
  bool _isAvailable = true;
  bool _isSignedIn = true;
  bool _isOnline = true;
  String _userId = 'mock-user-id';
  final List<Map<String, dynamic>> _pendingOperations = [];
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isOnline => _isOnline;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Future<bool> isICloudAvailable() async {
    return _isAvailable;
  }

  @override
  Future<bool> isSignedIn() async {
    return _isSignedIn;
  }

  @override
  Future<String?> getUserIdentifier() async {
    return _userId;
  }

  @override
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    // Mock implementation
    return true;
  }

  @override
  Future<Map<String, dynamic>?> fetchData(
      String recordType, String recordId) async {
    // Mock implementation
    return {'mock': 'data'};
  }

  @override
  Future<void> deleteData(String key) async {
    // Mock implementation
  }

  @override
  Future<bool> processPendingOperations() async {
    // Mock implementation
    return true;
  }

  @override
  Future<bool> subscribeToChanges() async {
    // Mock implementation
    return true;
  }

  @override
  void updateAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
    notifyListeners();
  }

  @override
  Stream<bool> get availabilityStream => Stream.value(_isAvailable);

  @override
  Stream<void> get dataChangedStream => Stream.value(null);

  @override
  void addPendingOperationForTest(Map<String, dynamic> data) {
    _pendingOperations.add(Map.from(data));
    debugPrint('Mock added pending operation: ${data.keys}');
  }

  @override
  Future<void> openAppSettings() async {
    // Mock implementation
  }

  @override
  Map<String, dynamic>? verifyDataIntegrity(Map<String, dynamic>? data) {
    // For testing, simply return the data without verification
    return data;
  }

  // Methods to control mock behavior
  void setAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
    notifyListeners();
  }

  void setSignIn(bool isSignedIn) {
    _isSignedIn = isSignedIn;
    notifyListeners();
  }

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void setOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }
}
