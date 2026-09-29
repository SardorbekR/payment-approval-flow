import 'dart:async';

import 'package:payment_approval/features/payments/data/data_sources/payments_data_source.dart';
import 'package:payment_approval/features/payments/data/models/payment_json.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';

/// The single source of truth for payments on this device.
///
/// Every change is published as a whole [PaymentsSnapshot], so the list, the
/// Home summary and the details screen always show the same state.
class PaymentsRepository {
  PaymentsRepository({required PaymentsDataSource dataSource}) : _dataSource = dataSource;

  final PaymentsDataSource _dataSource;
  final _changes = StreamController<PaymentsSnapshot>.broadcast();
  PaymentsSnapshot? _snapshot;

  /// Replays the latest snapshot to each new listener, then emits every change.
  /// Nothing is emitted until [load] has succeeded.
  Stream<PaymentsSnapshot> watch() => Stream.multi((controller) {
    final current = _snapshot;
    if (current != null) controller.add(current);

    final subscription = _changes.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = subscription.cancel;
  });

  /// Fetches the server state and publishes it. Throws if a request fails or
  /// any item is malformed, so a partial list is never shown as complete.
  Future<void> load() async {
    final [paymentsJson, requestsJson] = await Future.wait([
      _dataSource.fetchPayments(),
      _dataSource.fetchPendingRequests(),
    ]);

    _publish(
      PaymentsSnapshot(
        payments: paymentsJson.map(paymentFromJson),
        pendingRequests: requestsJson.map(paymentRequestFromJson),
      ),
    );
  }

  /// Asks the server for a new incoming request and adds it to the pending ones.
  Future<PaymentRequest> createDebugRequest() async {
    _requireSnapshot();
    final request = paymentRequestFromJson(await _dataSource.createDebugRequest());
    _publish(_requireSnapshot().withPendingRequest(request));

    return request;
  }

  /// Submits [decision] and returns the full payment the server sends back.
  ///
  /// The request leaves the pending list and the payment joins the list in one
  /// snapshot. When the submission fails, the outcome is unclear: the server may
  /// have recorded it before the connection dropped, or the request was decided
  /// elsewhere. So the repository reloads from the server before rethrowing, and
  /// every screen shows the real state.
  Future<Payment> decide(PaymentRequest request, PaymentStatus decision) async {
    _requireSnapshot();
    try {
      final payment = paymentFromJson(
        await _dataSource.submitDecision(
          requestId: request.id,
          decision: paymentStatusToJson(decision),
        ),
      );
      if (payment.id != request.id) {
        throw FormatException('Decision response belongs to another payment', payment.id);
      }

      _publish(_requireSnapshot().withDecidedPayment(payment));

      return payment;
    } on RequestUnavailableException {
      await _catchUpWithServer(orDrop: request.id);
      rethrow;
    } on Exception {
      await _catchUpWithServer();
      rethrow;
    }
  }

  /// Whether [requestId] is still waiting for a decision.
  bool isPending(String requestId) =>
      _snapshot?.pendingRequests.any((request) => request.id == requestId) ?? false;

  Future<void> dispose() => _changes.close();

  /// Reloads from the server. If the server can't be reached either, at least
  /// stop listing [orDrop], a request the server said it no longer has.
  Future<void> _catchUpWithServer({String? orDrop}) async {
    try {
      await load();
    } on Exception {
      if (orDrop != null) _publish(_requireSnapshot().withoutPendingRequest(orDrop));
    }
  }

  PaymentsSnapshot _requireSnapshot() =>
      _snapshot ?? (throw StateError('Payments have not been loaded yet'));

  void _publish(PaymentsSnapshot snapshot) {
    _snapshot = snapshot;
    _changes.add(snapshot);
  }
}
