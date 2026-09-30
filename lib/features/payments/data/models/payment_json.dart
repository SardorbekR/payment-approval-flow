import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';

/// Strict: anything missing or malformed throws a [FormatException] naming the field
Payment paymentFromJson(Map<String, Object?> json) {
  return Payment(
    id: _requiredString(json, 'id'),
    reference: _requiredString(json, 'reference'),
    recipientName: _requiredString(json, 'recipient_name'),
    amount: _money(json, 'amount'),
    status: _status(json, 'status'),
    decidedAt: _instant(json, 'decided_at'),
    note: _optionalString(json, 'note'),
  );
}

PaymentRequest paymentRequestFromJson(Map<String, Object?> json) {
  return PaymentRequest(
    id: _requiredString(json, 'id'),
    reference: _requiredString(json, 'reference'),
    maskedRecipient: _requiredString(json, 'recipient_masked'),
    currency: _currency(json, 'currency'),
    requestedAt: _instant(json, 'requested_at'),
  );
}

String paymentStatusToJson(PaymentStatus status) => switch (status) {
  PaymentStatus.approved => 'approved',
  PaymentStatus.rejected => 'rejected',
};

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();

  throw FormatException('Expected a non-empty string for "$key"', value);
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) throw FormatException('Expected a string or null for "$key"', value);

  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}

/// Rejects anything but integer minor units rather than guess an amount
Money _money(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map<String, Object?>) {
    throw FormatException('Expected an object for "$key"', value);
  }

  final minorUnits = value['minor_units'];
  if (minorUnits is! int || minorUnits <= 0) {
    throw FormatException('Expected a positive integer for "$key.minor_units"', minorUnits);
  }

  return Money(minorUnits, _currency(value, 'currency'));
}

Currency _currency(Map<String, Object?> json, String key) {
  final code = _requiredString(json, key);
  try {
    return Currency.fromCode(code);
  } on FormatException {
    throw FormatException('Unsupported currency for "$key"', code);
  }
}

PaymentStatus _status(Map<String, Object?> json, String key) => switch (json[key]) {
  'approved' => PaymentStatus.approved,
  'rejected' => PaymentStatus.rejected,
  final value => throw FormatException('Expected "approved" or "rejected" for "$key"', value),
};

/// A timestamp without a zone is ambiguous, so it's rejected
DateTime _instant(Map<String, Object?> json, String key) {
  final value = _requiredString(json, key);
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) {
    throw FormatException('Expected an ISO 8601 timestamp with a time zone for "$key"', value);
  }

  return parsed;
}
