import Flutter
import UIKit
import BackgroundTasks
import CloudKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // MARK: - Properties
  
  private let syncTaskIdentifier = "com.naresh.pomoTimer.sync"
  
  // CloudKit properties
  private let container = CKContainer.default()
  private lazy var privateDatabase = container.privateCloudDatabase
  private let recordType = "PomoTimerData"
  private let recordID = CKRecord.ID(recordName: "userSettings")
  private var isCloudAvailable = false
  private var pendingOperations: [() -> Void] = []
  
  // MARK: - Application Lifecycle
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Set up the CloudKit method channel
    let controller = window?.rootViewController as! FlutterViewController
    let cloudKitChannel = FlutterMethodChannel(
        name: "com.naresh.pomoTimer/cloudkit",
        binaryMessenger: controller.binaryMessenger)
    
    // Handle method calls
    cloudKitChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      self.handleMethodCall(call, result: result)
    }
    
    // Check iCloud availability
    checkICloudAvailability()
    
    // Register for background tasks
    if #available(iOS 13.0, *) {
        registerBackgroundTasks()
    }
    
    // Process any pending operations
    processPendingOperations()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    
    // Sync when app becomes active
    processPendingOperations()
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    
    // Schedule background sync when app enters background
    if #available(iOS 13.0, *) {
        scheduleBackgroundSync()
    }
  }
  
  // MARK: - Method Channel Handling
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isICloudAvailable":
        result(isCloudAvailable)
        
    case "saveData":
        guard let data = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                               message: "Arguments are not a valid map", 
                               details: nil))
            return
        }
        
        saveData(data: data) { success in
            result(success)
        }
        
    case "fetchData":
        fetchData { data in
            result(data)
        }
        
    case "subscribeToChanges":
        subscribeToChanges { success in
            result(success)
        }
        
    case "processPendingOperations":
        processPendingOperations { success in
            result(success)
        }
        
    default:
        result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - CloudKit Operations
  
  private func checkICloudAvailability() {
    container.accountStatus { [weak self] (status, error) in
        DispatchQueue.main.async {
            if status == .available {
                self?.isCloudAvailable = true
            } else {
                self?.isCloudAvailable = false
                print("iCloud not available: \(status.rawValue)")
                if let error = error {
                    print("iCloud error: \(error.localizedDescription)")
                }
            }
        }
    }
  }
  
  private func saveData(data: [String: Any], completion: @escaping (Bool) -> Void) {
    guard isCloudAvailable else {
        // Queue operation for later if iCloud is not available
        pendingOperations.append { [weak self] in
            self?.saveData(data: data, completion: { _ in })
        }
        completion(false)
        return
    }
    
    // Check if record exists
    privateDatabase.fetch(withRecordID: recordID) { [weak self] (record, error) in
        guard let self = self else { return }
        
        let recordToSave: CKRecord
        
        if let existingRecord = record {
            // Update existing record
            recordToSave = existingRecord
        } else {
            // Create new record
            recordToSave = CKRecord(recordType: self.recordType, recordID: self.recordID)
        }
        
        // Update record with new data
        for (key, value) in data {
            if let value = value as? CKRecordValue {
                recordToSave[key] = value
            }
        }
        
        // Save record
        self.privateDatabase.save(recordToSave) { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving to CloudKit: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
  }
  
  private func fetchData(completion: @escaping ([String: Any]?) -> Void) {
    guard isCloudAvailable else {
        completion(nil)
        return
    }
    
    privateDatabase.fetch(withRecordID: recordID) { (record, error) in
        DispatchQueue.main.async {
            if let error = error {
                print("Error fetching from CloudKit: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let record = record else {
                completion(nil)
                return
            }
            
            // Convert record to dictionary
            var data: [String: Any] = [:]
            for key in record.allKeys() {
                if let value = record[key] {
                    // Handle different types of values
                    if let stringValue = value as? String {
                        data[key] = stringValue
                    } else if let numberValue = value as? NSNumber {
                        data[key] = numberValue
                    } else if let dateValue = value as? Date {
                        data[key] = Int(dateValue.timeIntervalSince1970 * 1000)
                    } else if let arrayValue = value as? [Any] {
                        data[key] = arrayValue
                    }
                }
            }
            
            completion(data)
        }
    }
  }
  
  private func subscribeToChanges(completion: @escaping (Bool) -> Void) {
    guard isCloudAvailable else {
        completion(false)
        return
    }
    
    let subscription = CKQuerySubscription(
        recordType: recordType,
        predicate: NSPredicate(value: true),
        options: [.firesOnRecordCreation, .firesOnRecordUpdate]
    )
    
    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.shouldSendContentAvailable = true
    subscription.notificationInfo = notificationInfo
    
    privateDatabase.save(subscription) { (_, error) in
        DispatchQueue.main.async {
            if let error = error {
                print("Error creating subscription: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
  }
  
  // MARK: - Background Tasks
  
  @available(iOS 13.0, *)
  private func registerBackgroundTasks() {
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: syncTaskIdentifier,
        using: nil) { [weak self] task in
            self?.handleBackgroundSync(task: task as! BGAppRefreshTask)
    }
  }
  
  @available(iOS 13.0, *)
  private func scheduleBackgroundSync() {
    let request = BGAppRefreshTaskRequest(identifier: syncTaskIdentifier)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
    
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Background sync scheduled")
    } catch {
        print("Could not schedule background sync: \(error)")
    }
  }
  
  @available(iOS 13.0, *)
  private func handleBackgroundSync(task: BGAppRefreshTask) {
    // Schedule the next sync
    scheduleBackgroundSync()
    
    // Create a task expiration handler
    task.expirationHandler = { [weak self] in
        self?.operationQueue.cancelAllOperations()
    }
    
    // Process pending operations
    processPendingOperations { success in
        task.setTaskCompleted(success: success)
    }
  }
  
  // MARK: - Helper Methods
  
  private lazy var operationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  
  private func processPendingOperations(completion: ((Bool) -> Void)? = nil) {
    guard isCloudAvailable else {
        completion?(false)
        return
    }
    
    if pendingOperations.isEmpty {
        completion?(true)
        return
    }
    
    // Process all pending operations
    let operations = pendingOperations
    pendingOperations = []
    
    for operation in operations {
        operation()
    }
    
    completion?(true)
  }
}
