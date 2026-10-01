// Enum types stored in the Drift schema.

/// User account status.
enum UserStatus { active, inactive, pendingApproval }

/// Per-user language preference (`User.locale_preference`).
enum UserLocale { en, ne }

/// Measurement unit for a garment template.
enum GarmentUnit { inch, cm }

/// Customer gender — drives the default suggested [GarmentUnit]/template.
enum Gender { male, female, other }

/// Order / garment lifecycle status.
enum OrderStatus {
  booked,
  cutting,
  stitching,
  trial,
  ready,
  delivered,
  cancelled,
}

/// Reason captured when an order is cancelled.
enum CancelledReason { customerCancelled, duplicate, fabricUnavailable, other }

/// Payment method.
enum PaymentMode { cash, card, upi, bank }

/// Whether a payment is the advance or the balance.
enum PaymentType { advance, balance }

/// Which lifecycle event a WhatsApp template is for.
enum WhatsAppEventType { orderConfirmed, trialReminder, readyForPickup, custom }

/// Outbound message channel.
enum MessageChannel { whatsapp, sms }

/// Delivery status of an outbound message.
enum MessageStatus { scheduled, delivered, read, failed }

/// Queued offline mutation kind.
enum OfflineAction { create, update }

/// Sync state of a queued offline mutation.
enum OfflineSyncStatus { pending, synced, failed }
