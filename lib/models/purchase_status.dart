/// Represents the current status of a purchase
enum PurchaseStatus {
  /// Purchase has not been attempted yet
  notPurchased,

  /// Purchase is in progress
  purchasing,

  /// Purchase was successful
  purchased,

  /// An error occurred during the purchase
  error,

  /// Purchase was restored from a previous purchase
  restored,

  /// Product was not found
  notFound,

  /// Purchase is pending (e.g., waiting for connectivity)
  pending,

  /// Subscription has expired
  expired,
}
