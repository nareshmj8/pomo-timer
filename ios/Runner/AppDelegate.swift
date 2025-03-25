import Flutter
import UIKit
import BackgroundTasks
import CloudKit
import StoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // MARK: - Properties
  
  private let syncTaskIdentifier = "com.naresh.pomodorotimemaster.sync"
  
  // CloudKit properties
  private let container = CKContainer.default()
  private lazy var privateDatabase = container.privateCloudDatabase
  private let recordType = "PomoTimerData"
  private let recordID = CKRecord.ID(recordName: "userSettings")
  private var isCloudAvailable = false
  private var pendingOperations: [() -> Void] = []
  private var lastSyncTime: Date?
  
  // MARK: - Application Lifecycle
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Set up the CloudKit method channel
    let controller = window?.rootViewController as! FlutterViewController
    let cloudKitChannel = FlutterMethodChannel(
        name: "com.naresh.pomodorotimemaster/cloudkit",
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
    
    // Register for iCloud account changes
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(iCloudAccountChanged),
        name: NSNotification.Name.CKAccountChanged,
        object: nil
    )
    
    let storeKitChannel = FlutterMethodChannel(name: "com.naresh.pomodorotimemaster/storekit",
                                              binaryMessenger: controller.binaryMessenger)
    
    storeKitChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      if call.method == "getReceiptInfo" {
        self.handleGetReceiptInfo(call, result: result)
      } else if call.method == "refreshReceipt" {
        self.handleRefreshReceipt(call, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    
    // Check iCloud availability again when app becomes active
    checkICloudAvailability()
    
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
  
  // MARK: - iCloud Account Changes
  
  @objc func iCloudAccountChanged(_ notification: Notification) {
    // Check iCloud availability when account changes
    checkICloudAvailability()
    
    // Notify Flutter about the change
    let controller = window?.rootViewController as! FlutterViewController
    let cloudKitChannel = FlutterMethodChannel(
        name: "com.naresh.pomodorotimemaster/cloudkit",
        binaryMessenger: controller.binaryMessenger)
    
    cloudKitChannel.invokeMethod("onICloudAccountChanged", arguments: ["available": isCloudAvailable])
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
            let wasAvailable = self?.isCloudAvailable ?? false
            let isNowAvailable = status == .available
            
            self?.isCloudAvailable = isNowAvailable
            
            // If availability changed, notify Flutter
            if wasAvailable != isNowAvailable {
                let controller = self?.window?.rootViewController as? FlutterViewController
                if let controller = controller {
                    let cloudKitChannel = FlutterMethodChannel(
                        name: "com.naresh.pomodorotimemaster/cloudkit",
                        binaryMessenger: controller.binaryMessenger)
                    
                    cloudKitChannel.invokeMethod("onAvailabilityChanged", arguments: ["available": isNowAvailable])
                }
            }
            
            if let error = error {
                print("iCloud error: \(error.localizedDescription)")
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
        // Return more detailed result with error code
        let controller = window?.rootViewController as! FlutterViewController
        let cloudKitChannel = FlutterMethodChannel(
            name: "com.naresh.pomodorotimemaster/cloudkit",
            binaryMessenger: controller.binaryMessenger)
        
        cloudKitChannel.invokeMethod("onError", arguments: [
            "code": "NETWORK_ERROR",
            "operation": "saveData",
            "message": "iCloud is not available. Operation queued for later."
        ])
        
        completion(false)
        return
    }
    
    // Check if record exists
    privateDatabase.fetch(withRecordID: recordID) { [weak self] (record, error) in
        guard let self = self else { return }
        
        // Handle specific errors from fetch operation
        if let error = error {
            self.handleCloudKitError(error, operation: "saveData_fetch")
            completion(false)
            return
        }
        
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
            if let stringValue = value as? String {
                recordToSave[key] = stringValue
            } else if let intValue = value as? Int {
                recordToSave[key] = intValue as NSNumber
            } else if let doubleValue = value as? Double {
                recordToSave[key] = doubleValue as NSNumber
            } else if let boolValue = value as? Bool {
                recordToSave[key] = boolValue as NSNumber
            } else if let arrayValue = value as? [String] {
                recordToSave[key] = arrayValue as CKRecordValue
            } else if let dateValue = value as? Date {
                recordToSave[key] = dateValue
            } else if let timestampValue = value as? Int {
                // Convert timestamp to Date
                let date = Date(timeIntervalSince1970: TimeInterval(timestampValue) / 1000.0)
                recordToSave[key] = date
            }
        }
        
        // Add last sync time
        recordToSave["lastSyncTime"] = Date()
        self.lastSyncTime = Date()
        
        // Save record
        self.privateDatabase.save(recordToSave) { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving to CloudKit: \(error.localizedDescription)")
                    self.handleCloudKitError(error, operation: "saveData_save")
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
        // Return more detailed result with error code
        let controller = window?.rootViewController as! FlutterViewController
        let cloudKitChannel = FlutterMethodChannel(
            name: "com.naresh.pomodorotimemaster/cloudkit",
            binaryMessenger: controller.binaryMessenger)
        
        cloudKitChannel.invokeMethod("onError", arguments: [
            "code": "NETWORK_ERROR",
            "operation": "fetchData",
            "message": "iCloud is not available."
        ])
        
        completion(nil)
        return
    }
    
    privateDatabase.fetch(withRecordID: recordID) { [weak self] (record, error) in
        guard let self = self else { return }
        
        DispatchQueue.main.async {
            if let error = error {
                // If record not found, return empty dictionary
                if let ckError = error as? CKError, ckError.code == .unknownItem {
                    completion([:])
                    return
                }
                
                print("Error fetching from CloudKit: \(error.localizedDescription)")
                self.handleCloudKitError(error, operation: "fetchData")
                completion(nil)
                return
            }
            
            guard let record = record else {
                completion([:])
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
                        // Determine if it's a boolean
                        if CFGetTypeID(numberValue) == CFBooleanGetTypeID() {
                            data[key] = numberValue.boolValue
                        } else if floor(numberValue.doubleValue) == numberValue.doubleValue {
                            // It's an integer
                            data[key] = numberValue.intValue
                        } else {
                            // It's a double
                            data[key] = numberValue.doubleValue
                        }
                    } else if let dateValue = value as? Date {
                        // Convert date to timestamp
                        data[key] = Int(dateValue.timeIntervalSince1970 * 1000)
                    } else if let arrayValue = value as? [Any] {
                        data[key] = arrayValue
                    }
                }
            }
            
            // Update last sync time
            if let syncTime = record["lastSyncTime"] as? Date {
                self.lastSyncTime = syncTime
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
    
    // Check if subscription already exists
    let subscriptionID = "pomoTimerChanges"
    privateDatabase.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
        if subscription != nil {
            // Subscription already exists
            completion(true)
            return
        }
        
        // Create new subscription
        let subscription = CKQuerySubscription(
            recordType: self.recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        self.privateDatabase.save(subscription) { (_, error) in
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
  
  // MARK: - Remote Notifications
  
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Check if this is a CloudKit notification
    if let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
        // Handle CloudKit notification
        if ckNotification.notificationType == .query {
            // Sync data
            fetchData { _ in
                // Notify Flutter about the change
                let controller = self.window?.rootViewController as! FlutterViewController
                let cloudKitChannel = FlutterMethodChannel(
                    name: "com.naresh.pomodorotimemaster/cloudkit",
                    binaryMessenger: controller.binaryMessenger)
                
                cloudKitChannel.invokeMethod("onDataChanged", arguments: nil)
                
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
    } else {
        // Not a CloudKit notification, let the parent handle it
        super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
  }
  
  // MARK: - StoreKit Methods
  
  private func handleGetReceiptInfo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Check if receipt exists
    guard let receiptURL = Bundle.main.appStoreReceiptURL else {
      result([
        "receiptExists": false,
        "error": "No receipt found"
      ])
      return
    }
    
    // Try to read receipt data
    do {
      let receiptData = try Data(contentsOf: receiptURL)
      let receiptString = receiptData.base64EncodedString()
      
      // Get transactions using the appropriate API for the iOS version
      if #available(iOS 15.0, *) {
        getTransactionsIOS15 { transactions in
          result([
            "receiptExists": true,
            "receiptPath": receiptURL.path,
            "receiptData": receiptString,
            "transactions": transactions
          ])
        }
      } else {
        // For iOS 14 and below, just return the receipt data
        result([
          "receiptExists": true,
          "receiptPath": receiptURL.path,
          "receiptData": receiptString
        ])
      }
    } catch {
      result([
        "receiptExists": false,
        "error": "Failed to read receipt: \(error.localizedDescription)"
      ])
    }
  }
  
  @available(iOS 15.0, *)
  private func getTransactionsIOS15(completion: @escaping ([[String: Any]]) -> Void) {
    Task {
      var transactionInfo: [[String: Any]] = []
      
      do {
        // Get all transactions
        for await verification in Transaction.all {
          guard case .verified(let transaction) = verification else {
            continue
          }
          
          // Add basic transaction details
          var transactionDetails: [String: Any] = [
            "productID": transaction.productID,
            "purchaseDate": transaction.purchaseDate.description
          ]
          
          // Add optional fields
          if let expirationDate = transaction.expirationDate {
            transactionDetails["expirationDate"] = expirationDate.description
          } else {
            transactionDetails["expirationDate"] = "none"
          }
          
          // Add other transaction properties
          transactionDetails["isUpgraded"] = transaction.isUpgraded
          
          transactionInfo.append(transactionDetails)
        }
        
        completion(transactionInfo)
      } catch {
        print("Error getting transactions: \(error.localizedDescription)")
        completion([])
      }
    }
  }
  
  private func handleRefreshReceipt(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Create a receipt refresh request
    let request = SKReceiptRefreshRequest()
    request.delegate = self
    
    // Start the request
    request.start()
    
    // Return success immediately, the delegate methods will handle completion
    result(true)
    
    print("Receipt refresh request started")
  }
  
  // Add a helper method to handle CloudKit errors
  private func handleCloudKitError(_ error: Error, operation: String) {
    let controller = window?.rootViewController as! FlutterViewController
    let cloudKitChannel = FlutterMethodChannel(
        name: "com.naresh.pomodorotimemaster/cloudkit",
        binaryMessenger: controller.binaryMessenger)
    
    var errorCode = "UNKNOWN_ERROR"
    var errorMessage = error.localizedDescription
    
    // Extract specific CloudKit error codes
    if let ckError = error as? CKError {
        switch ckError.code {
        case .networkFailure, .networkUnavailable, .serviceUnavailable:
            errorCode = "NETWORK_ERROR"
            errorMessage = "Network connection unavailable for iCloud operation."
        case .notAuthenticated, .badContainer:
            errorCode = "AUTHENTICATION_ERROR"
            errorMessage = "iCloud authentication failed. Please check your Apple ID settings."
        case .quotaExceeded:
            errorCode = "QUOTA_EXCEEDED"
            errorMessage = "Your iCloud storage quota has been exceeded."
        case .serverRejectedRequest, .internalError:
            errorCode = "SERVER_ERROR"
            errorMessage = "iCloud server error occurred. Please try again later."
        case .permissionFailure:
            errorCode = "PERMISSION_ERROR"
            errorMessage = "Permission denied to access iCloud data."
        case .zoneNotFound:
            errorCode = "ZONE_NOT_FOUND"
            errorMessage = "iCloud container zone not found."
        case .unknownItem:
            errorCode = "RECORD_NOT_FOUND"
            errorMessage = "The requested data was not found in iCloud."
        case .constraintViolation:
            errorCode = "CONSTRAINT_ERROR"
            errorMessage = "Data validation failed. Please check your data format."
        case .limitExceeded:
            errorCode = "LIMIT_EXCEEDED"
            errorMessage = "iCloud operation limit exceeded. Please try again later."
        case .assetFileNotFound:
            errorCode = "ASSET_NOT_FOUND"
            errorMessage = "Asset file not found in iCloud."
        case .incompatibleVersion:
            errorCode = "VERSION_ERROR"
            errorMessage = "Incompatible iCloud version detected."
        case .changeTokenExpired:
            errorCode = "TOKEN_ERROR"
            errorMessage = "iCloud change token has expired."
        default:
            errorCode = "CLOUDKIT_ERROR"
            errorMessage = "An error occurred with iCloud: \(ckError.localizedDescription)"
        }
    }
    
    // Send error details to Flutter
    cloudKitChannel.invokeMethod("onError", arguments: [
        "code": errorCode,
        "operation": operation,
        "message": errorMessage,
        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
    ])
    
    print("CloudKit Error [\(operation)]: \(errorCode) - \(errorMessage)")
  }
}

// Extension to handle SKReceiptRefreshRequest delegate methods
extension AppDelegate: SKRequestDelegate {
  func requestDidFinish(_ request: SKRequest) {
    if request is SKReceiptRefreshRequest {
      print("Receipt refresh request completed successfully")
    }
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    if request is SKReceiptRefreshRequest {
      print("Receipt refresh request failed with error: \(error.localizedDescription)")
    }
  }
}
