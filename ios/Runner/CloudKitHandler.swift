// This file is no longer needed as the functionality has been moved to AppDelegate.swift
// The file can be deleted from the project. 

private let container = CKContainer(identifier: "iCloud.com.naresh.pomodorotimemaster")
private lazy var privateDatabase = container.privateCloudDatabase
private let recordType = "PomoTimerData"
private let recordID = CKRecord.ID(recordName: "userSettings")
private var isCloudAvailable = false
private var pendingOperations: [() -> Void] = []

cloudKitChannel.setMethodCallHandler { [weak self] (call, result) in
  guard let self = self else { return }
  self.handleMethodCall(call, result: result)
} 

private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  // Handle all CloudKit operations
} 