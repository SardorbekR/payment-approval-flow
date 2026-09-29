import 'dart:math';

import 'package:clock/clock.dart';
import 'package:payment_approval/features/payments/data/data_sources/payments_api.dart';
import 'package:payment_approval/features/payments/data/data_sources/recipient_mask.dart';

part 'in_memory_payments_seed.dart';

/// Stands in for the payments backend and keeps its state in memory.
///
/// Like a real server, it holds the full details of every payment and decides
/// what each response may contain. Pending requests go out with a masked name
/// and no amount; the full payment is only returned once a decision is submitted.
/// [latency] makes loading and submitting states visible in the demo.
class InMemoryPaymentsApi implements PaymentsApi {
  InMemoryPaymentsApi({Random? random, Duration latency = Duration.zero})
    : _random = random ?? Random(),
      _latency = latency {
    for (final record in _seedRecords(clock.now())) {
      _records[record.id] = record;
    }
  }

  final Random _random;
  final Duration _latency;
  final _records = <String, _PaymentRecord>{};

  @override
  Future<List<Map<String, Object?>>> fetchPayments() async {
    await _respond();

    return [
      for (final record in _records.values)
        if (record.isDecided) record.toPaymentJson(),
    ];
  }

  @override
  Future<List<Map<String, Object?>>> fetchPendingRequests() async {
    await _respond();

    return [
      for (final record in _records.values)
        if (!record.isDecided) record.toRequestJson(),
    ];
  }

  @override
  Future<Map<String, Object?>> createDebugRequest() async {
    await _respond();

    final record = _PaymentRecord(
      id: _uniqueId(),
      reference: _uniqueReference(),
      recipientName: _pick(_recipientNames),
      minorUnits: _randomAmount(),
      note: _random.nextInt(5) == 0 ? null : _pick(_paymentNotes),
      requestedAt: clock.now().toUtc(),
    );
    _records[record.id] = record;

    return record.toRequestJson();
  }

  @override
  Future<Map<String, Object?>> submitDecision({
    required String requestId,
    required String decision,
  }) async {
    await _respond();

    final status = switch (decision) {
      'approved' => _RecordStatus.approved,
      'rejected' => _RecordStatus.rejected,
      _ => throw ArgumentError.value(decision, 'decision', 'Expected "approved" or "rejected"'),
    };
    final record = _records[requestId];
    if (record == null) throw RequestUnavailableException(requestId);
    if (record.isDecided) {
      // A retry of the recorded decision gets the same answer; anything else conflicts.
      if (record.status == status) return record.toPaymentJson();
      throw RequestUnavailableException(requestId);
    }

    final decided = record.decide(status, at: clock.now().toUtc());
    _records[requestId] = decided;

    return decided.toPaymentJson();
  }

  Future<void> _respond() async {
    if (_latency > Duration.zero) await Future<void>.delayed(_latency);
  }

  String _uniqueId() {
    while (true) {
      final id = 'pay_${_randomHex(8)}';
      if (!_records.containsKey(id)) return id;
    }
  }

  String _uniqueReference() {
    final taken = {for (final record in _records.values) record.reference};
    while (true) {
      final reference = 'PAY-${10000 + _random.nextInt(90000)}';
      if (!taken.contains(reference)) return reference;
    }
  }

  /// Mostly everyday amounts with the occasional large invoice, usually in whole dirhams.
  int _randomAmount() {
    final dirhams = switch (_random.nextInt(10)) {
      < 5 => 20 + _random.nextInt(480),
      < 9 => 500 + _random.nextInt(4500),
      _ => 5000 + _random.nextInt(45000),
    };
    final fils = switch (_random.nextInt(10)) {
      < 7 => 0,
      < 9 => 50,
      _ => _random.nextInt(100),
    };

    return dirhams * 100 + fils;
  }

  // Built from 4-bit chunks: bit shifts past 32 bits misbehave on the web.
  String _randomHex(int length) =>
      List.generate(length, (_) => _random.nextInt(16).toRadixString(16)).join();

  T _pick<T>(List<T> items) => items[_random.nextInt(items.length)];
}

enum _RecordStatus { pending, approved, rejected }

/// The server's own view of a payment, including the fields a device only
/// receives after the user decides.
class _PaymentRecord {
  const _PaymentRecord({
    required this.id,
    required this.reference,
    required this.recipientName,
    required this.minorUnits,
    required this.requestedAt,
    this.note,
    this.status = _RecordStatus.pending,
    this.decidedAt,
  });

  static const _currencyCode = 'AED';

  final String id;
  final String reference;
  final String recipientName;
  final int minorUnits;
  final String? note;
  final DateTime requestedAt;
  final _RecordStatus status;
  final DateTime? decidedAt;

  bool get isDecided => status != _RecordStatus.pending;

  _PaymentRecord decide(_RecordStatus decision, {required DateTime at}) => _PaymentRecord(
    id: id,
    reference: reference,
    recipientName: recipientName,
    minorUnits: minorUnits,
    note: note,
    requestedAt: requestedAt,
    status: decision,
    decidedAt: at,
  );

  Map<String, Object?> toPaymentJson() {
    final decidedAt = this.decidedAt;
    if (decidedAt == null) throw StateError('Request $id has not been decided yet');

    return {
      'id': id,
      'reference': reference,
      'recipient_name': recipientName,
      'amount': {'minor_units': minorUnits, 'currency': _currencyCode},
      'status': status.name,
      'decided_at': decidedAt.toIso8601String(),
      'note': note,
    };
  }

  /// All a device may see before the user authenticates: a masked name and no amount.
  Map<String, Object?> toRequestJson() => {
    'id': id,
    'reference': reference,
    'recipient_masked': maskRecipientName(recipientName),
    'currency': _currencyCode,
    'requested_at': requestedAt.toIso8601String(),
  };
}
